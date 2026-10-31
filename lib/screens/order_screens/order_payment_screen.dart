import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shafici_pos/app.dart';
import 'package:shafici_pos/blocs/cubits/customer_cubit.dart';
import 'package:shafici_pos/blocs/states/customer_state.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/shadows.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/credit_model.dart';
import 'package:shafici_pos/models/customer_model.dart';
import 'package:shafici_pos/models/order_calculation_model.dart';
import 'package:shafici_pos/models/order_data_model.dart';
import 'package:shafici_pos/models/order_item_model.dart';
import 'package:shafici_pos/models/order_payment_model.dart';
import 'package:shafici_pos/models/payment_method_model.dart';
import 'package:shafici_pos/models/adapters/register_credit_model.dart';
import 'package:shafici_pos/models/sale_data_model.dart';
import 'package:shafici_pos/models/user_model.dart';
import 'package:shafici_pos/models/web_socket_message_model.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/providers/products_provider.dart';
import 'package:shafici_pos/providers/sales_provider.dart';
import 'package:shafici_pos/providers/web_socket_server_provider.dart';
import 'package:shafici_pos/screens/credit_screens/create_credit_widget.dart';
import 'package:shafici_pos/screens/order_screens/widgets/pos_add_payment_popup.dart';
import 'package:shafici_pos/screens/order_screens/widgets/pos_payment_list_display_widget.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_loading_screen_widget.dart';
import 'package:shafici_pos/ui/ui_no_data_founded.dart';
import 'package:shafici_pos/ui/ui_order_calculation_summary_widget.dart';
import 'package:shafici_pos/ui/ui_popup_widget.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class OrderPaymentScreen extends StatefulWidget {
  const OrderPaymentScreen({super.key});

  @override
  State<OrderPaymentScreen> createState() => _OrderPaymentScreenState();
}

class _OrderPaymentScreenState extends State<OrderPaymentScreen> {
  late UserModel _userData;
  late ProductsProvider _productsProvider;

  final _apiServices = CApiServices();
  final _secureStorageService = CSecureStorageService();
  final _discountController = TextEditingController();

  double _amountPaid = 0;
  CustomerModel? _selectedCustomer;
  final _customerNameController = TextEditingController();
  RegisterCreditModel? _creditData;
  final List<OrderPaymentModel> _paymentList = [];

  bool _showCustomersList = false;
  bool _showCreditPopup = false;
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

  // -- -- --
  void _toggleShowCreditPopup() {
    setState(() => _showCreditPopup = !_showCreditPopup);
  }

  // -- -- --
  void _toggleShowCustomersList() {
    setState(() => _showCustomersList = !_showCustomersList);
  }

  // -- -- --
  void _handleCustomerChange(CustomerModel customer) {
    setState(() {
      _selectedCustomer = customer;
      _customerNameController.text = customer.customerName;
    });
    _toggleShowCustomersList();
  }

  
  // -- -- --
  void _handleNewPayment(OrderPaymentModel payment) {
    setState(() => _paymentList.add(payment));
    _calculateAmountPaid();
    _toggleShowPaymentPopup();
  }


  // -- -- --
  void _handleAddCredit(double amount) {
    if (_selectedCustomer == null) return;

    setState(() => _creditData = RegisterCreditModel(customer: _selectedCustomer!, amount: amount));
    _toggleShowCreditPopup();
    _calculateAmountPaid();
  }


  // -- -- --
  void _removePayment(int index) {
    setState(() => _paymentList.removeAt(index));
    _calculateAmountPaid();
  }

  // -- -- --
  void _deleteCredit() {
    setState(() => _creditData = null);
    _calculateAmountPaid();
  }

  
  // -- -- --
  void _calculateAmountPaid() {
    double totalPayments = 0;
    for (var payment in _paymentList) { totalPayments += payment.paidAmount; }
    double totalCredit = _creditData?.amount ?? 0;

    setState(() => _amountPaid = (totalPayments + totalCredit),);
  }

