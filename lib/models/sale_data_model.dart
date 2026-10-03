import 'package:hive_flutter/adapters.dart';
import 'package:shafici_pos/constants/hive_type_ids.dart';
import 'package:shafici_pos/models/credit_model.dart';
import 'package:shafici_pos/models/order_calculation_model.dart';
import 'package:shafici_pos/models/order_item_model.dart';
import 'package:shafici_pos/models/order_payment_model.dart';


part 'adapters/sale_data_model.g.dart';
const typeId = CHiveTypeIds.offlineOrderTypeId;
@HiveType(typeId: typeId)

class SaleDataModel {
  @HiveField(0)
  final String sellerId;
  
  @HiveField(1)
  final String sellerName;
  
  @HiveField(2)
  final String cashierId;

  
  @HiveField(3)
  final String cashierName;
  
  @HiveField(4)
  final List<OrderItemModel> items;
  
  @HiveField(5)
  final OrderCalculationModel orderCalculation;
  
  @HiveField(6)
  final List<OrderPaymentModel> orderPayments;
  
  @HiveField(7)
  final double totalChange;
  
  @HiveField(8)
  final DateTime createdAt;
  
  @HiveField(9)
  final String? receiptUrl;
  
  @HiveField(10)
  final CreditModel? creditData;

  SaleDataModel({
    required this.sellerId,
    required this.sellerName,
    required this.cashierId,
    required this.cashierName,
    required this.items,
    required this.orderCalculation,
    required this.orderPayments,
    required this.totalChange,
    required this.createdAt,
    this.receiptUrl,
    required this.creditData
  });


  factory SaleDataModel.fromMap(Map<String, dynamic> sale) {
    return SaleDataModel( 
      sellerId: sale['seller_id'],
      sellerName: sale['seller_name'],
      cashierId: sale['cashier_id'],
      cashierName: sale['cashier_name'],
      items: (sale['order_items'] as List<dynamic>? ?? []).map((item) => OrderItemModel.fromMap(item)).toList(),
      orderCalculation: OrderCalculationModel.fromMap(sale['order_calculation']),
      orderPayments: (sale['order_payments'] as List<dynamic>).map((payment) => OrderPaymentModel.fromMap(payment)).toList(),
      totalChange: double.parse(sale['total_change']),
      createdAt: DateTime.parse(sale['created_at']).toLocal(),
      receiptUrl: sale['receipt_url'],
      // creditData: CreditModel.fromMap(sale['credit_data']) 
      creditData: null
    );
  }
}