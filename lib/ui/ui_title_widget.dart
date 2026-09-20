import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';

class UiTitleWidget extends StatelessWidget {
  final String text;
  final bool defaultText;
  final bool bold;
  final bool bigger;
  final bool medium;
  final double? customSize;
  final TextAlign textAlign;
  final bool capitalizeWords;
  final int maxLine;
  final Color? color;

  const UiTitleWidget({
    super.key,
    required this.text,
    this.defaultText = false,
    this.bold = true,
    this.bigger = false,
    this.medium = false,
    this.customSize,
    this.textAlign = TextAlign.start,
    this.capitalizeWords = false,
    this.maxLine = 1,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      defaultText ? text : capitalizeWords ? CHelperFunctions.capitalizeWords(text) : CHelperFunctions.capitalize(text),
      textAlign: textAlign,
      maxLines: maxLine,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: customSize ?? (bigger ? 24 : (medium ? 16 : null)),
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: color ?? CColors.black
      ),
    );
  }
}