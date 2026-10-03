import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:shafici_pos/constants/hive_strings.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/shared_prefs_keys.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/models/order_calculation_model.dart';
import 'package:shafici_pos/models/order_item_model.dart';
import 'package:shafici_pos/models/order_session_model.dart';
import 'package:shafici_pos/models/product_category_model.dart';
import 'package:shafici_pos/models/product_model.dart';
import 'package:shafici_pos/models/web_socket_message_model.dart';
import 'package:shafici_pos/providers/web_socket_server_provider.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';
import 'package:shafici_pos/services/shared_preferences_services.dart';


enum StockStatusEnum { avaiable, lowStock, outOfStock }

class ProductsProvider extends ChangeNotifier {
  // Providers
  final WebSocketServerProvider webSocketServerProvider;

  // Services
  final CSecureStorageService _secureStorageService = CSecureStorageService();
  final CSharedPreferencesServices _sharedPreferencesServices = CSharedPreferencesServices();
  final CApiServices _apiServices = CApiServices();
  
  // Hive Boxes
  final Box<ProductModel> _productsBox = Hive.box(CHiveStrings.productsBox);
  final Box<ProductCategoryModel> _productCategoriesBox = Hive.box(CHiveStrings.productCategoriesBox);
  final Box<OrderSessionModel> _orderSessionsBox = Hive.box<OrderSessionModel>(CHiveStrings.orderSessionsBox);

  // Prefs
  bool get onDiscount => _sharedPreferencesServices.getBool(CSharedPrefsKeys.onDiscount) ?? false;
  bool get addVAT => _sharedPreferencesServices.getBool(CSharedPrefsKeys.calculateVAT) ?? false;

  // Local variables
  final List<ProductModel> _productList = [];
  final List<ProductCategoryModel> _productCategoryList = [];
  // final List<OrderSessionModel> _orderSessions = [];
  int _activeSessionId = 1;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Global variables
  List<ProductModel> get productList => _productList;
  List<ProductCategoryModel> get productCategoryList => _productCategoryList;
  List<OrderSessionModel> get orderSessions => _orderSessionsBox.values.toList();
  int get activeSessionId => _activeSessionId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // - - - INSTANCES
  OrderSessionModel? get activeSessionData => _orderSessionsBox.values.firstWhereOrNull((s) => s.sessionId == activeSessionId);
  OrderCalculationModel? get activeSessionCalc => activeSessionData == null ? null : _calculateSession(onDiscount: onDiscount, addVAT: addVAT);
  // - - -
  List<ProductModel> get lowStockProducts => _getLowProducts();
  List<ProductModel> get outOfStockProducts => _getOutOfStockProducts();
  List<ProductModel> get expiredProducts => _getExpiredProducts();
  List<ProductModel> get expiringProducts => _getProductsExpiringIn7Days();




  ProductsProvider({
    required this.webSocketServerProvider
  });



