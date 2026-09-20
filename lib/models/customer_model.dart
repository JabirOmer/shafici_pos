import 'package:hive_flutter/adapters.dart';
import 'package:shafici_pos/constants/hive_type_ids.dart';

part 'adapters/customer_model.g.dart';
const typeId = CHiveTypeIds.customerMethodTypeId;
@HiveType(typeId: typeId)

class CustomerModel extends HiveObject {
  @HiveField(0)
  final String customerId;

  @HiveField(1)
  final String customerName;

  @HiveField(2)
  final String phoneNumber;

  CustomerModel({
    required this.customerId,
    required this.customerName,
    required this.phoneNumber,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> customer) {
    return CustomerModel(
      customerId: customer['customer_id'], 
      customerName: customer['customer_name'], 
      phoneNumber: customer['phone_number']
    );
  }
}