import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shafici_pos/app.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/order_calculation_model.dart';
import 'package:shafici_pos/models/order_data_model.dart';
import 'package:shafici_pos/models/order_item_model.dart';
import 'package:shafici_pos/models/order_payment_model.dart';
import 'package:shafici_pos/models/payment_method_model.dart';
import 'package:shafici_pos/models/sale_data_model.dart';
import 'package:shafici_pos/models/user_model.dart';
import 'package:shafici_pos/models/web_socket_message_model.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/providers/products_provider.dart';
import 'package:shafici_pos/providers/sales_provider.dart';
import 'package:shafici_pos/providers/web_socket_server_provider.dart';
import 'package:shafici_pos/screens/order_screens/widgets/pos_add_payment_popup.dart';
import 'package:shafici_pos/screens/order_screens/widgets/pos_payment_list_display_widget.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_loading_screen_widget.dart';
import 'package:shafici_pos/ui/ui_no_data_founded.dart';
import 'package:shafici_pos/ui/ui_order_calculation_summary_widget.dart';
import 'package:shafici_pos/ui/ui_popup_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class OrderPaymentScreen extends StatefulWidget {
  const OrderPaymentScreen({super.key});

  @override
  State<OrderPaymentScreen> createState() => _OrderPaymentScreenState();
}

class _OrderPaymentScreenState extends State<OrderPaymentScreen> {
  late UserModel _userData;

  final CApiServices _apiServices = CApiServices();
  final CSecureStorageService _secureStorageService = CSecureStorageService();

  double _amountPaid = 0;
  final List<OrderPaymentModel> _paymentList = [];
  bool _showPaymentPopup = false;
  
  // bool _isLoading = false;
  // String? _errorMessage;
  // String? _successMessage;



  // - - - - - - >>
  // - - - F U N C T I O N S

  
  // -- -- --
  void _toggleShowPaymentPopup() {
    setState(() => _showPaymentPopup = !_showPaymentPopup);
  }

  
  // // -- -- --
  // void _clearMessages() {
  //   setState(() {
  //     _errorMessage = null;
  //     _successMessage = null;
  //   });
  // }

  
  // -- -- --
  void _handleNewPayment(OrderPaymentModel payment) {
    setState(() => _paymentList.add(payment));
    _calculateAmountPaid();
    _toggleShowPaymentPopup();
  }


  // -- -- --
  void _removePayment(int index) {
    setState(() => _paymentList.removeAt(index));
    _calculateAmountPaid();
  }

  
  // -- -- --
  void _calculateAmountPaid() {
    double total = 0;
    for (var payment in _paymentList) { total += payment.paidAmount; }
    setState(() => _amountPaid = total,);
  }

  
  // -- -- --
  Future<void> _handleOrderSubmit(WebSocketServerProvider socketProvider, List<OrderItemModel> items, OrderCalculationModel calculation) async {
    final SalesProvider salesProvider = Provider.of(context, listen: false);

    final double change = _amountPaid > calculation.grandTotal ? _amountPaid - calculation.grandTotal : 0;

    final order = OrderDataModel(
      sellerId: _userData.userId, cashierId: _userData.userId, customerId: null, 
      items: items, orderCalculation: calculation, 
      orderPayments: _paymentList, totalChange: change,
      createdAt: DateTime.now()
    );

    final saleData = SaleDataModel(
      sellerId: _userData.userId, sellerName: '${_userData.firstName} ${_userData.middleName}', 
      cashierId: _userData.userId, cashierName: '${_userData.firstName} ${_userData.middleName}', 
      items: items, orderCalculation: calculation, 
      orderPayments: _paymentList, totalChange: change, 
      createdAt: DateTime.now()
    );

    await salesProvider.sendOrder(order, saleData: saleData);

    final socketMessage = WebSocketMessageModel(
      type: 'order-completed', 
      data: { 'msg': "Order is completed" }
    );

    if (salesProvider.sendSuccessMessage != null) socketProvider.sendMessage(socketMessage);
  }


