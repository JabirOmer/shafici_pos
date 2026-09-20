import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class RegisterProductPopupWidget extends StatefulWidget {
  final void Function() closePopup;
  const RegisterProductPopupWidget({
    super.key,
    required this.closePopup
  });

  @override
  State<RegisterProductPopupWidget> createState() => _RegisterProductPopupWidgetState();
}

class _RegisterProductPopupWidgetState extends State<RegisterProductPopupWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: CSizes.blurSigma, sigmaY: CSizes.blurSigma),
        child: Column(
          children: [

            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 900),
              child: Container(
                decoration: BoxDecoration(
                  color: CColors.white,
                  borderRadius: BorderRadius.circular(CSizes.smallRadius + 20),
                ),
                padding: EdgeInsets.all(CSizes.largeGap),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      UiTitleWidget(text: 'Register product', textAlign: TextAlign.center,),

                      SizedBox(height: CSizes.largeGap,),

                      UiTextFieldWidget(
                        label: 'product name',
                      )
                    ],
                  )
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}