  // -- -- --
  Future<void> _handleDiscountChange(String value) async {
    _productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    final discount = double.tryParse(value) ?? 0.00;
    await _productsProvider.handleDiscountChange(discount);
  }

  
  // -- -- --
  Future<void> _handleOrderSubmit(WebSocketServerProvider socketProvider, List<OrderItemModel> items, OrderCalculationModel calculation) async {
    final SalesProvider salesProvider = Provider.of(context, listen: false);

    final double change = _amountPaid > calculation.grandTotal ? _amountPaid - calculation.grandTotal : 0;

    // - - - O R D E R _ D A T A ( F O R _ A P I )
    final order = OrderDataModel(
      sellerId: _userData.userId, 
      cashierId: _userData.userId, 
      customerId: null, 
      items: items, 
      orderCalculation: calculation, 
      orderPayments: _paymentList, 
      totalChange: change,
      createdAt: DateTime.now(),
      creditData: _creditData
    );

    
    // - - - F O R _ O F F L I N E _ D I S P L A Y
    final saleData = SaleDataModel(
      sellerId: _userData.userId, 
      sellerName: '${_userData.firstName} ${_userData.middleName}', 
      cashierId: _userData.userId, 
      cashierName: '${_userData.firstName} ${_userData.middleName}', 
      items: items, 
      orderCalculation: calculation, 
      orderPayments: _paymentList, 
      totalChange: change, 
      createdAt: DateTime.now(),
      creditData: _creditData == null ? null : CreditModel(
        branchId: 'this branch', 
        creditId: 'unknown', 
        totalAmount: _creditData!.amount, 
        customer: _creditData!.customer, 
        creditStatus: 'pending', 
        records: [], 
        items: [],
        createdAt: DateTime.now()
      )
    );

    await salesProvider.sendOrder(order, saleData: saleData);

    final socketMessage = WebSocketMessageModel(
      type: 'order-completed', 
      data: { 'msg': "Order is completed" }
    );

    if (salesProvider.sendSuccessMessage != null) socketProvider.sendMessage(socketMessage);
  }


  Future<void> _goBack() async {
    _productsProvider = Provider.of(context, listen: false);
    final SalesProvider salesProvider = Provider.of(context, listen: false);
    salesProvider.clearSendMessage();
    await _productsProvider.clearActiveSession();
    if (mounted) Navigator.pop(context);
  }

