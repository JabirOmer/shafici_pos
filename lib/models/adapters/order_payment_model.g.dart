// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../order_payment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderPaymentModelAdapter extends TypeAdapter<OrderPaymentModel> {
  @override
  final int typeId = 7;

  @override
  OrderPaymentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderPaymentModel(
      paymentId: fields[0] as String,
      paymentName: fields[1] as String,
      paidAmount: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, OrderPaymentModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.paymentId)
      ..writeByte(1)
      ..write(obj.paymentName)
      ..writeByte(2)
      ..write(obj.paidAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderPaymentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
