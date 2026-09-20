import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/sizes.dart';

class UiAddCustomerPopupWidget extends StatefulWidget {
  const UiAddCustomerPopupWidget({super.key});

  @override
  State<UiAddCustomerPopupWidget> createState() => _UiAddCustomerPopupWidgetState();
}

class _UiAddCustomerPopupWidgetState extends State<UiAddCustomerPopupWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: CSizes.blurSigma, sigmaY: CSizes.blurSigma),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(CSizes.largeGap),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: Container(
                decoration: BoxDecoration(
                  color: CColors.white,
                  borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                ),
                padding: EdgeInsets.all(CSizes.largeGap),
                child: Text('add customer popup'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}