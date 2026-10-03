class CreditRecordModel {
  final String creditId;
  final String recordId;
  final double amountPaid;
  final String paymentId;
  final String paymentName;
  final DateTime createdAt;


  CreditRecordModel({
    required this.creditId,
    required this.recordId,
    required this.amountPaid,
    required this.paymentId,
    required this.paymentName,
    required this.createdAt,
  });


  factory CreditRecordModel.fromMap(Map<String, dynamic> record) {
    return CreditRecordModel(
      creditId: record['credit_id'], 
      recordId: record['record_id'], 
      amountPaid: double.parse(record['amount_paid']), 
      paymentId: record['payment_id'], 
      paymentName: record['payment_name'], 
      createdAt: DateTime.parse(record['created_at']).toLocal()
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'amount_paid': amountPaid,
      'payment_id': paymentId,
      'created_at': createdAt.toUtc().toIso8601String()
    };
  }

}