import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/themes/textfield_theme.dart';
// import 'package:shafici_pos/constants/colors.dart';
// import 'package:shafici_pos/themes/textfield_theme.dart';

class CAppTheme {
  CAppTheme._();

  static ThemeData lightMode = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: CColors.whiteShade1,
    fontFamily: 'DMSans',
    inputDecorationTheme: CTextfieldTheme.lightMode,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: CColors.red,
      // selectionColor: Colors.red.withAlpha((0.3 * 255).round()),
      selectionColor: CColors.primaryColor.withValues(alpha: 0.3),
      selectionHandleColor: const Color.fromARGB(255, 243, 33, 229),
    ),
    appBarTheme: AppBarTheme(
      // backgroundColor: CColors.primaryColor.withValues(alpha: 0.1),
      backgroundColor: CColors.white,
      centerTitle: true,
      toolbarHeight: 80,
    ),
    // datePickerTheme: DatePickerThemeData(
            // colorScheme: ColorScheme.light(
            //   primary: CColors.primaryColor,
            //   onPrimary: CColors.white,
            //   onSurface: CColors.black
            // ),
            // textButtonTheme: TextButtonThemeData(
            //   style: TextButton.styleFrom(
            //     foregroundColor: Colors.red, // button text color
            //   ),
            // ),
    // )

    datePickerTheme: DatePickerThemeData(
      backgroundColor: Colors.white,
      headerBackgroundColor: Colors.teal,
      headerForegroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CSizes.largeRadius)),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return Colors.grey;
        if (states.contains(WidgetState.selected)) return Colors.white;
        return Colors.black;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.teal;
        return Colors.transparent;
      }),
    ),
  );
}