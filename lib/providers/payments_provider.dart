import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shafici_pos/constants/hive_strings.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/models/payment_method_model.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';

class PaymentMethodsProvider extends ChangeNotifier {
  final CApiServices _apiServices = CApiServices();
  final CSecureStorageService _secureStorageService = CSecureStorageService();

  final Box<PaymentMethodModel> _paymentMethodsBox = Hive.box(CHiveStrings.paymentMethodsBox);

  List<PaymentMethodModel> _paymentMethods = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PaymentMethodModel> get paymentMethods => _paymentMethods;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;


  Future<void> setPaymentMethods() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _fetchPaymentMethods();
    } catch (e) {
      _errorMessage = 'could not get payment methods';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> _fetchPaymentMethods() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
      final response = await _apiServices.getRequest(url: CUrlStrings.getPaymentMethodsUrl, authToken: deviceToken);
      switch (response.statusCode) {
        case 200: {
          final List<dynamic> data = response.data;
          final Iterable<PaymentMethodModel> methods = data.map((method) => PaymentMethodModel.fromMap(method));
          await _paymentMethodsBox.clear();
          await _paymentMethodsBox.addAll(methods);
        }

        default: _errorMessage = response.data;
      }
    } catch (e) {
      _errorMessage = 'Failed to get payment methods data';
      notifyListeners();
    } finally {
      _isLoading = false;
      _paymentMethods = _paymentMethodsBox.values.toList();
      notifyListeners();
    }
  }
}