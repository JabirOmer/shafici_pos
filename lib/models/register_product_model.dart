import 'package:shafici_pos/helpers/helper_functions.dart';

class RegisterProductModel {
  final String productBarcode;
  final String productName;
  final String categoryId;
  final DateTime? expireDate;
  final double? costInUsd;
  final double costInBirr;
  final double sellingPrice;
  final double onDiscountPrice;
  final bool isTaxable;
  final int stockQuanity;
  final int alertQuantity;
  final String? productCode;
  final String? batchNumber;


  RegisterProductModel({
    required this.productBarcode,
    required this.productName,
    required this.categoryId,
    required this.expireDate,
    required this.costInUsd,
    required this.costInBirr,
    required this.sellingPrice,
    required this.onDiscountPrice,
    required this.isTaxable,
    required this.stockQuanity,
    required this.alertQuantity,
    required this.productCode,
    required this.batchNumber,
  });


  Map<String, dynamic> toJson() {
    return {
      "product_barcode": productBarcode,
      "product_name": productName,
      "category_id": categoryId,
      "expire_date": expireDate != null ? CHelperFunctions.formatDateTime(expireDate!, normalFormat: true) : null,
      "cost_in_usd": costInUsd,
      "cost_in_birr": costInBirr,
      "selling_price": sellingPrice,
      "on_discount_price": onDiscountPrice,
      "is_taxable": isTaxable,
      "stock_quantity": stockQuanity,
      "alert_quantity": alertQuantity,
      "product_code": productCode,
      "batch_number": batchNumber,
    };
  }
}