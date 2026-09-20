import 'package:hive_flutter/hive_flutter.dart';
import 'package:shafici_pos/constants/hive_type_ids.dart';

part 'adapters/order_item_model.g.dart';
const typeId = CHiveTypeIds.orderItemTypeId;
@HiveType(typeId: typeId)

class OrderItemModel extends HiveObject {
  @HiveField(0)
  final String productId;
  
  @HiveField(1)
  final String productName;

  @HiveField(4)
  final bool isTaxable;

  @HiveField(5)
  final double unitCost;

  @HiveField(6)
  final double unitSoldAt;

  @HiveField(7)
  int quantity;

  @HiveField(8)
  final DateTime createdAt;



  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.isTaxable,
    required this.unitCost,
    required this.unitSoldAt,
    required this.quantity,
    required this.createdAt,
  });


  factory OrderItemModel.fromMap(Map<String, dynamic> item) {
    print(1);
    return OrderItemModel(
      productId: item['product_id'], 
      productName: item['product_name'], 
      isTaxable: item['is_taxable'], 
      unitCost: double.parse(item['unit_cost'].toString()), 
      unitSoldAt: double.parse(item['unit_sold_at'].toString()), 
      quantity: int.parse(item['quantity'].toString()), 
      createdAt: DateTime.parse(item['created_at'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "product_name": productName,
      "is_taxable": isTaxable,
      "unit_cost": unitCost,
      "unit_sold_at": unitSoldAt,
      "quantity": quantity
    };
  }
}