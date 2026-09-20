import 'package:hive_flutter/hive_flutter.dart';
import 'package:shafici_pos/constants/hive_type_ids.dart';

part 'adapters/order_calculation_model.g.dart';
const typeId = CHiveTypeIds.orderCalculationTypeId;
@HiveType(typeId: typeId)

class OrderCalculationModel extends HiveObject {
  @HiveField(0)
  final double subtotal;

  @HiveField(1)
  final double discount;

  @HiveField(2)
  final double taxable;

  @HiveField(3)
  final double vat;

  @HiveField(4)
  final double grandTotal;

  @HiveField(5)
  final double totalCost;



  OrderCalculationModel({
    required this.subtotal,
    required this.discount,
    required this.taxable,
    required this.vat,
    required this.grandTotal,
    required this.totalCost,
  });


  factory OrderCalculationModel.fromMap(Map<String, dynamic> calculation) {
    return OrderCalculationModel(
      subtotal: double.parse(calculation['subtotal'].toString()),
      discount: double.parse(calculation['discount'].toString()),
      taxable: double.parse(calculation['taxable'].toString()),
      vat: double.parse(calculation['vat'].toString()),
      grandTotal: double.parse(calculation['grand_total'].toString()),
      totalCost: double.parse(calculation['total_cost'].toString()),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "subtotal": subtotal,
      "discount": discount,
      "taxable": taxable,
      "vat": vat,
      "grand_total": grandTotal,
      "total_cost": totalCost,
    };
  }
}