  void _clearMessage() {
    final SalesProvider salesProvider = Provider.of(context, listen: false);
    salesProvider.clearSendMessage();
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _productsProvider = Provider.of(context, listen: false);
      _discountController.text = _productsProvider.activeSessionCalc?.discount.toString() ?? '';
    });
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
                                onDiscountChange: (value) => _handleDiscountChange(value),
                                discountController: _discountController,
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
                  Expanded(
                    child: Stack(
                      children: [
                        
                        // if (_paymentList.isEmpty) Center(
                        //   child: UiNoDataFounded(
                        //     title: 'no payment is registered',
                        //     buttonText: 'add payment',
                        //     onButtonClick: _toggleShowPaymentPopup,
                        //   ),
                        // ),


                        // - - - P A Y M E N T _ L I S T
                        Padding(
                          padding: EdgeInsets.all(CSizes.largeGap),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: UiButtonWidget(
                                      icon: CIcons.profileAdd,
                                      text: 'customer',
                                      tranparent: true,
                                      vericalPadding: CSizes.smallGap,
                                      onClick: _toggleShowCustomersList
                                    ),
                                  ),

                                  SizedBox(width: CSizes.mediumGap,),

                                  if (_selectedCustomer != null) Expanded(
                                    child: UiButtonWidget(
                                      icon: CIcons.walletAdd,
                                      text: 'credit',
                                      tranparent: true,
                                      vericalPadding: CSizes.smallGap,
                                      onClick: _toggleShowCreditPopup
                                    ),
                                  ),

                                  if (_selectedCustomer != null) SizedBox(width: CSizes.mediumGap,),

                                  Expanded(
                                    child: UiButtonWidget(
                                      icon: CIcons.walletAdd,
                                      text: 'add payment',
                                      vericalPadding: CSizes.smallGap,
                                      onClick: _toggleShowPaymentPopup
                                    ),
                                  )
                                ],
                              ),
                                                
                              SizedBox(height: CSizes.largeGap,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  UiTitleWidget(
                                    text: 'Customer name:',
                                    bold: false,
                                    defaultText: true,
                                  ),

                                  UiTitleWidget(
                                    text:  CHelperFunctions.capitalizeWords(_selectedCustomer?.customerName ?? 'unknown'),
                                    bold: false,
                                  )
                                ],
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  UiTitleWidget(
                                    text: 'Phone number:',
                                    bold: false,
                                    defaultText: true,
                                  ),

                                  UiTitleWidget(
                                    text:  _selectedCustomer?.phoneNumber ?? 'unknown',
                                    bold: false,
                                  )
                                ],
                              ),

                              SizedBox(height: CSizes.largeGap,),

                              if (_creditData != null) Container(
                                decoration: BoxDecoration(
                                  color: CColors.deepPurple,
                                  borderRadius: BorderRadius.circular(CSizes.xLargeGap),
                                  boxShadow: CShadows.shadow1,
                                ),
                                padding: EdgeInsets.all(CSizes.mediumGap),
                                margin: EdgeInsets.only(bottom: CSizes.largeGap),
                                child: Row(
                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: CColors.white,
                                              borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: CSizes.mediumGap),
                                            margin: EdgeInsets.only( right: CSizes.mediumGap ),
                                            child: Center(
                                              child: UiTitleWidget(
                                                text: 'Credit',
                                                bold: false,
                                                textAlign: TextAlign.center,
                                                // color: CColors.whiteShade2,
                                              ),
                                            ),
                                          ),

                                          UiTitleWidget(
                                            text: _creditData!.customer.customerName,
                                            color: CColors.white,
                                          ),
                                        ],
                                      ),
                                    ),

                                    UiTitleWidget(
                                        text: '  ${CHelperFunctions.formatNumberWithComma(_creditData!.amount)} Birr  ',
                                        defaultText: true,
                                        color: CColors.white,
                                        medium: true,
                                      ),
                              
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          UiButtonWidget(
                                            icon: CIcons.trashIcon,
                                            vericalPadding: CSizes.smallGap,
                                            horizontalPadding: CSizes.smallGap,
                                            backgroundColor: CColors.red,
                                            onClick: _deleteCredit
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

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
                              ),
                        
                            ],
                          ),
                        ),


                        // - - - C U S T O M E R S
                        if (_showCustomersList) _customersListWidget(),


                        // - - - A D D _ P A Y M E N T _ P O P U P
                        if (_showPaymentPopup) PosAddPaymentPopup(
                          onCloseClick: _toggleShowPaymentPopup, 
                          // onSubmitClick: (paymentMethod, amount) => _handleNewPayment(paymentMethod, amount),
                          onSubmitClick: (payment) => _handleNewPayment(payment),
                        ),


                        // - - - A D D _ C R E D I T _ P O P U P
                        if (_showCreditPopup) CreateCreditWidget(
                          onCancel: _toggleShowCreditPopup,
                          customer: _selectedCustomer,
                          onSubmit: (amount) => _handleAddCredit(amount), 
                        ),

                      ],
                    ),
                  ),
              
                ],
              ),
            ),
    
    
    
            // // - - - A D D _ P A Y M E N T _ P O P U P
            // if (_showPaymentPopup) Scaffold(
            //   backgroundColor: CColors.transparent,
            //   body: PosAddPaymentPopup(
            //     onCloseClick: _toggleShowPaymentPopup, 
            //     // onSubmitClick: (paymentMethod, amount) => _handleNewPayment(paymentMethod, amount),
            //     onSubmitClick: (payment) => _handleNewPayment(payment),
            //   ),
            // ),
    
    
    
    
    
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
                primaryText: 'try again', 
                primaryClick: _clearMessage, 
                secondaryText: 'back', 
                secondaryClick: _goBack,
                outSideClick: () {}
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


  ClipRRect _customersListWidget() {
    return ClipRRect(
      child: Container(
        height: double.infinity,
        color: CColors.dimmedBackgound,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: CSizes.blurSigma, sigmaY: CSizes.blurSigma),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: CColors.whiteShade1,
                border: Border.all(width: 1, color: CColors.whiteShade2),
                borderRadius: BorderRadius.circular(CSizes.largeGap)
              ),
              padding: EdgeInsets.all(CSizes.largeGap),
              margin: EdgeInsets.all(CSizes.largeGap),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  UiTitleWidget(text: 'Select customer', bigger: true, ),
                  
                  SizedBox(height: CSizes.largeGap,),
                  
                  Expanded(
                    child: BlocBuilder<CustomerCubit, CustomerState>(
                      builder: (context, state) {
                        if (state.customersDataList.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.all(CSizes.largeGap),
                            child: UiTitleWidget(text: 'No customers are founded', bold: false,)
                          );
                        }
                        return ListView.separated(
                          // padding: EdgeInsets.all(CSizes.largeGap),
                          padding: EdgeInsets.all(0),
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final customer = state.customersDataList[index];
                            return _customerListTile(
                              index: index,
                              customer: customer,
                              onClick: () => _handleCustomerChange(customer)
                            );
                          }, 
                          separatorBuilder: (context, index) => Divider( height: 1, color: CColors.whiteShade2, indent: 47, ), 
                          itemCount: state.customersDataList.length
                        );
                      },
                    ),
                  ),

                  SizedBox(height: CSizes.largeGap,),

                  UiButtonWidget(
                    text: 'cancel',
                    // backgroundColor: CColors.transparent,
                    tranparent: true,
                    onClick: _toggleShowCustomersList
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  GestureDetector _customerListTile({
    required int index,
    required CustomerModel customer,
    required void Function() onClick
  }) {
    return GestureDetector(
      onTap: onClick,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          color: CColors.transparent,
          padding: EdgeInsets.symmetric( vertical: CSizes.smallGap, ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: CColors.whiteShade2,
                        borderRadius: BorderRadius.circular(CSizes.mediumGap)
                      ),
                      margin: EdgeInsets.only(right: CSizes.mediumGap),
                      child: Center(
                        child: UiTitleWidget(
                          text: (index+1).toString().padLeft(2, '0'),
                          customSize: 10,
                        )
                      ),
                    ),
                        
                    UiTitleWidget(text: customer.customerName, bold: false,)
                        
                  ],
                ),
              ),

              SizedBox(width: CSizes.mediumGap,),

              UiTitleWidget(text: customer.phoneNumber, bold: false, color: CColors.whiteShade3,)

            ],
          ),
        ),
      ),
    );
  }
}