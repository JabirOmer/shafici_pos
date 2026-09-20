import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/order_item_model.dart';
import 'package:shafici_pos/models/order_payment_model.dart';
import 'package:shafici_pos/models/sale_data_model.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_order_calculation_summary_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class SaleDetailsPopupWidget extends StatelessWidget {
  final SaleDataModel saleData;
  final bool isOffline;
  final void Function(SaleDataModel sale)? onSendAgainClick;
  final void Function() onBackClick;

  const SaleDetailsPopupWidget({
    super.key,
    required this.saleData,
    this.isOffline = false,
    this.onSendAgainClick,
    required this.onBackClick,
  });

  @override
  Widget build(BuildContext context) {
    
    double getAmountPaid() {
      double total = 0;
      for (var payment in saleData.orderPayments) { total += payment.paidAmount; }
      return total;
    }

    return Scaffold(
      backgroundColor: CColors.dimmedBackgound,
      body: GestureDetector(
        onTap: onBackClick,
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: CSizes.blurSigma, sigmaY: CSizes.blurSigma),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints( minHeight: MediaQuery.of(context).size.height ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                
                    Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 800
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: CColors.whiteShade1,
                              borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                            ),
                            padding: EdgeInsets.all(CSizes.largeGap),
                            margin: EdgeInsets.all(CSizes.largeGap),
                            child: Column(
                              children: [
                                
                                // - - - B A S I C _ I N F O
                                Container(
                                  decoration: BoxDecoration(
                                    color: CColors.white,
                                    borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                                  ),
                                  padding: EdgeInsets.all(CSizes.mediumGap),
                                  child: _basicInfoMethod(
                                    cashierName: saleData.cashierName,
                                    sellerName: saleData.sellerName,
                                    isOffline: isOffline,
                                    createdAt: saleData.createdAt
                                  ),
                                ),
                                
                                SizedBox(height: CSizes.largeGap,),
                                
                                // - - - I T M E S
                                Container(
                                  color: CColors.white,
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) => _itemDisplayTileWidget(index, saleData.items[index]), 
                                    separatorBuilder: (context, index) => Container(height: 1, color: CColors.whiteShade2,), 
                                    itemCount: saleData.items.length
                                  ),
                                ),

                                SizedBox(height: CSizes.largeGap,),

                                // - - - O R D E R _ C A L C U L A T I O N
                                UiOrderCalculationSummaryWidget(
                                  orderCalculation: saleData.orderCalculation,
                                  amountPaid: getAmountPaid(),
                                  showTotalPaid: true,
                                ),

                                SizedBox(height: CSizes.largeGap,),

                                // - - - P A Y M E N T S
                                Container(
                                  color: CColors.white,
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) => _paymentDisplayTileWidget(index, saleData.orderPayments[index]), 
                                    separatorBuilder: (context, index) => Container(height: 1, color: CColors.whiteShade2,), 
                                    itemCount: saleData.orderPayments.length
                                  ),
                                ),
                                
                                SizedBox(height: CSizes.largeGap,),

                                Row(
                                  children: [
                                    Expanded(
                                      child: UiButtonWidget(
                                        text: 'back',
                                        tranparent: isOffline,
                                        onClick: onBackClick
                                      )
                                    ),

                                    if (isOffline && onSendAgainClick != null) SizedBox(width: CSizes.largeGap,),

                                    if (isOffline && onSendAgainClick != null) Expanded(
                                      child: UiButtonWidget(
                                        text: 'send again',
                                        icon: CIcons.sendIcon,
                                        onClick: () => onSendAgainClick!(saleData),
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
                
                  ],
                ),
              ),
            )
          ),
        ),
      ),
    );
  }





  // - - - - - -
  // - - - M E T H O D S
  // - - - - - -





  // - - - B A S I C _ I N F O _ M E T H O D
  Row _basicInfoMethod({ 
    required String cashierName,
    required String sellerName,
    bool isOffline = false,
    required DateTime createdAt
   }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
    
        Row(
          children: [
            UiTitleWidget(text: 'Cashier: ', bold: false,),
            UiTitleWidget(text: cashierName, capitalizeWords: true, bold: false,),
          ],
        ),
    
    
        Row(
          children: [
            UiTitleWidget(text: CHelperFunctions.formatDateTime(createdAt, addTime: true), defaultText: true, bold: false,),
        
            SizedBox(width: CSizes.mediumGap,),
        
            // Container(
            //   decoration: BoxDecoration(
            //     color: isOffline ? CColors.deepOrange.withAlpha(50) : CColors.green.withAlpha(50),
            //     borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
            //   ),
            //   padding: EdgeInsets.symmetric(horizontal: CSizes.mediumGap, vertical: 4),
            //   child: UiTitleWidget(
            //     // text: isOffline ? 'Pending' : 'Done', 
            //     text: '',
            //     capitalizeWords: true, 
            //     customSize: 10,
            //     color: isOffline ? CColors.deepOrange : CColors.green,
            //     textAlign: TextAlign.center,
            //   )
            // ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isOffline ? CColors.deepOrange : CColors.green,
              ),
            )
          ],
        )
    
      ],
    );
  }





  // - - - I T E M _ D I S P L A Y _ T I L E _ M E T H O D
  Container _itemDisplayTileWidget(int index, OrderItemModel item) {
    return Container(
      padding: EdgeInsets.all(CSizes.mediumGap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Row(
            children: [
              SizedBox(
                width: 25,
                child: UiTitleWidget(text: (index+1).toString().padLeft(2, '0'), bold: false, color: CColors.black,),
              ),

              SizedBox(width: CSizes.smallGap,),

              UiTitleWidget(text: item.productName, bold: false,),
            ],
          ),

          SizedBox(width: CSizes.smallGap,),

          Row(
            children: [
              UiTitleWidget(text: item.quantity.toString().padLeft(2, '0'), bold: false,),
              UiTitleWidget(text: '  x  ', bold: false,),
              UiTitleWidget(text: '${CHelperFunctions.formatNumberWithComma(item.unitSoldAt)} birr', bold: false, capitalizeWords: true,)
            ],
          )

        ],
      ),
    );
  }





  // - - - P A Y M E N T _ D I S P L A Y _ T I L E _ M E T H O D
  Container _paymentDisplayTileWidget(int index, OrderPaymentModel payment) {
    return Container(
      padding: EdgeInsets.all(CSizes.mediumGap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 25,
                child: UiTitleWidget(text: (index+1).toString().padLeft(2, '0'), bold: false, color: CColors.black,),
              ),

              SizedBox(width: CSizes.smallGap,),

              UiTitleWidget(text: payment.paymentName, bold: false,),
            ],
          ),

          SizedBox(width: CSizes.smallGap,),

          Row(
            children: [
              UiTitleWidget(text: '${CHelperFunctions.formatNumberWithComma(payment.paidAmount)} birr', bold: false, capitalizeWords: true,)
            ],
          )
        ],
      ),      
    );
  }

}