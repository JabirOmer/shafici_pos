import 'package:hive_flutter/hive_flutter.dart';
import 'package:shafici_pos/constants/hive_type_ids.dart';
import 'package:shafici_pos/models/order_item_model.dart';

part 'adapters/order_session_model.g.dart';
const typeId = CHiveTypeIds.orderSessionTypeId;
@HiveType(typeId: typeId)

class OrderSessionModel extends HiveObject {
  @HiveField(0)
  final int sessionId;

  @HiveField(1)
  final List<OrderItemModel> items;

  @HiveField(2)
  final double discount;


  OrderSessionModel({
    required this.sessionId,
    required this.items,
    this.discount = 0,
  });


  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'items': items.map((item) => item.toJson()).toList(),
      'discount': discount
    };
  }
}