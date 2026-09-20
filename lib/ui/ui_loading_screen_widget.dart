import 'dart:ui';

import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:shafici_pos/constants/animations.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/sizes.dart';
// import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';
import 'package:lottie/lottie.dart';

class UiLoadingScreenWidget extends StatelessWidget {
  final bool fullScreen;
  final bool addText;
  final bool transparent;
  const UiLoadingScreenWidget({
    super.key,
    this.fullScreen = false,
    this.addText = true,
    this.transparent = false
  });

  @override
  Widget build(BuildContext context) {
    return fullScreen ? Scaffold(
      backgroundColor: transparent ? CColors.dimmedBackgound : null,
      body: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: CSizes.blurSigma, sigmaY: CSizes.blurSigma),
          child: Center(child: loadingMethod())
        ),
      ),
    ) : Center(child: loadingMethod());
  }



  // - - - M E T H O D S



  // Method_01
  ConstrainedBox loadingMethod() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 400
      ),
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(
          horizontal: CSizes.xLargeGap, vertical: CSizes.xLargeGap
        ),
        margin: EdgeInsets.all(CSizes.largeGap),
        decoration: BoxDecoration(
          color: CColors.white,
          borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              CAnimations.loadingRing,
              height: 100,
            ),
        
            UiTitleWidget(text: 'wait a moment ...', textAlign: TextAlign.center, bold: false,)
          ],
        ),
      ),
    );
  }
}