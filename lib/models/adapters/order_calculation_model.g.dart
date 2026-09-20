// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../order_calculation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderCalculationModelAdapter extends TypeAdapter<OrderCalculationModel> {
  @override
  final int typeId = 6;

  @override
  OrderCalculationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderCalculationModel(
      subtotal: fields[0] as double,
      discount: fields[1] as double,
      taxable: fields[2] as double,
      vat: fields[3] as double,
      grandTotal: fields[4] as double,
      totalCost: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, OrderCalculationModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.subtotal)
      ..writeByte(1)
      ..write(obj.discount)
      ..writeByte(2)
      ..write(obj.taxable)
      ..writeByte(3)
      ..write(obj.vat)
      ..writeByte(4)
      ..write(obj.grandTotal)
      ..writeByte(5)
      ..write(obj.totalCost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderCalculationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
