// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../order_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderDataModelAdapter extends TypeAdapter<OrderDataModel> {
  @override
  final int typeId = 8;

  @override
  OrderDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderDataModel(
      sellerId: fields[0] as String,
      cashierId: fields[1] as String?,
      customerId: fields[2] as String?,
      items: (fields[3] as List).cast<OrderItemModel>(),
      orderCalculation: fields[4] as OrderCalculationModel,
      orderPayments: (fields[5] as List).cast<OrderPaymentModel>(),
      totalChange: fields[6] as double,
      createdAt: fields[7] as DateTime,
      creditData: fields[8] as RegisterCreditModel?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderDataModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.sellerId)
      ..writeByte(1)
      ..write(obj.cashierId)
      ..writeByte(2)
      ..write(obj.customerId)
      ..writeByte(3)
      ..write(obj.items)
      ..writeByte(4)
      ..write(obj.orderCalculation)
      ..writeByte(5)
      ..write(obj.orderPayments)
      ..writeByte(6)
      ..write(obj.totalChange)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.creditData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
