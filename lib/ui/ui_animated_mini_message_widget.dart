import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';

class UiAnimatedMiniMessageWidget extends StatelessWidget {
  final String? displayText;
  final bool isSuccess;
  final bool isNeutral;
  const UiAnimatedMiniMessageWidget({
    super.key,
    required this.displayText,
    this.isSuccess = false,
    this.isNeutral = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      height: displayText != null ? 40 : 0,
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: isNeutral ? CColors.whiteShade1 : (isSuccess ? CColors.green : CColors.red),
        borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
      ),
      padding: EdgeInsets.symmetric(horizontal: CSizes.mediumGap),
      margin: EdgeInsets.only(top: displayText != null ? CSizes.largeGap : 0),
      child: Center(
        child: Text(
          CHelperFunctions.capitalize(displayText ?? ''),
          style: TextStyle(
            color: isNeutral ? CColors.whiteShade3 : CColors.white
          ),
        ),
      ),
    );
  }
}