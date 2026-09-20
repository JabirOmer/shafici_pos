import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/shadows.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class UiButtonWidget extends StatelessWidget {
  final String? text;
  final String? icon;
  final bool defaultText;
  final bool isDisabled;
  final double? width;
  final double? height;
  final double? vericalPadding;
  final double? horizontalPadding;
  final void Function() onClick;
  final bool tranparent;
  final bool addShadow;
  final Color? color;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool biggerText;
  final bool biggerIcon;
  final void Function(LongPressStartDetails details)? onLongPressStart;
  final void Function(LongPressEndDetails details)? onLongPressEnd;
  final double? borderRaduis;

  const UiButtonWidget({
    super.key,
    this.text,
    this.icon,
    this.defaultText = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.vericalPadding,
    this.horizontalPadding,
    required this.onClick,
    this.tranparent = false,
    this.addShadow = false,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.biggerText = false,
    this.biggerIcon = false,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.borderRaduis
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = isDisabled ? CColors.whiteShade2 : backgroundColor ?? (tranparent ? CColors.transparent : CColors.primaryColor);

    return MouseRegion(
      cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: isDisabled ? () {} : onClick,
        onLongPressStart: isDisabled ? null : onLongPressStart,
        onLongPressEnd: onLongPressEnd,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isDisabled ? CColors.whiteShade2 : backgroundColor ?? (tranparent ? CColors.transparent : CColors.primaryColor),
            borderRadius: BorderRadius.circular(borderRaduis ?? CSizes.smallRadius + 20),
            border: Border.all(width: 1, color: borderColor ?? ((tranparent || isDisabled) ? CColors.whiteShade2 : color ?? buttonColor)),
            boxShadow: addShadow ? CShadows.shadow1 : null
          ),
          padding: EdgeInsets.symmetric(
            vertical: vericalPadding ?? CSizes.mediumGap,
            horizontal: horizontalPadding ?? CSizes.largeGap
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [

              // T E X T
              if (text != null) UiTitleWidget(
                text: text!,
                defaultText: defaultText,
                maxLine: 1,
                bold: false,
                textAlign: TextAlign.center,
                color: isDisabled ? CColors.blackShade3 : color ?? (tranparent ? CColors.blackShade1 : CColors.whiteShade1),
                bigger: biggerText,
              ),

              if (text != null && icon != null) SizedBox(width: CSizes.mediumGap,),


              // I C O N
              if (icon != null) SvgPicture.asset(
                icon!,
                height: biggerIcon ? 24 : 16,
                colorFilter: ColorFilter.mode(isDisabled ? CColors.blackShade3 : color ?? (tranparent ? CColors.black : CColors.whiteShade1), BlendMode.srcIn),
              )
            ],
          )
        ),
      ),
    );
  }
}