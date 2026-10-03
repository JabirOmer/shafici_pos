import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/credit_model.dart';
import 'package:shafici_pos/services/pdf_service.dart';

class CInvoicePdfService {


  // - - - G E N R A T E _ P D F
  static Future<File> generate(CreditModel credit) async {
    final regular = Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
    final bold = Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'));

    final pdf = Document();

    final customer = credit.customer.customerName;
    final name = '${customer}_invoice.pdf';

    pdf.addPage(MultiPage(
      build: (context) => [
        // _buildTitle(credit),
        Text('text')

        // the rest of the data
      ],
    ));

    return CPdfService.saveDocument(name: name, pdf: pdf);
  }
}




// - - - 
// - - - 
// - - - 




// 
Widget _buildTitle(CreditModel credit) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    
    Text(
      'INVOICE',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold
      )
    ),

    // SizedBox()

    Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text('ISSUED TO', style: TextStyle(  )),
              // Text(credit.customer.customerName),
              // Text(credit.customer.phoneNumber),
            ]
          )
        ),


        Expanded(
          child: Column(
            children: [
              Text('INVOICE NO', style: TextStyle(  )),
              // Text(CHelperFunctions.shortenId(credit.creditId)),
              // Text(CHelperFunctions.formatDateTime(credit.createdAt)),
            ]
          )
        ),
      ]
    )

  ]
);