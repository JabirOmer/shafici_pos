import 'package:shafici_pos/models/customer_model.dart';

class RegisterCreditModel {
  final CustomerModel customer;
  final double amount;


  RegisterCreditModel({
    required this.customer,
    required this.amount,
  });


  Map<String, dynamic> toJson() {
    return {
      "customer_id": customer.customerId,
      "credit_amount": amount
    };
  }
}