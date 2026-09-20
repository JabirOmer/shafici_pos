import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/screens/app_layout_screens/app_layout_screen.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class ResponsiveAppLayoutScreen extends StatelessWidget {
  const ResponsiveAppLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < CSizes.mediumScreenWidth || constraints.maxHeight < 100) {
          return Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 500
                    ),
                    child: Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: CColors.white,
                        borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                      ),
                      padding: EdgeInsets.all(CSizes.largeGap),
                      margin: EdgeInsets.all(CSizes.largeGap),
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            CIcons.warningIcon,
                            height: 64,
                          ),
                    
                          SizedBox(height: CSizes.largeGap,),
                    
                          UiTitleWidget(
                            text: 'please use a wider display',
                            textAlign: TextAlign.center,
                            bold: false,
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        }

        else {
          return AppLayoutScreen();
        }
      },
    );
  }
}