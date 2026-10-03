import 'package:flutter/material.dart';

class CShadows {
  CShadows._();

  static List<BoxShadow> shadow1 = [
    BoxShadow( color: Color.fromRGBO(0, 0, 0, 0.1), blurRadius: 15, spreadRadius: -3, offset: Offset(0, 10), ),
    BoxShadow( color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 6, spreadRadius: -2, offset: Offset(0, 4), )
  ];

  static List<BoxShadow> shadow2 = [
    BoxShadow( color: Color.fromRGBO(0, 0, 0, 0.1), blurRadius: 25, spreadRadius: -5, offset: Offset(0, 20), ),
    BoxShadow( color: Color.fromRGBO(0, 0, 0, 0.04), blurRadius: 10, spreadRadius: -5, offset: Offset(0, 10), )
  ];


}