  Future<void> setProducts({ bool onlyProducts = false, bool onlyCategories = false }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!onlyCategories) await _fetchProducts();
      if (!onlyProducts) await _fetchCategories();
    } catch (e) {
      _errorMessage = 'could not find products data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> _fetchProducts() async {
    try {
      final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
      print('gettings products');
      final resposne = await _apiServices.getRequest(url: CUrlStrings.getProductsUrl, authToken: deviceToken);
      print('products got: ${resposne.statusCode}');

      switch (resposne.statusCode) {
        case 200: {
          final List<dynamic> data = resposne.data;
          final Iterable<ProductModel> products = data.map((product) => ProductModel.fromMap(product));
          await _productsBox.clear();
          await _productsBox.addAll(products);
          await _reAssignOrderSession();
        }
      }
    }
    catch (e) {
      if (kDebugMode) print('Failed to get products: $e');
    }
    finally {
      _productList.clear();
      _productList.addAll(_productsBox.values.toList());
      notifyListeners();
    }
  }


  Future<void> _fetchCategories() async {
    try {
      final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
      final resposne = await _apiServices.getRequest(url: CUrlStrings.getCategoriesUrl, authToken: deviceToken);
      
      switch (resposne.statusCode) {
        case 200: {
          final List<dynamic> data = resposne.data;
          final Iterable<ProductCategoryModel> categories = data.map((category) => ProductCategoryModel.fromMap(category));
          await _productCategoriesBox.clear();
          await _productCategoriesBox.addAll(categories);
        }
      }
    }
    finally {
      _productCategoryList.clear();
      _productCategoryList.addAll(_productCategoriesBox.values.toList());
      notifyListeners();
    }
  }




  // - - - - - -
  // - - - O V E R V I E W
  // - - - - - -



  List<ProductModel> _getLowProducts() {
    final products = productList;
    return products.where((p) => (p.stock <= p.alertQuantity && p.stock > 0)).toList();
  }
  
  List<ProductModel> _getOutOfStockProducts() {
    final products = productList;
    return products.where((p) => p.stock == 0).toList();
  }
  
  List<ProductModel> _getExpiredProducts() {
    final products = productList;
    final now = DateTime.now().toUtc();
    return products.where((p) => p.expireDate != null && p.expireDate!.isBefore(now)).toList();
  }

  List<ProductModel> _getProductsExpiringIn7Days() {
  final now = DateTime.now().toUtc();
  final startRange = now.add(const Duration(days: 1));
  final endRange = now.add(const Duration(days: 30));

  return productList.where((p) {
    if (p.expireDate == null) return false;
    final expireDate = p.expireDate!;
    return expireDate.isAfter(startRange) && expireDate.isBefore(endRange);
  }).toList();
}





  // - - - - - - >
  // - - - O R D E R _ S E S S I O N S


  // - - -  - - -  - - -
  // Future<void> _initializeOrderSession() async {
  //   print('\ninitializing');
  //   final List<OrderSessionModel> sessions = _orderSessionsBox.values.toList();
  //   if (sessions.isEmpty) { 
  //     await createOrderSession();
  //     return;
  //   }
  //   print('object 0001x');
  //   // _orderSessions..clear()..addAll(_orderSessionsBox.values.toList());
  // }



  // --- --- ---
  Future<void> _reAssignOrderSession() async { 
    await _orderSessionsBox.clear();
    notifyListeners();
  }


  // - - -  - - -  - - -
  Future<void> createOrderSession() async {
    final sessions = _orderSessionsBox.values.toList();
    final sessionId = sessions.length+1;
    final session = OrderSessionModel(sessionId: sessionId, items: []);

    await _orderSessionsBox.put(sessionId, session);
    notifyListeners();
    setActiveSession(sessionId);
  }


  // - - -  - - -  - - -
  void setActiveSession(int sessionId) {
    _activeSessionId = sessionId;
    notifyListeners();
    _sendOrderDataToDisplay();
  }

  // - - -  - - -  - - -
  Future<void> deleteOrderSession(int sessionId) async {
    final List<OrderSessionModel> remainingSessions = _orderSessionsBox.values.where((s) => s.sessionId != sessionId).toList();
    Map<int, OrderSessionModel> arrengedSession = {};
    
    for (var i = 0; i < remainingSessions.length; i++) {
      final freshId = i+1;
      final freshSession = OrderSessionModel(sessionId: freshId, items: remainingSessions[i].items);
      arrengedSession[freshId] = freshSession;
    }

    await _orderSessionsBox.clear();
    await _orderSessionsBox.putAll(arrengedSession);
    notifyListeners();

    sessionId == 1 ? null : setActiveSession(sessionId-1);
  }


  // -- -- --
  Future<void> clearActiveSession() async {
    final sessionId = activeSessionId;
    final clear = OrderSessionModel(sessionId: sessionId, items: []);
    await _orderSessionsBox.put(sessionId, clear);
    // _orderSessions..clear()..addAll(_orderSessionsBox.values.toList());
    notifyListeners();
  }





  // - - - - - -
  // - - - S E S S I O N _ I T E M S


  // - - -  - - -  - - -
  Future<void> incrementItemInOrderSession(ProductModel product) async {
    final OrderSessionModel? session = activeSessionData;
    if (session == null) return;

    final itemIndex = session.items.indexWhere((i) => i.productId == product.productId);
    
    if (itemIndex == -1) {
      final newItem = OrderItemModel(
        productId: product.productId, 
        productName: product.productName, 
        isTaxable: product.isTaxable, 
        unitCost: product.unitCost, 
        unitSoldAt: product.sellingPrice, 
        quantity: 1, 
        createdAt: DateTime.now()
      );

      session.items.add(newItem);
    } 
    else {
      // final availableQty = product.stock;
      final currentQty = session.items[itemIndex].quantity;

      // if (availableQty <= currentQty) return;
      session.items[itemIndex].quantity += 1;
    }
    notifyListeners();

    session.items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _orderSessionsBox.put(activeSessionId, session);
    notifyListeners();

    _sendOrderDataToDisplay();
  }


  // - - -  - - -  - - -
  Future<void> decrementItemInOrderSession(ProductModel product) async {
        final session = activeSessionData;
    if (session == null) return;

    final itemIndex = session.items.indexWhere((i) => i.productId == product.productId);

    if (itemIndex != -1 && session.items[itemIndex].quantity > 1) {
      session.items[itemIndex].quantity-=1;
      await _orderSessionsBox.put(session.sessionId, session);
      notifyListeners();
    }

    _sendOrderDataToDisplay();
  }


  // - - -  - - -  - - -
  Future<void> removeItemFromOrderSession(ProductModel product) async {
    final session = activeSessionData;
    if (session == null) return;

    final itemIndex = session.items.indexWhere((i) => i.productId == product.productId);
    
    if (itemIndex != -1) {
      session.items.removeWhere((s) => s.productId == product.productId);
      session.items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      await _orderSessionsBox.put(activeSessionId, session);
      // _orderSessions..clear()..addAll(_orderSessionsBox.values.toList());
      notifyListeners();
    }

    _sendOrderDataToDisplay();
  }





  // - - - - - - >>
  // - - - S E S S I O N _ C A L C U L A T I O N S

  // OrderSessionModel? _getActiveSessionData() {
  //   if (_orderSessionsBox.isEmpty) return null;
  //   return _orderSessionsBox.values.firstWhere((s) => s.sessionId == _activeSessionId);
  // }


  // Func 1.3
  OrderCalculationModel _calculateSession({ required bool onDiscount, required bool addVAT }) {
    final OrderSessionModel? session = activeSessionData;

    if (session == null) return OrderCalculationModel(subtotal: 0, discount: 0, taxable: 0, vat: 0, grandTotal: 0, totalCost: 0);

    double subtotal = _calculateSessionSubtotal(session);
    // double discount = onDiscount ? subtotal - _calculateSessionDiscount(session) : 0;
    double discount = 0; 
    double taxable = _calculateSessionTaxable(session, onDiscount);   
    double vat = addVAT ? (taxable * 0.15) : 0;
    double grandTotal = (subtotal-discount)+vat;
    double totalCost = _calculateSessionCost(session);

    return OrderCalculationModel(
      subtotal: subtotal, 
      discount: discount, 
      taxable: taxable, 
      vat: vat, 
      grandTotal: grandTotal,
      totalCost: totalCost
    );
  }

  double _calculateSessionSubtotal(OrderSessionModel session) {
    double subtotal = 0;
    for (var item in session.items) {
      subtotal = subtotal + (item.quantity * item.unitSoldAt);
    }
    return subtotal;
  }

  double _calculateSessionDiscount(OrderSessionModel session) {
    double onDiscount = 0;
    // for (var item in session.items) {
    //   onDiscount = onDiscount + (item.quantity * item.onDiscountPrice);
    // }
    return onDiscount;
  }

  double _calculateSessionTaxable(OrderSessionModel session, bool onDiscount) {
    double taxable = 0;
    for (var item in session.items) {
      // if (!item.isTaxable) continue;
      // if (onDiscount) taxable += (item.quantity * item.onDiscount);
      // taxable = item.unitSoldAt * item.quantity;
      print('\n');
      if (item.isTaxable) {
        print('${item.productName} is taxable');
        taxable = taxable + (item.unitSoldAt * item.quantity);
      } else {
        print('${item.productName} is not taxable');
      }

    }

    print('Total taxable: $taxable');
    return taxable;
  }

  double _calculateSessionCost(OrderSessionModel session) {
    double totalCost = 0;
    for (var item in session.items) {
      totalCost += (item.quantity * item.unitCost);
    }
    return totalCost;
  }





  // - - - W E B _ S O C K E T
  Future<void> _sendOrderDataToDisplay() async {
    final message = WebSocketMessageModel(
      type: 'order', 
      data: {
        'order_items': activeSessionData!.items,
        'order_calculation': activeSessionCalc!
      }
    );
    await webSocketServerProvider.sendMessage(message);
  }



  // -- -- --
  Future<void> manuallyRecalculate() async {
    _calculateSession(onDiscount: onDiscount, addVAT: addVAT);
    await _sendOrderDataToDisplay();
  }

}