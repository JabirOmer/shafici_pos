import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class UiDeleteOrderWidget extends StatelessWidget {
  final String orderIndex;
  final String sellerName;
  final String grandTotal;
  final void Function() onCancelClick;
  final void Function() onDeleteClick;

  const UiDeleteOrderWidget({
    super.key,
    required this.orderIndex,
    required this.sellerName,
    required this.grandTotal,
    required this.onCancelClick,
    required this.onDeleteClick,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: CSizes.blurSigma,
          sigmaY: CSizes.blurSigma
        ),
        child: GestureDetector(
          onTap: onCancelClick,
          child: Container(
            width: double.maxFinite,
            color: CColors.dimmedBackgound,
            padding: EdgeInsets.all(CSizes.largeGap),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                GestureDetector(
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
                        children: [
                      
                          // - - - I C O N
                          SvgPicture.asset(
                            CIcons.warningIcon,
                            height: 64,
                            colorFilter: ColorFilter.mode(CColors.red, BlendMode.srcIn),
                          ),
                      
                          SizedBox(height: CSizes.largeGap,),
                      
                      
                          // - - - I N F O
                          Container(
                            decoration: BoxDecoration(
                              color: CColors.whiteShade1,
                              borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                            ),
                            padding: EdgeInsets.all(CSizes.mediumGap),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                UiTitleWidget(
                                  text: 'Order number:',
                                  color: CColors.whiteShade3,
                                  capitalizeWords: true,
                                  bold: false,
                                ),
                      
                                UiTitleWidget(
                                  text: orderIndex
                                )
                              ],
                            ),
                          ),
                      
                          SizedBox(height: CSizes.smallGap,),
                      
                          Container(
                            decoration: BoxDecoration(
                              color: CColors.whiteShade1,
                              borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                            ),
                            padding: EdgeInsets.all(CSizes.mediumGap),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                UiTitleWidget(
                                  text: 'Seller:',
                                  color: CColors.whiteShade3,
                                  bold: false,
                                ),
                      
                                UiTitleWidget(
                                  text: sellerName,
                                  capitalizeWords: true,
                                )
                              ],
                            ),
                          ),
                      
                      
                          SizedBox(height: CSizes.smallGap,),
                      
                      
                          Container(
                            decoration: BoxDecoration(
                              color: CColors.whiteShade1,
                              borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                            ),
                            padding: EdgeInsets.all(CSizes.mediumGap),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                UiTitleWidget(
                                  text: 'grand total:',
                                  color: CColors.whiteShade3,
                                  capitalizeWords: true,
                                  bold: false,
                                ),
                      
                                UiTitleWidget(
                                  text: grandTotal,
                                  capitalizeWords: true,
                                )
                              ],
                            ),
                          ),
                      
                          SizedBox(height: CSizes.largeGap,),
                      
                          // - - - B U T T O N S
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                      
                              Expanded(
                                child: UiButtonWidget(
                                  text: 'back',
                                  tranparent: true,
                                  onClick: onCancelClick
                                ),
                              ),
                      
                              SizedBox(width: CSizes.mediumGap,),
                      
                              Expanded(
                                child: UiButtonWidget(
                                  text: 'delete',
                                  backgroundColor: CColors.red,
                                  color: CColors.white,
                                  onClick: onDeleteClick
                                ),
                              )
                            ],
                          )
                      
                        ]
                      ),
                    ),
                  ),
                ),
              ],
            )
          )
        )
      )
    );
  }
}