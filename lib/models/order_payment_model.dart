import 'package:hive_flutter/hive_flutter.dart';
import 'package:shafici_pos/constants/hive_type_ids.dart';


part 'adapters/order_payment_model.g.dart';
const typeId = CHiveTypeIds.orderPaymentTypeId;
@HiveType(typeId: typeId)


class OrderPaymentModel extends HiveObject {
  @HiveField(0)
  final String paymentId;

  @HiveField(1)
  final String paymentName;

  @HiveField(2)
  final double paidAmount;

  
  OrderPaymentModel({
    required this.paymentId,
    required this.paymentName,
    required this.paidAmount
  });


  factory OrderPaymentModel.fromMap(Map<String, dynamic> payment) {
    return OrderPaymentModel(
      paymentId: payment['payment_id'], 
      paymentName: payment['payment_name'], 
      paidAmount: double.parse(payment['paid_amount'])
    );
  }

  
  Map<String, dynamic> toJson() {
    return {
      "method_id": paymentId,
      "method_name": paymentName,
      "amount": paidAmount
    };
  }
}