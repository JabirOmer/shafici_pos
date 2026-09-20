import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/animations.dart';
import 'package:shafici_pos/constants/colors.dart';
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
  final String? buttonText;
  final Color? backgroundColor;
  final void Function()? onButtonClick;

  const UiNoDataFounded({
    super.key,
    this.title,
    this.addAnimation = true,
    this.noRepeat = false,
    this.noDataAnimation,
    this.iconHeight,
    this.buttonText,
    this.onButtonClick,
    this.backgroundColor,
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
            padding: EdgeInsets.all(CSizes.xLargeGap),
            child: Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: backgroundColor ?? CColors.white,
                borderRadius: BorderRadius.circular(CSizes.smallRadius + 20),
              ),
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
            
                      UiButtonWidget(
                        text: buttonText ?? 'try again',
                        onClick: onButtonClick!,
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