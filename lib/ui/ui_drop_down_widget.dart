import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class UiDropDownWidget extends StatelessWidget {
  final String? value;
  final String hint;
  final Map<String, String> items;
  final bool openDropDown;
  final void Function() dropDownClick;
  final void Function(String key) optionClick;

  const UiDropDownWidget({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.openDropDown,
    required this.dropDownClick,
    required this.optionClick,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        GestureDetector(
          onTap: dropDownClick,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(CSizes.smallRadius + 20),
              border: Border.all(width: 1, color: openDropDown ? CColors.primaryColor : CColors.whiteShade2)
            ),
            padding: EdgeInsets.only(
              left: CSizes.mediumGap,
              right: CSizes.mediumGap - 4
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                UiTitleWidget(
                  text: value ?? hint,
                  bold: false,
                  color: value == null ? CColors.red : CColors.black,
                  capitalizeWords: true,
                ),

                SvgPicture.asset(
                  openDropDown ? CIcons.arrowToUp : CIcons.arrowToDown,
                  colorFilter: ColorFilter.mode(CColors.whiteShade3, BlendMode.srcIn),
                )
              ],
            )
          ),
        ),
        
        // - - - I T E M S _ L I S T
        if (openDropDown) SizedBox(height: CSizes.smallGap,),

        if (openDropDown) LimitedBox(
          maxHeight: 250,
          child: items.isEmpty ? Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: CColors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
            ),
            padding: EdgeInsets.all(CSizes.mediumGap),
            child: UiTitleWidget(text: 'no options are founded', textAlign: TextAlign.center, bold: false,),
          ) 
          
          : Container(
            decoration: BoxDecoration(
              color: CColors.whiteShade1,
              borderRadius: BorderRadiusGeometry.circular(CSizes.mediumRadius),
              border: Border.all(width: 1, color: CColors.whiteShade2)
            ),
            clipBehavior: Clip.hardEdge,
            child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final entry = items.entries.elementAt(index);
                return GestureDetector(
                  onTap: () => optionClick(entry.key),
                  child: Container(
                    color: CColors.transparent,
                    padding: EdgeInsets.all(CSizes.mediumGap),
                    child: UiTitleWidget(text: '- ${entry.value}', bold: false, capitalizeWords: true,),
                  ),
                );
              }, 
              separatorBuilder: (context, index) => Container(height: 1, color: CColors.whiteShade2,), 
              itemCount: items.length,
            ),
          ),
        ),
        
        // if (openDropDown && items.isEmpty)Container(
        //   padding: EdgeInsets.all(CSizes.smallGap),
        //   child: UiTitleWidget(text: 'no options are founded', textAlign: TextAlign.center,),
        // )
      ],
    );
  }
}