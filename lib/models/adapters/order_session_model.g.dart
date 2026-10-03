// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../order_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderSessionModelAdapter extends TypeAdapter<OrderSessionModel> {
  @override
  final int typeId = 5;

  @override
  OrderSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderSessionModel(
      sessionId: fields[0] as int,
      items: (fields[1] as List).cast<OrderItemModel>(),
      discount: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, OrderSessionModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.sessionId)
      ..writeByte(1)
      ..write(obj.items)
      ..writeByte(2)
      ..write(obj.discount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
