import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:shafici_pos/constants/animations.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class UiPopupWidget extends StatelessWidget {
  final String message;
  final bool defaultText;
  final String primaryText;
  final void Function() primaryClick;
  final String? secondaryText;
  final void Function()? secondaryClick;
  final bool isSuccess;
  final bool isDisabled;
  final bool isDimmed;
  final Color? iconColor;
  final void Function() outSideClick;

  const UiPopupWidget({
    super.key,
    required this.message,
    this.defaultText = false,
    required this.primaryText,
    required this.primaryClick,
    this.secondaryText,
    this.secondaryClick,
    this.isSuccess = false,
    this.isDimmed = true,
    this.isDisabled = false,
    this.iconColor,
    required this.outSideClick,
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
          onTap: isDisabled ? () {} : outSideClick,
          child: Container(
            width: double.maxFinite,
            color: isDimmed ? CColors.dimmedBackgound : CColors.whiteShade1,
            padding: EdgeInsets.all(CSizes.largeGap),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            
                GestureDetector(
                  onTap: () {},
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 400
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CColors.white,
                        borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                      ),
                      padding: EdgeInsets.all(CSizes.largeGap),
                      child: Column(
                        children: [

                          // - - - I C O N
                          SizedBox(
                            child: isSuccess ? Lottie.asset(
                              height: 96,
                              CAnimations.animation2,
                            ) : SvgPicture.asset(
                              height: 64,
                              CIcons.warningIcon,
                              colorFilter: ColorFilter.mode(iconColor ?? (isSuccess ? CColors.blackShade2 : CColors.red), BlendMode.srcIn),
                            ),
                          ),
                          
                          SizedBox(height: CSizes.xLargeGap,),
                          
                          // - - - T I T L E
                          UiTitleWidget(
                            text: message, 
                            defaultText: defaultText,
                            textAlign: TextAlign.center,
                            bold: false,
                            maxLine: 2,
                          ),
                          
                          SizedBox(height: CSizes.xLargeGap,),
                          
                          
                          // - - - B U T T O N S
                          Row(
                            children: [
                              if (secondaryText != null) Expanded(
                                child: UiButtonWidget(
                                  text: secondaryText!, 
                                  onClick: secondaryClick!,
                                  tranparent: true,
                                  isDisabled: isDisabled,
                                ),
                              ),
                          
                              if (secondaryText != null) SizedBox(width: CSizes.mediumGap,),
                          
                              Expanded(
                                child: UiButtonWidget(
                                  text: primaryText, 
                                  onClick: primaryClick,
                                  isDisabled: isDisabled,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}