class CreditItemModel {
  final String productId;
  final String productName;
  final double unitSoldAt;
  final int quantity;

  
  CreditItemModel({
    required this.productId,
    required this.productName,
    required this.unitSoldAt,
    required this.quantity,
  });


  factory CreditItemModel.fromMap(Map<String, dynamic> item) {
    return CreditItemModel(
      productId: item['product_id'], 
      productName: item['product_name'],
      unitSoldAt: 200,
      quantity: 4 
      // unitSoldAt: double.parse(item['unit_sold_at']), 
      // quantity: int.parse(item['quantity'])
    );
  }
}