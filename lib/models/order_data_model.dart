import 'package:hive_flutter/adapters.dart';
import 'package:shafici_pos/constants/hive_type_ids.dart';
import 'package:shafici_pos/models/order_calculation_model.dart';
import 'package:shafici_pos/models/order_item_model.dart';
import 'package:shafici_pos/models/order_payment_model.dart';


part 'adapters/order_data_model.g.dart';
const typeId = CHiveTypeIds.orderDataTypeId;
@HiveType(typeId: typeId)

class OrderDataModel extends HiveObject {
  @HiveField(0)
  final String sellerId;

  @HiveField(1)
  String? cashierId;

  @HiveField(2)
  final String? customerId;

  @HiveField(3)
  final List<OrderItemModel> items;

  @HiveField(4)
  final OrderCalculationModel orderCalculation;

  @HiveField(5)
  final List<OrderPaymentModel> orderPayments;

  @HiveField(6)
  final double totalChange;

  @HiveField(7)
  final DateTime createdAt;


  OrderDataModel({
    required this.sellerId,
    required this.cashierId,
    required this.customerId,
    required this.items,
    required this.orderCalculation,
    required this.orderPayments,
    required this.totalChange,
    required this.createdAt,
  });


  factory OrderDataModel.fromMap(Map<String, dynamic> orderData) {
    return OrderDataModel( 
      sellerId: orderData['seller_id'],
      cashierId: orderData['cashier_id'],
      customerId: orderData['customer_id'],
      items: (orderData['order_items'] as List<dynamic>? ?? []).map((item) => OrderItemModel.fromMap(item)).toList(),
      orderCalculation: OrderCalculationModel.fromMap(orderData['order_calculation']),
      orderPayments: (orderData['order_payments'] as List<dynamic>).map((payment) => OrderPaymentModel.fromMap(payment)).toList(),
      totalChange: double.parse(orderData['total_change']),
      createdAt: DateTime.parse(orderData['created_at']).toLocal(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'seller_id': sellerId,
      'cashier_id': cashierId,
      'customer_id': customerId,
      'order_items': items.map((item) => item.toJson()).toList(),
      'order_calculation': orderCalculation.toJson(),
      'order_payments': orderPayments.map((payment) => payment.toJson()).toList(),
      'total_change': totalChange,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}