  Future<void> _goBack() async {
    final ProductsProvider productsProvider = Provider.of(context, listen: false);
    final SalesProvider salesProvider = Provider.of(context, listen: false);
    salesProvider.clearSendMessage();
    await productsProvider.clearActiveSession();
    if (mounted) Navigator.pop(context);
  }

  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final AppInfoProvider appInfoProvider = Provider.of(context, listen: false);
    if (appInfoProvider.currentUser == null) {
      CHelperFunctions.navigateToScreen(context: context, screen: App(), replacement: true);
    } else {
      _userData = appInfoProvider.currentUser!;
    }
  }


  @override
  Widget build(BuildContext context) {
    final webSocketServerProvider = context.watch<WebSocketServerProvider>();

    return Consumer2<ProductsProvider, SalesProvider>(
      builder: (context, productProvider, saleProvider, child) {
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: UiTitleWidget(text: 'order payment'),
              ),
              body: Row(
                children: [
              
                  // O V E R V I E W
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(CSizes.largeGap),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints( maxWidth: 500 ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              UiOrderCalculationSummaryWidget(
                                orderCalculation: productProvider.activeSessionCalc!,
                                amountPaid: _amountPaid,
                                title: 'Overview',
                              ),
                          
                              SizedBox(height: CSizes.largeGap,),
                          
                              Row(
                                children: [
                                  UiButtonWidget(
                                    text: 'back',
                                    tranparent: true,
                                    color: CColors.black,
                                    onClick: () => Navigator.pop(context), 
                                  ),
                          
                                  SizedBox(width: CSizes.mediumGap,),
                                  
                                  Expanded(
                                    child: UiButtonWidget(
                                      text: 'submit',  
                                      isDisabled:  _amountPaid < productProvider.activeSessionCalc!.grandTotal,
                                      onClick: () => _handleOrderSubmit(webSocketServerProvider, productProvider.activeSessionData!.items, productProvider.activeSessionCalc!),
                                    ),
                                  )
                                ],
                              )
                          
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              
              
                  Container(
                    width: 1,
                    color: CColors.black,
                  ),
                  
                  
                  // - - - N O _ P A Y M E N T S
                  Stack(
                    children: [
                      
                    ],
                  ),
                  if (_paymentList.isEmpty) Expanded(
                    child: UiNoDataFounded(
                      title: 'no payment is registered',
                      buttonText: 'add payment',
                      onButtonClick: _toggleShowPaymentPopup,
                    ),
                  ),
              
              
                  // - - - P A Y M E N T _ L I S T
                  if (_paymentList.isNotEmpty) Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(CSizes.largeGap),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              UiButtonWidget(
                                icon: CIcons.walletAdd,
                                text: 'add payment',
                                vericalPadding: CSizes.smallGap,
                                onClick: _toggleShowPaymentPopup
                              )
                            ],
                          ),
                  
                          SizedBox(height: CSizes.largeGap,),

                          Expanded(
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: AlwaysScrollableScrollPhysics(),
                              itemBuilder: (context, index) => PosPaymentListDisplayWidget(
                                index: index, 
                                payment: _paymentList[index], 
                                onDeleteClick: () => _removePayment(index)
                              ), 
                              separatorBuilder: (context, index) => SizedBox(height: CSizes.mediumGap,), 
                              itemCount: _paymentList.length
                            ),
                          )

                        ],
                      ),
                    ),
                  )
              
                ],
              ),
            ),
    
    
    
            // - - - A D D _ P A Y M E N T _ P O P U P
            if (_showPaymentPopup) Scaffold(
              backgroundColor: CColors.transparent,
              body: PosAddPaymentPopup(
                onCloseClick: _toggleShowPaymentPopup, 
                // onSubmitClick: (paymentMethod, amount) => _handleNewPayment(paymentMethod, amount),
                onSubmitClick: (payment) => _handleNewPayment(payment),
              ),
            ),
    
    
    
    
    
            // - - - S U C C E S S _ P O P U P
            if (saleProvider.sendSuccessMessage != null) Scaffold(
              backgroundColor: CColors.transparent,
              body: UiPopupWidget(
                isSuccess: true,
                message: saleProvider.sendSuccessMessage!, 
                primaryText: 'okey', 
                primaryClick: _goBack, 
                outSideClick: _goBack
              ),
            ),
    
    
    
    
    
            // - - - E R R O R _ P O P U P
            if (saleProvider.sendErrorMessage != null) Scaffold(
              backgroundColor: CColors.transparent,
              body: UiPopupWidget(
                message: saleProvider.sendErrorMessage!, 
                primaryText: 'okey', 
                primaryClick: saleProvider.clearSendMessage, 
                outSideClick: saleProvider.clearSendMessage
              ),
            ),
    
    
    
    
    
            // - - - I S _ L O A D I N G
            if (saleProvider.sendIsLoading) Scaffold(
              backgroundColor: CColors.transparent,
              body: UiLoadingScreenWidget(
                fullScreen: true,
                transparent: true,
              ),
            )
    
          ],
        );
      },
    );
  }
}