import 'package:flutter/widgets.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class SalesOverviewWidget extends StatelessWidget {
  final int totalOrders;
  final double totalSales;
  final double totalChange;

  const SalesOverviewWidget({
    super.key,
    required this.totalOrders,
    required this.totalSales,
    required this.totalChange,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints( minWidth: constraints.maxWidth ),
            child: SizedBox(
              height: 100,
              child: IntrinsicWidth(
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  
                      // Total Orders
                      Expanded(
                        child: _salesOverviewCardMethod(
                          title: 'total orders',
                          value: totalOrders.toString().padLeft(2, '0'),
                          gradient: CColors.gradientGreen
                        ),
                      ),
                  
                      SizedBox(width: CSizes.largeGap,),
                  
                      // Total Sales 
                      Expanded(
                        child: _salesOverviewCardMethod(
                          title: 'sales',
                          value: '${CHelperFunctions.formatNumberWithComma(totalSales, addDecimal: true)} Birr',
                          gradient: CColors.gradientNavyBlue
                        ),
                      ),
                  
                      SizedBox(width: CSizes.largeGap,),
                  
                      // Total Change 
                      Expanded(
                        child: _salesOverviewCardMethod(
                          title: 'change',
                          value: '${CHelperFunctions.formatNumberWithComma(totalChange, addDecimal: true)} Birr',
                          gradient: CColors.gradientOrange
                        ),
                      ),
                  
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }




        // child: Container(
        //   color: CColors.red,
        //   child: SingleChildScrollView(
        //     scrollDirection: Axis.horizontal,
        //     child: IntrinsicWidth(
        //       child: IntrinsicHeight(
        //         child: SizedBox(
        //           height: 100,
        //           child: Row(
        //             crossAxisAlignment: CrossAxisAlignment.stretch,
        //             children: [
                      
        //               // Total Orders
        //               Expanded(
        //                 child: _salesOverviewCardMethod(
        //                   title: 'total orders',
        //                   value: totalOrders.toString().padLeft(2, '0'),
        //                   gradient: CColors.gradientGreen
        //                 ),
        //               ),
                  
        //               SizedBox(width: CSizes.mediumGap,),
                  
        //               // Total Sales 
        //               Expanded(
        //                 child: _salesOverviewCardMethod(
        //                   title: 'sales',
        //                   value: '${CHelperFunctions.formatNumberWithComma(totalSales, addDecimal: true)} Birr',
        //                   gradient: CColors.gradientNavyBlue
        //                 ),
        //               ),
                  
        //               SizedBox(width: CSizes.mediumGap,),
                  
        //               // Total Change 
        //               Expanded(
        //                 child: _salesOverviewCardMethod(
        //                   title: 'change',
        //                   value: '${CHelperFunctions.formatNumberWithComma(totalChange, addDecimal: true)} Birr',
        //                   gradient: CColors.gradientOrange
        //                 ),
        //               ),
                  
        //               // SizedBox(width: CSizes.largeGap,),
                  
        //               // if (currentUser.userRole == UserRolesEnum.admin.name) Row(
        //               //   children: [
        //               //     // Total cost
        //               //     salesOverviewCardMethod(
        //               //       title: 'cost',
        //               //       value: '${CHelperFunctions.formatNumberWithComma(totalCost, addDecimal: true)} Birr',
        //               //       gradient: CColors.gradientRed
        //               //     ),
                      
        //               //     SizedBox(width: CSizes.largeGap,),
                      
        //               //     // Total cost
        //               //     salesOverviewCardMethod(
        //               //       title: 'profit',
        //               //       value: '${CHelperFunctions.formatNumberWithComma(totalProfit, addDecimal: true)} Birr',
        //               //       gradient: CColors.gradientGreen
        //               //     ),
        //               //   ],
        //               // )
                  
        //             ],
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),

  // - - - S A L E S _ O V E R V I E W _ C A R D _ M E T H O D
  Container _salesOverviewCardMethod({ 
    required String title, 
    required String value,
    Gradient? gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        border: Border.all(width: 1, color: CColors.whiteShade2),
        borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
      ),
      padding: EdgeInsets.symmetric(vertical: CSizes.largeGap, horizontal: CSizes.xLargeGap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          UiTitleWidget(
            text: title,
            capitalizeWords: true,
            bigger: true,
            color: CColors.white,
          ),

          SizedBox(width: CSizes.largeGap,),
          
          UiTitleWidget(
            text: value,
            bigger: true,
            defaultText: true,
            color: CColors.white,
          ),
        ],
      ),
    );
  }
}