import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/order_data_model.dart';
import 'package:shafici_pos/models/payment_method_model.dart';
import 'package:shafici_pos/models/sale_data_model.dart';
import 'package:shafici_pos/models/user_model.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/providers/payments_provider.dart';
import 'package:shafici_pos/providers/sales_provider.dart';
import 'package:shafici_pos/providers/users_provider.dart';
import 'package:shafici_pos/screens/login_screens/login_screen.dart';
import 'package:shafici_pos/screens/sales_screen/widgets/sale_details_popup_widget.dart';
import 'package:shafici_pos/screens/sales_screen/widgets/sales_list_display_widget.dart';
import 'package:shafici_pos/screens/sales_screen/widgets/sales_overview_widget.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_loading_screen_widget.dart';
import 'package:shafici_pos/ui/ui_no_data_founded.dart';
import 'package:shafici_pos/ui/ui_popup_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  late UserModel _userData;
  SaleDataModel? _saleDetails;
  bool? _isOfflineDetails;
  bool _showPaymentsOverview = false;



  // - - - - - -
  // - - - F U N C T I O N S

  // -- -- --
  bool _dateIsToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
      date.month == now.month && 
      date.day == now.day;
  }

  // -- -- --
  void _showDatePicker(DateTime initialDate) {
    showDatePicker(
      context: context, 
      firstDate: DateTime(2026), 
      lastDate: DateTime.now(),
      initialDate: initialDate
    )
    .then(
      (date) {
        if (date == null) return;
        _handleDateChange(date);
      }
    );
  }

  // -- -- --
  Future<void> _handleDateChange(DateTime date) async {
    final SalesProvider salesProvider = Provider.of(context, listen: false);
    await salesProvider.changeSalesDate(date);
  }


  // -- -- --
  void _handleProductDetailsChange(SaleDataModel? data, bool? offline) {
    setState(() { 
      _saleDetails = data;
      _isOfflineDetails = offline;
    });
  }


  // -- -- --
  Future<void> _handleOrderResend(SaleDataModel sale) async {
    final SalesProvider salesProvider = Provider.of(context, listen: false);

    final order = OrderDataModel(
      sellerId: sale.sellerId, cashierId: sale.cashierId, customerId: null, 
      items: sale.items, orderCalculation: sale.orderCalculation, 
      orderPayments: sale.orderPayments, totalChange: sale.totalChange,
      createdAt: sale.createdAt
    );

    await salesProvider.sendOrder(order, resend: true, saleData: sale);
  }


  // -- -- --
  void _toggleShowPaymentOverview() {
    setState(() => _showPaymentsOverview = !_showPaymentsOverview);
  }


  double _calculatePaymentTotal(String paymentId) {
    final SalesProvider salesProvider = Provider.of(context, listen: false);
    final orderList = salesProvider.salesList;
    double total = 0;
    for (var order in orderList) {
      for (var payment in order.orderPayments) { 
        if (payment.paymentId != paymentId) continue; 
        total += payment.paidAmount;
      }
    }
    return total;
  }



  // --- --- ---
  // Future<void> _handleOrderDelete(SaleDataModel sale) async {
  //   final ProductsProvider productsProvider = Provider.of(context, listen: false);
    
  //   final order = OrderDataModel(
  //     sellerId: sale.sellerId, cashierId: sale.cashierId, customerId: null, 
  //     items: sale.items, orderCalculation: sale.orderCalculation, 
  //     orderPayments: sale.orderPayments, totalChange: sale.totalChange
  //   );

  //   await 
  // }


  
  // 
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final AppInfoProvider appInfoProvider = Provider.of(context, listen: false);
    if (appInfoProvider.currentUser == null) {
      await appInfoProvider.userLogout();
      if (!mounted) return;
      CHelperFunctions.navigateToScreen(context: context, screen: LoginScreen(), replacement: true);
    }
    setState(() => _userData = appInfoProvider.currentUser!);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
          // - - - - - -
          // - - - M A I N _ C O N T A I N E R
          // - - - - - -

          Container(
            padding: EdgeInsets.symmetric(horizontal: CSizes.largeGap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: CSizes.largeGap,),
                
                // - - - P A G E _ T I T L E
                UiTitleWidget(text: 'Sales History', bigger: true,),
      
                SizedBox(height: CSizes.largeGap,),
      
                // - - - T O G G L E _ S E C T I O N
                Consumer<SalesProvider>(
                  builder: (context, provider, child) => _toggleBetweenOrderTypesMethod(
                    isOffline: provider.showOfflineOrders,
                    offlineCount: provider.offlineSalesList.length,
                    salesDate: provider.salesDate,
                    onToggleClick: (showOffline) => provider.toggleShowOfflineOrders(showOffline),
                    onRefreshClick: provider.fetchOnlineSales,
                    onShowPaymentsOverviewClick: _toggleShowPaymentOverview,
                    onDateClick: () => _showDatePicker(provider.salesDate),
                  ),
                ),
      
                SizedBox(height: CSizes.largeGap,),
      
      
                // - - - M A I N _ D I S P L A Y
                Expanded(
                  child: Consumer<SalesProvider>(
                    builder: (context, provider, child) {
                      
                      // - - - O F F L I N E
                      if (provider.showOfflineOrders) {
                        // Empty offline orders
                        if (provider.offlineSalesList.isEmpty) return UiNoDataFounded(title: 'offline orders will be displayed here',);

                        // Display offline orders
                        return SingleChildScrollView(
                          child: SalesListDisplayWidget(
                            salesList: provider.offlineSalesList,
                            onSeeDetailsClick: (sale) => _handleProductDetailsChange(sale, true),
                            isOffline: true,
                            onSendAgainClick: (sale) => _handleOrderResend(sale),
                            canDelete: _userData.canEditInventory && _userData.userRole == UserRolesEnum.admin.name,
                            onDeleteClick: (sale) => provider.removeFromOfflineList(sale),
                          ),
                        );  
                      } 
                      


                      
                      // - - - O N L I N E
                      else {
                        // Loading
                        if (provider.isLoading) return UiLoadingScreenWidget(fullScreen: true);

                        // Error
                        if (provider.errorMessage != null) {
                          return UiNoDataFounded(
                            title: provider.errorMessage,
                            buttonText: 'search again',
                            onButtonClick: provider.fetchOnlineSales,
                          );
                        }

                        // Empty online orders
                        if (provider.salesList.isEmpty) {
                          return UiNoDataFounded(
                            title: 'no sales are founded',
                            buttonText: 'search again',
                            onButtonClick: provider.fetchOnlineSales,
                          );
                        }
                        
                        // Display Online orders
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              // Sales Overview
                              SalesOverviewWidget(
                                totalOrders: provider.salesList.length, 
                                totalSales: provider.totalSales, 
                                totalChange: provider.totalChange
                              ),

                              SizedBox(height: CSizes.largeGap,),

                              // Sales List
                              SalesListDisplayWidget(
                                salesList: provider.salesList, 
                                onSeeDetailsClick: (sale) => _handleProductDetailsChange(sale, false)
                              )
                            ],
                          ),
                        );  
                      }

                    },
                  ),
                ),
      
                SizedBox(height: CSizes.largeGap,),
                
              ],
            ),
          ),




          // - - - P A Y M E N T S _ O V E R V I E W
          if (_showPaymentsOverview) ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: CSizes.blurSigma, sigmaY: CSizes.blurSigma),
              child: GestureDetector(
                onTap: _toggleShowPaymentOverview,
                child: Container(
                  decoration: BoxDecoration(
                    color: CColors.dimmedBackgound,
                    borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                  ),
                  padding: EdgeInsets.all(CSizes.largeGap),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [                                                
                      Center(
                        child: Consumer<PaymentMethodsProvider>(
                          builder: (context, provider, child) {
                            return _paymentsOverviewMethod(
                              paymentList: provider.paymentMethods,
                              onCancel: _toggleShowPaymentOverview
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            )
          ),




          // - - - - - -
          // - - - S A L E _ D E T A I L S _ P O P U P
          // - - - - - -

          if (_saleDetails != null) Scaffold(
            backgroundColor: CColors.transparent,
            body: SaleDetailsPopupWidget(
              saleData: _saleDetails!,
              isOffline: _isOfflineDetails ?? true,
              onBackClick: () => _handleProductDetailsChange(null, null),
              onSendAgainClick: (sale) {
                _handleProductDetailsChange(null, null);
                _handleOrderResend(sale);
              }
            ),
          ),




          
          // - - - - - -
          // - - - R E S E N D
          // - - - - - -

          Consumer<SalesProvider>(
            builder: (context, provider, child) {
              // Loading
              if (provider.sendIsLoading) { 
                return UiLoadingScreenWidget(
                  fullScreen: true,
                  transparent: true,
                );
              }

              // Success
              if (provider.sendSuccessMessage != null) {
                return UiPopupWidget(
                  isSuccess: true,
                  message: provider.sendSuccessMessage!, 
                  primaryText: 'okay', 
                  primaryClick: provider.clearSendMessage, 
                  outSideClick: provider.clearSendMessage,
                );
              }
              
              // Error
              if (provider.sendErrorMessage != null) {
                return UiPopupWidget(
                  message: provider.sendErrorMessage!, 
                  primaryText: 'try again later', 
                  primaryClick: provider.clearSendMessage, 
                  outSideClick: provider.clearSendMessage,
                );
              }

              return SizedBox();
            },
          )

        ],
      ),
    );
  }





  // - - - - - -
  // - - - M E T H O D S
  // - - - - - -




  // - - - 
  Row _toggleBetweenOrderTypesMethod({
    required bool isOffline,
    required int offlineCount,
    required DateTime salesDate,
    required void Function(bool showOffline) onToggleClick,
    required void Function() onRefreshClick,
    required void Function() onShowPaymentsOverviewClick,
    required void Function() onDateClick,
  }) {
    final bool isToday = _dateIsToday(salesDate);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        
        Row(
          children: [
            UiButtonWidget(
              text: 'online sales',
              tranparent: isOffline,
              vericalPadding: CSizes.smallGap,
              onClick: () => onToggleClick(false)
            ),

            SizedBox(width: CSizes.mediumGap,),

            Stack(
              alignment: AlignmentGeometry.center,
              clipBehavior: Clip.none,
              children: [
                UiButtonWidget(
                  text: "offline orders",
                  tranparent: !isOffline,
                  vericalPadding: CSizes.smallGap,
                  onClick: () => onToggleClick(true)
                ),
                if (offlineCount > 0) Positioned(
                  top: -10,
                  right: -5,
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: CColors.red,
                      borderRadius: BorderRadius.circular(12.5)
                    ),
                    child: Center(
                      child: Text(
                        '$offlineCount'.padLeft(2, '0'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: CColors.white
                        ),
                      )
                    ),
                  ),
                ),


              ],
            ),
            
            SizedBox(width: CSizes.mediumGap,),

            if (!isOffline) UiButtonWidget(
              icon: CIcons.refreshIcon,
              tranparent: true,
              horizontalPadding: CSizes.smallGap,
              vericalPadding: CSizes.smallGap,
              onClick: onRefreshClick,
            ),

            SizedBox(width: CSizes.mediumGap,),

            if (!isOffline) Row(
              children: [
                UiButtonWidget(
                  icon: CIcons.walletIcon,
                  tranparent: true,
                  horizontalPadding: CSizes.smallGap,
                  vericalPadding: CSizes.smallGap,
                  onClick: onShowPaymentsOverviewClick,
                ),
        
                SizedBox(width: CSizes.mediumGap,),
              ],
            ),
          ],
        ),

        SizedBox(width: CSizes.mediumGap,),

        if (!isOffline) Row(
          children: [
            UiButtonWidget(
              icon: CIcons.calendar,
              text: CHelperFunctions.formatDateTime(salesDate),
              tranparent: !isToday,
              vericalPadding: CSizes.smallGap,
              onClick: onDateClick
            ),

            SizedBox(width: CSizes.mediumGap,),

            if (!isToday) UiButtonWidget(
              text: 'today',
              vericalPadding: CSizes.smallGap,
              onClick: () => _handleDateChange(DateTime.now())
            )
          ],
        ),

        
      ],
    );
  }



  // - - - P A Y M E N T S _ O V E R V I E W _ M E T H O D
  GestureDetector _paymentsOverviewMethod({
    required List<PaymentMethodModel> paymentList,
    required void Function() onCancel
  }) {
    return GestureDetector(
      onTap: () {},
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 600),
        child: Container(
          decoration: BoxDecoration(
            color: CColors.white,
            borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
          ),
          padding: EdgeInsets.all(CSizes.largeGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UiTitleWidget(
                text: 'payments overview',
                bigger: true,
                capitalizeWords: true,
                textAlign: TextAlign.center,
              ),
          
              SizedBox(height: CSizes.largeGap,),
      
              ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) { 
                  final amount = _calculatePaymentTotal(paymentList[index].paymentId);
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: CSizes.largeGap,
                      vertical: CSizes.mediumGap
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        UiTitleWidget(
                          text: paymentList[index].paymentName,
                          bold: false,
                        ),
                    
                        SizedBox(width: CSizes.largeGap,),
                        
                        UiTitleWidget(
                          text: '${CHelperFunctions.formatNumberWithComma(amount, addDecimal: amount == 0)} Birr',
                          defaultText: true,
                          color: amount > 0 ? null : CColors.whiteShade2,
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => Container(height: 1, color: CColors.whiteShade2,),
                itemCount: paymentList.length,
              ),
      
              SizedBox(height: CSizes.largeGap,),
      
              UiButtonWidget(
                text: 'back',
                onClick: onCancel,
              )
      
            ],
          ),
        ),
      ),
    );
  }

}