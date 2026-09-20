import 'package:flutter/material.dart';

class CShadows {
  CShadows._();

  static List<BoxShadow> shadow1 = [
    BoxShadow( color: Color.fromRGBO(0, 0, 0, 0.1), blurRadius: 15, spreadRadius: -3, offset: Offset(0, 10), ),
    BoxShadow( color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 6, spreadRadius: -2, offset: Offset(0, 4), )
  ];


}