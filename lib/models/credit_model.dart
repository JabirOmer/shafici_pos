import 'package:flutter/foundation.dart';
import 'package:shafici_pos/models/credit_record_model.dart';
import 'package:shafici_pos/models/customer_model.dart';

class CreditModel {
  final String branchId;
  final String creditId;
  final double totalAmount;
  final CustomerModel customer;
  final String creditStatus;
  final List<CreditRecordModel> records;
  final DateTime createdAt;


  CreditModel({
    required this.branchId,
    required this.creditId,
    required this.totalAmount,
    required this.customer,
    required this.creditStatus,
    required this.records,
    required this.createdAt,
  });


  factory CreditModel.fromMap(Map<String, dynamic> credit) {
    return CreditModel(
      branchId: credit['branch_id'], 
      creditId: credit['credit_id'], 
    customer: CustomerModel.fromMap(credit['customer'] as Map<String, dynamic>), 
      creditStatus: credit['credit_status'], 
      totalAmount: double.parse(credit['total_amount']), 
      records: (credit['records'] as List<dynamic>).map((record) => CreditRecordModel.fromMap(record)).toList(), 
      createdAt: DateTime.parse(credit['created_at']).toLocal()
    );
  }
}