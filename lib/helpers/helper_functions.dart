import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:intl/intl.dart';

class CHelperFunctions {
  CHelperFunctions._();


  // - - - Navigat To Other Screen - - -
  static void navigateToScreen({required BuildContext context, required Widget screen, bool replacement=false, bool addSound = true}){
    replacement ? Navigator.pushAndRemoveUntil(
      context, MaterialPageRoute(builder: (context) => screen), (route) => false
    ) : Navigator.push(
      context, MaterialPageRoute(builder: (context) => screen)
    );
  }


  // - - - A V A I A L A B L E _ S C R E E N _ S P A C E
  static double availableScreenHeight({required BuildContext context}) {
    // final screenHeight = MediaQuery.of(context).size.height;
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = 0;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    print('Height: $appBarHeight');
    return screenHeight - appBarHeight - topPadding - bottomPadding;
  }


  // - - - T E X T _ T R A N S F O R M A T I O N
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase()+text.substring(1).toLowerCase();
  }

  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;

    String firstFormat = text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    String finalFormat = firstFormat.split('-').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join('-');

    return finalFormat;
  }



  static String formatNumberWithComma(num number, {bool addDecimal = false}) {
    final formatter = addDecimal ? NumberFormat('#,##0.00') : NumberFormat('#,##0.##');
    return formatter.format(number);
  }

  static double? formatStringToDouble(String number) {
    final cleaned = number.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.-]'), '');
    return double.tryParse(cleaned);
  }

  static String formatDateTime(DateTime date, { bool timeOnly = false, bool addTime = false, bool shortBaseMonth = false, bool normalFormat = false }) {
    final String dateFormat = normalFormat ? 'yyyy-MM-dd' : (shortBaseMonth ? 'MM-dd-yyyy' : 'MMM - dd - yyyy');
    final formattedDate = DateFormat(dateFormat).format(date);
    final formattedTime = DateFormat('hh:mm a').format(date);
    return timeOnly ? formattedTime : (addTime ? '$formattedDate   $formattedTime' : formattedDate);
  }

  static DateTime? formateStringToDate({ required String value }) {
    DateFormat inputFormat = DateFormat('dd-MM-yyyy');
    return inputFormat.tryParse(value);
  }


  static String getStockStatus({ required int stock, required int alertQuantity }) {
    if (stock <= 0) return 'out of stock';
    if (stock <= alertQuantity) return 'low stock';
    return 'available';
  }

  static Color getStockStatusColor({ required int stock, required int alertQuantity }) {
    if (stock <= 0) return CColors.red.withValues(alpha: 0.3);
    if (stock <= alertQuantity) return CColors.deepOrange.withValues(alpha: 0.3);
    return CColors.green.withValues(alpha: 0.3);
  }



  // -- -- --
  static String shortenId(String id) {
    if (id.isEmpty) return id;
    final seperated = id.split('-').toList();
    
    List<String> list = seperated.map((section) {
      return section.substring(1, 4);
    }).toList();

    return list.length >= 4 ? '${list[0]}-${list[1]}${list[2]}-${list.last}' : list.first;
  }
}
  // void getStockStatus() {
  //     if (product.stock <= 0) {
  //       stockStatus = 'out of stock';
  //       stockStatusColor = CColors.red.withValues(alpha: 0.3);
  //     } 
  //     else if (product.stock <= product.alertQuantity) {
  //       stockStatus = 'low stock';
  //       stockStatusColor = CColors.deepOrange.withValues(alpha: 0.3);
  //     } 
  //     else {
  //       stockStatus = 'available';
  //       stockStatusColor = CColors.green.withValues(alpha: 0.3);
  //     } 
  //   }
  //   getStockStatus();