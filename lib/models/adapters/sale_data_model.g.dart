// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../sale_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleDataModelAdapter extends TypeAdapter<SaleDataModel> {
  @override
  final int typeId = 11;

  @override
  SaleDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleDataModel(
      sellerId: fields[0] as String,
      sellerName: fields[1] as String,
      cashierId: fields[2] as String,
      cashierName: fields[3] as String,
      items: (fields[4] as List).cast<OrderItemModel>(),
      orderCalculation: fields[5] as OrderCalculationModel,
      orderPayments: (fields[6] as List).cast<OrderPaymentModel>(),
      totalChange: fields[7] as double,
      createdAt: fields[8] as DateTime,
      receiptUrl: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SaleDataModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.sellerId)
      ..writeByte(1)
      ..write(obj.sellerName)
      ..writeByte(2)
      ..write(obj.cashierId)
      ..writeByte(3)
      ..write(obj.cashierName)
      ..writeByte(4)
      ..write(obj.items)
      ..writeByte(5)
      ..write(obj.orderCalculation)
      ..writeByte(6)
      ..write(obj.orderPayments)
      ..writeByte(7)
      ..write(obj.totalChange)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.receiptUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
