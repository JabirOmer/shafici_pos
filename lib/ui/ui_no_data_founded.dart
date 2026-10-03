import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/animations.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/shadows.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';
import 'package:lottie/lottie.dart';

class UiNoDataFounded extends StatelessWidget {
  final String? title;
  final bool addAnimation;
  final bool noRepeat;
  final String? noDataAnimation;
  final double? iconHeight;
  final Color? backgroundColor;
  
  final String? buttonText;
  final void Function()? onButtonClick;

  final String? secondaryText;
  final void Function()? onSecondaryBtnClick;

  const UiNoDataFounded({
    super.key,
    this.title,
    this.addAnimation = true,
    this.noRepeat = false,
    this.noDataAnimation,
    this.iconHeight,
    this.backgroundColor,

    this.buttonText,
    this.onButtonClick,

    this.secondaryText,
    this.onSecondaryBtnClick
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 600
          ),
          child: Padding(
            padding: EdgeInsets.all(0),
            child: Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: backgroundColor ?? CColors.white,
                boxShadow: CShadows.shadow1,
                border: Border.all(width: 1, color: CColors.whiteShade2),
                borderRadius: BorderRadius.circular(CSizes.smallRadius + 20),
              ),
              margin: EdgeInsets.all(CSizes.largeGap),
              padding: EdgeInsets.symmetric(
                horizontal: CSizes.xLargeGap,
                vertical: CSizes.xLargeGap
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (addAnimation) Column(
                    children: [
                      Lottie.asset(
                        noDataAnimation ?? CAnimations.emptyList,
                        height: iconHeight ?? 128,
                        repeat: !noRepeat
                      ),
        
                      SizedBox(height: CSizes.largeGap,)
                    ],
                  ),
        
                  // - - - T E X T
                  UiTitleWidget(
                    text: title ?? 'no data is founded!',
                    bold: false,
                    maxLine: 3,
                    textAlign: TextAlign.center,
                  ),
            
                  if (onButtonClick != null) Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: CSizes.largeGap,),
            
                      Row(
                        children: [

                          if (onSecondaryBtnClick != null) Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: CSizes.mediumGap),
                              child: UiButtonWidget(
                                tranparent: true,
                                text: secondaryText ?? 'cancel',
                                onClick: onSecondaryBtnClick!,
                              ),
                            ),
                          ),

                          Expanded(
                            child: UiButtonWidget(
                              text: buttonText ?? 'search again',
                              onClick: onButtonClick!,
                            ),
                          ),

                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}