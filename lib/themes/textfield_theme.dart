import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/sizes.dart';

class CTextfieldTheme {

  CTextfieldTheme._();

  static InputDecorationTheme lightMode = InputDecorationTheme(
    errorMaxLines: 2,

    hintStyle: const TextStyle().copyWith(fontSize: 14, color: CColors.blackShade3),
    
    labelStyle: const TextStyle().copyWith(color: CColors.blackShade3, fontSize: 12),

    floatingLabelStyle: const TextStyle().copyWith(color: CColors.black, fontSize: 16),
    
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(CSizes.smallRadius + 20),
      borderSide: BorderSide(width: 1, color: CColors.whiteShade2),
    ),

    disabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(CSizes.smallRadius + 20),
      borderSide: BorderSide(width: 1, color: CColors.whiteShade2),
    ),
    
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(CSizes.smallRadius + 20),
      borderSide: BorderSide(width: 1, color: CColors.blackShade1),
    ),
    
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(CSizes.smallRadius + 20),
      borderSide: BorderSide(width: 1, color: CColors.red),
    ),

    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(CSizes.smallRadius + 20),
      borderSide: BorderSide(width: 1, color: CColors.red),
    ),
  );

}