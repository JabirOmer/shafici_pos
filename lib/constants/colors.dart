import 'package:flutter/material.dart';

// final 

class CColors {
  CColors._();

  // static Color primaryColor = Color(0xFF00565E);
  static Color primaryColor = Color(0xFF003338);
  // static Color primaryColor = Color.fromARGB(255, 0, 0, 0);
  // static Color primaryColor = Color.fromARGB(255, 211, 0, 88);
  // static Color primaryColor = Color(0xFF613dc1);
  // static Color primaryColor = Color.fromARGB(255, 0, 0, 0);

  // static Color primaryColor = Color.fromARGB(255, 176, 85, 1);
  // static Color primaryColor = Color(0xFF240046);
  
  // - - - W H I T E _ S H A D E S
  static Color white = Color(0xFFFFFFFF);
  static Color whiteShade1 = Color(0xFFF7F7F7);
  static Color whiteShade2 = Color(0xFFD3D3D3);
  static Color whiteShade3 = Color.fromARGB(255, 109, 109, 109);

  // - - - W H I T E _ S H A D E S
  static Color black = Color(0xFF000000);
  static Color blackShade1 = Color(0xFF0B2545);
  static Color blackShade2 = Color(0xFF33415C);
  static Color blackShade3 = Color.fromARGB(255, 96, 96, 96);


  // - - - PURPLE
  static Color darkPurple = Color(0xFF240046);
  static Color deepPurple = Color(0xFF613dc1);
  static Color purpleShade1 = Color(0xFF4B0082);
  static Color purpleShade2 = Color(0xFFE0AAFF);

  static Color transparent = Color.fromARGB(0, 255, 255, 255);
  static Color dimmedBackgound = Color.fromARGB(150, 0, 0, 0);

  static Color deepOrange = Color(0xFFfb8b24);
  static Color red = Color(0xFFC1121F);
  static Color redDimmed = Color.fromARGB(255, 255, 149, 156);
  static Color green = Color(0xFF386641);

  // - - - O R D E R _ O V E R _ V I E W
  static LinearGradient redAndYellow = LinearGradient(colors: [ Color(0xFFFF2626), Color.fromARGB(255, 69, 0, 0) ]);
  static LinearGradient gradientGreen = LinearGradient(colors: [ Color(0xFF013F4A), Color(0xFF051F20) ]);
  static LinearGradient gradientRed = LinearGradient(colors: [ Color(0xFFEC3030), Color(0xFF6A0002) ]);
  static LinearGradient gradientOrange = LinearGradient(colors: [ Color(0xFFFF8800), Color.fromARGB(255, 206, 83, 0) ]);
  static LinearGradient gradientNavyBlue = LinearGradient(colors: [ Color(0xFF00498D), Color(0xFF000B18) ]);
  static LinearGradient gradientBlue = LinearGradient(colors: [ Color.fromARGB(255, 20, 107, 170), Color.fromARGB(255, 0, 32, 54) ]);
}
