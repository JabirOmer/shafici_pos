import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shafici_pos/constants/hive_strings.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/models/order_data_model.dart';
import 'package:shafici_pos/models/sale_data_model.dart';
import 'package:shafici_pos/models/user_model.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/providers/users_provider.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';

class SalesProvider extends ChangeNotifier {
  final AppInfoProvider appInfoProvider;

  SalesProvider({ required this.appInfoProvider });

  final CApiServices _apiServices = CApiServices();
  final CSecureStorageService _secureStorageService = CSecureStorageService();
  final Box<SaleDataModel> _offlineSalesBox = Hive.box(CHiveStrings.offlineSalesBox);


  // final List<SaleDataModel> _offlineSalesList = ;
  final List<SaleDataModel> _salesList = [];
  DateTime _salesDate = DateTime.now();
  bool _showOfflineOrders = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool _sendIsLoading = false;
  String? _sendErrorMessage;
  String? _sendSuccessMessage;

  List<SaleDataModel> get offlineSalesList => _offlineSalesBox.values.toList();
  List<SaleDataModel> get salesList => _salesList;
  DateTime get salesDate => _salesDate;
  bool get showOfflineOrders => _showOfflineOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get sendIsLoading => _sendIsLoading;
  String? get sendErrorMessage => _sendErrorMessage;
  String? get sendSuccessMessage => _sendSuccessMessage;

  // Instances
  double get totalSales => _calculateTotalSales();
  double get totalChange => _calculateTotalChange();





  // - - - F E T C H _ O N L I N E _ S A L E S
  Future<void> fetchOnlineSales() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(Duration(seconds: 1));
    
    try {
      final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
      final dataMap = { 
        "start_date": salesDate.toIso8601String(),
        "end_date": salesDate.toIso8601String()
      };

      final response = await _apiServices.postRequest(url: CUrlStrings.getSalesUrl, data: dataMap, authToken: deviceToken);

      switch (response.statusCode) {
        case 200: {
          final List<dynamic> data = response.data;
          final List<SaleDataModel> salesData = data.map((sale) => SaleDataModel.fromMap(sale)).toList();

          // - - - filter out
          final userData  = appInfoProvider.currentUser;
          final userRole = userData?.userRole;
          late List<SaleDataModel> filteredData;

          switch (userRole) {
            case 'admin': filteredData = salesData;
            case 'cashier': filteredData = salesData.where((s) => s.cashierId == userData!.userId).toList();
            default: filteredData = [];
          }

          _salesList.clear();
          _salesList.addAll(filteredData);
        }
        default: {
          _salesList.clear();
          _errorMessage = response.data;
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to get sales data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }





  // - - - S E N D _ O R D E R
  Future<void> sendOrder(OrderDataModel order, { bool resend = false, SaleDataModel? saleData }) async {
    if (_sendIsLoading) return;

    _sendIsLoading = true;
    _sendErrorMessage = null;
    _sendSuccessMessage = null;
    notifyListeners();

    await Future.delayed(Duration(seconds: 3));

    try {
      final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
      final dataMap = { "order_data": order.toJson() };
      final response = await _apiServices.postRequest(url: CUrlStrings.sendOrderUrl, data: dataMap, authToken: deviceToken);

      switch (response.statusCode) {
        case 201: {
          _sendSuccessMessage = response.data['msg'];
          if (resend && saleData != null) removeFromOfflineList(saleData);
        }
        default: _sendErrorMessage = response.data;
      }
    } catch (e) {
      _sendErrorMessage = 'failed to resend';

      if (!resend && saleData != null) {
        final addedToOffline = await addToOfflineOrders(saleData);
        if (addedToOffline) _sendErrorMessage = 'order is saved offline';
      }
    }
    finally {
      _sendIsLoading = false;
      notifyListeners();
    }
  }





  // - - - O F F L I N E _ O R D E R S
  Future<bool> addToOfflineOrders(SaleDataModel saleData) async {
    try {
      await _offlineSalesBox.add(saleData);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }





  // - - - R E M O V E _ F R O M _ O F F L I N E _ L I S T
  Future<bool> removeFromOfflineList(SaleDataModel saleData) async {
    try {
      final list = offlineSalesList;
      final index = list.indexOf(saleData);

      if (index == -1) return false;
      _offlineSalesBox.deleteAt(index);
      notifyListeners();

      return true;
    } catch (e) {
      if (kDebugMode) print('Failed to remove order from offline list: $e');
      return false;
    }
  }





  // - - - C L E A R _ E R R O R
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }




  // - - - C L E A R _ S E N D _ M E S S A G E
  void clearSendMessage() {
    _sendErrorMessage = null;
    _sendSuccessMessage = null;
    notifyListeners();
  }




  // - - - T O G G L E _ S H O W _ O F F L I N E
  void toggleShowOfflineOrders(bool offline) {
    if (_showOfflineOrders == offline) return;
    _showOfflineOrders = offline;
    notifyListeners();
  }




  // - - - C H A N G E _ S A L E S _ D A T E
  Future<void> changeSalesDate(DateTime date) async {
    _salesDate = date;
    notifyListeners();
    await fetchOnlineSales();
  }




  // - - - TOTAL_SALES
  double _calculateTotalSales() {
    final List<SaleDataModel> orderList = salesList;
    double total = 0;
    for (var order in orderList) { total += order.orderCalculation.grandTotal; }
    return total;
  }

  // Total Change
  double _calculateTotalChange() {
    final List<SaleDataModel> orderList = salesList;
    double total = 0;
    for (var order in orderList) { total += order.totalChange; }
    return total;
  }
}