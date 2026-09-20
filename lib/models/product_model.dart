import 'package:hive_flutter/hive_flutter.dart';
import 'package:shafici_pos/constants/hive_type_ids.dart';

part 'adapters/product_model.g.dart';
const typeId = CHiveTypeIds.productTypeId;
@HiveType(typeId: typeId)

class ProductModel extends HiveObject {
  
  @HiveField(0)
  final String productId;
  
  @HiveField(1)
  final String categoryId;
  
  @HiveField(2)
  final String categoryName;
  
  @HiveField(3)
  final String? productCode;

  @HiveField(4)
  final String productBarcode;
  
  @HiveField(5)
  final String productName;
  
  @HiveField(6)
  final double unitCost;

  @HiveField(7)
  final double? unitCostInUSD;

  @HiveField(8)
  final double sellingPrice;

  @HiveField(9)
  final double onDiscountPrice;
  
  @HiveField(10)
  final int stock;

  @HiveField(11)
  final int alertQuantity;
  
  @HiveField(12)
  final DateTime? expireDate;

  @HiveField(13)
  final bool isTaxable;

  @HiveField(14)
  final DateTime? createdAt;

  @HiveField(15)
  final DateTime? updatedAt;

  @HiveField(16)
  final String? batchNumber;


  ProductModel({
    required this.productId,
    required this.categoryId,
    required this.categoryName,
    required this.productBarcode,
    this.productCode,
    required this.productName,
    required this.unitCost,
    this.unitCostInUSD,
    required this.sellingPrice,
    required this.onDiscountPrice,
    required this.stock,
    required this.alertQuantity,
    required this.expireDate,
    required this.isTaxable,
    this.updatedAt,
    this.createdAt,
    this.batchNumber,
  });


  factory ProductModel.fromMap(Map<String, dynamic> product) {
    final double cost = double.tryParse(product['cost_in_birr']) ?? 0;
    final double? costInUSD = double.tryParse(product['cost_in_usd'] ?? '');
    final double selling = double.tryParse(product['selling_price']) ?? 0;
    final double discount = double.tryParse(product['on_discount_price']) ?? 0;
    final String expireString = product['expire_date'] ?? '';

    return ProductModel(
      productId: product['product_id'],
      categoryId: product['category_id'],
      categoryName: product['category_name'],
      productBarcode: product['product_barcode'] == product['product_code'] ? '---' : product['product_barcode'],
      productName: product['product_name'],
      unitCost: cost,
      unitCostInUSD: costInUSD,
      sellingPrice: selling,
      onDiscountPrice: discount,
      stock: product['stock_quantity'],
      alertQuantity: product['alert_quantity'],
      expireDate: DateTime.tryParse(expireString)?.toLocal(),
      isTaxable: product['is_taxable'],
      createdAt: DateTime.tryParse(product['created_at'])?.toLocal(),
      updatedAt: DateTime.tryParse(product['updated_at'])?.toLocal(),
      productCode: product['product_code'],
      batchNumber: (product['batch_number']),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "product_name": productName,
      "unit_cost": unitCost,
      "selling_price": sellingPrice,
      "updated_at":  updatedAt?.toIso8601String()
    };
  }
}