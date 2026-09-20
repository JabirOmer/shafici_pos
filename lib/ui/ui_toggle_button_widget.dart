import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/sizes.dart';

class UiToggleButtonWidget extends StatelessWidget {
  final bool isOn;
  final void Function() onClick;
  final bool isDisabled;
  final bool isLoading;
  final bool smaller;
  const UiToggleButtonWidget({
    super.key,
    required this.isOn,
    required this.onClick,
    this.isDisabled = false,
    this.isLoading = false,
    this.smaller = true,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: (isDisabled || isLoading) ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: (isDisabled || isLoading) ? () {} : onClick,
        child: Container(
          width: smaller ? 48 : 60,
          height: smaller ? 21 : 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CSizes.mediumGap),
            color: isLoading ? CColors.whiteShade2 : (isOn ? CColors.primaryColor : CColors.redDimmed)
          ),
          padding: EdgeInsets.all(4),
          child: LayoutBuilder(
            builder: (context, constraints) =>  Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: smaller ? 24 : 30,
                    height: double.maxFinite,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isLoading ? CColors.whiteShade1 : CColors.white,
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


