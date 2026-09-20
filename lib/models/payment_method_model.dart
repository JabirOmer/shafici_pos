import 'package:hive_flutter/adapters.dart';
import 'package:shafici_pos/constants/hive_type_ids.dart';

part 'adapters/payment_method_model.g.dart';
const typeId = CHiveTypeIds.paymentMethodTypeId;
@HiveType(typeId: typeId)

class PaymentMethodModel extends HiveObject {
  @HiveField(0)
  final String paymentId;

  @HiveField(1)
  final String paymentName;

  @HiveField(2)
  final String? paymentAccount;
  
  @HiveField(3)
  final DateTime createdAt;
  
  @HiveField(4)
  final DateTime updatedAt;

  PaymentMethodModel({
    required this.paymentId,
    required this.paymentName,
    this.paymentAccount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentMethodModel.fromMap(Map<String, dynamic> method) {
    return PaymentMethodModel(
      paymentId: method['payment_id'], 
      paymentName: method['payment_name'],
      paymentAccount: method['payment_account'],
      createdAt: DateTime.parse(method['created_at']),
      updatedAt: DateTime.parse(method['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'payment_name': paymentName,
      'payment_account': paymentAccount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String()
    };
  }


  static Map<String, String> toDropDownMap(List<PaymentMethodModel> methods) {
    return { for (var method in methods) (method).paymentId : (method).paymentName };
  }
}