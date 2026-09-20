import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/order_calculation_model.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class UiOrderCalculationSummaryWidget extends StatelessWidget {
  final OrderCalculationModel orderCalculation;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? color;
  final Color? dividercolor;
  final String? title;
  final double? amountPaid;
  final bool showTotalPaid;
  const UiOrderCalculationSummaryWidget({
    super.key,
    required this.orderCalculation,
    this.backgroundColor,
    this.titleColor,
    this.color,
    this.dividercolor,
    this.title,
    this.amountPaid,
    this.showTotalPaid = false
  });

  @override
  Widget build(BuildContext context) {
    // final productsProvider = Provider.of<ProductsProvider>(context);
    // final OrderCalculationModel? orderCalculation = productsProvider.activeSessionCalc;

    return Container(
      // decoration: BoxDecoration(
      //   color: backgroundColor ?? CColors.white,
      //   borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
      // ),
      // padding: EdgeInsets.all(CSizes.largeGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (title != null) UiTitleWidget(
            text: title!,
            // centerText: true,
            textAlign: TextAlign.center,
            bigger: true,
            color: color,
          ),
          
          Column(
            children: [

              // - - - S U B T O T A L
              orderSummaryInfo(
                title: 'subtotal', 
                value: orderCalculation.subtotal,
                valueColor: color,
                titleColor: titleColor
              ),
                
              SizedBox(height: CSizes.smallGap,),
                
              
              // - - - D I S C O U N T
              orderSummaryInfo(
                title: 'discount', 
                value: orderCalculation.discount,
                valueColor: color,
                titleColor: titleColor
              ),
                
              SizedBox(height: CSizes.smallGap,),
                
              
              // - - - T A X A B L E
              if(orderCalculation.taxable > 0 && orderCalculation.subtotal != orderCalculation.taxable) Column(
                children: [
                  Container(
                    height: 1,
                    color: dividercolor ?? CColors.whiteShade2,
                    margin: EdgeInsets.symmetric(vertical: CSizes.smallGap),
                  ),

                  orderSummaryInfo(
                    title: 'taxable', 
                    value: orderCalculation.taxable,
                    valueColor: color,
                    titleColor: titleColor
                  ),

                  SizedBox(height: CSizes.smallGap,),
                ],
              ),
                
              
              // - - - V A T
              orderSummaryInfo(
                title: 'tax', 
                value: orderCalculation.vat,
                valueColor: color,
                titleColor: titleColor
              ),
                
              Container(
                height: 1,
                color: dividercolor ?? CColors.whiteShade2,
                margin: EdgeInsets.symmetric(vertical: CSizes.mediumGap),
              ),
            ],
          ),
            
          
          // - - - G R A N D _ T O T A L
          orderSummaryInfo(
            title: 'Total', 
            value: orderCalculation.grandTotal, 
            boldValue: true, 
            boldTitle: true, 
            titleColor: CColors.black, 
            biggerValue: true, 
            biggerTitle: true
          ),


          // - - - P A Y M E N T _ I N F O
          if (amountPaid != null) Column(
            children: [
              Container(
                height: 1,
                color: CColors.whiteShade2,
                margin: EdgeInsets.symmetric(vertical: CSizes.mediumGap),
              ),

              if (showTotalPaid) orderSummaryInfo(title: 'paid amount', value: amountPaid!),
              
              if (!showTotalPaid) orderSummaryInfo(title: 'remaining', value: amountPaid! < orderCalculation.grandTotal ? orderCalculation.grandTotal - amountPaid! : 0 ),

              SizedBox(height: CSizes.smallGap,),

              orderSummaryInfo(title: 'change', value: amountPaid! > orderCalculation.grandTotal ? amountPaid! - orderCalculation.grandTotal : 0),
            ],
          )
        ],
      ),
    );
  }

  Row orderSummaryInfo({ 
    required String title,
    required num value,
    bool boldTitle = false,
    bool boldValue = false,
    Color? titleColor,
    Color? valueColor,
    bool biggerTitle = false,
    bool biggerValue = false,
   }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        UiTitleWidget(
          text: title, 
          bold: boldTitle, 
          color: titleColor ?? CColors.blackShade3,
          bigger: biggerTitle,
        ),

        SizedBox(width: CSizes.mediumGap,),

        Expanded(
          child: UiTitleWidget(
            text: '${CHelperFunctions.formatNumberWithComma(value, addDecimal: false)} Birr', 
            capitalizeWords: true, 
            bold: boldValue,
            color: valueColor,
            bigger: biggerValue,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}