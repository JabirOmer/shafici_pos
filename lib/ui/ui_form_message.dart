import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class UiFormMessage extends StatelessWidget {
  final String? message;
  final bool isSuccess;
  final double? bottomMargin;

  const UiFormMessage({
    super.key,
    required this.message,
    this.isSuccess = false,
    this.bottomMargin,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSuccess ? CColors.green.withAlpha(30) :  CColors.red.withAlpha(30),
        borderRadius: BorderRadius.circular(CSizes.largeGap)
      ),
      height: message == null ? 0 : 46,
      padding: EdgeInsets.symmetric(horizontal: CSizes.mediumGap),
      margin: EdgeInsets.only(bottom: message == null ? 0 : (bottomMargin ?? CSizes.largeGap)),
      child: Center(
        child: UiTitleWidget(
          text: message ?? '',
          color: isSuccess ? CColors.green : CColors.red,
          textAlign: TextAlign.center,
          bold: false,
        ),
      ),
    );
  }
}