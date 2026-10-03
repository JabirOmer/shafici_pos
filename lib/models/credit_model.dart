import 'package:flutter/foundation.dart';
import 'package:shafici_pos/models/credit_item_model.dart';
import 'package:shafici_pos/models/credit_record_model.dart';
import 'package:shafici_pos/models/customer_model.dart';
import 'package:shafici_pos/models/order_item_model.dart';

class CreditModel {
  final String branchId;
  final String creditId;
  final double totalAmount;
  final CustomerModel customer;
  final String creditStatus;
  final List<CreditItemModel> items;
  final List<CreditRecordModel> records;
  final DateTime createdAt;


  CreditModel({
    required this.branchId,
    required this.creditId,
    required this.totalAmount,
    required this.customer,
    required this.creditStatus,
    required this.items,
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
      items: (credit['items'] as List<dynamic>).map((item) => CreditItemModel.fromMap(item)).toList(), 
      // items: [],
      records: (credit['records'] as List<dynamic>).map((record) => CreditRecordModel.fromMap(record)).toList(), 
      createdAt: DateTime.parse(credit['created_at']).toLocal()
    );
  }
}