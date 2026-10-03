import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
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
      pageFormat: PdfPageFormat.a4,
      // margin: EdgeInsets.all(15),
      build: (context) => [
        _buildTitle(credit),

        // the rest of the data
      ],
    ));

    return CPdfService.saveDocument(name: name, pdf: pdf);
  }




// - - - 
// - - - 
// - - - 




  // 
  static Widget _buildTitle(CreditModel credit) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      
      Text(
        'INVOICE',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold
        )
      ),
      SizedBox(height: 0.2 * PdfPageFormat.cm),
      Text(CHelperFunctions.shortenId(credit.creditId)),

      SizedBox(height: 0.8 * PdfPageFormat.cm),

      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ISSUED TO:', style: TextStyle( fontWeight: FontWeight.bold )),
                SizedBox(height: 0.2 * PdfPageFormat.cm),
                Text(CHelperFunctions.capitalizeWords(credit.customer.customerName)),
                Text(credit.customer.phoneNumber),
              ]
            )
          ),


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('VOUCHER NO', style: TextStyle( fontWeight: FontWeight.bold )),
                
                SizedBox(height: 0.2 * PdfPageFormat.cm),
                Text('Date: ${CHelperFunctions.formatDateTime(credit.createdAt)}'),
              ]
            )
          ),
        ]
      )

    ]
  );




  // 
  // static Widget _itemsList(CreditModel credit) {
  //   final headers = {
  //     index
  //   }

  //   return TableHelper.fromTextArray(
  //     headers: ,
  //     data: data
  //   );
  // }

}