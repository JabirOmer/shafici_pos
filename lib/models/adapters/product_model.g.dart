// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductModelAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 3;

  @override
  ProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductModel(
      productId: fields[0] as String,
      categoryId: fields[1] as String,
      categoryName: fields[2] as String,
      productBarcode: fields[3] as String,
      productName: fields[4] as String,
      unitCost: fields[5] as double,
      unitCostInUSD: fields[6] as double?,
      sellingPrice: fields[7] as double,
      onDiscountPrice: fields[8] as double,
      stock: fields[9] as int,
      alertQuantity: fields[10] as int,
      expireDate: fields[11] as DateTime?,
      isTaxable: fields[12] as bool,
      updatedAt: fields[14] as DateTime?,
      createdAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.categoryName)
      ..writeByte(3)
      ..write(obj.productBarcode)
      ..writeByte(4)
      ..write(obj.productName)
      ..writeByte(5)
      ..write(obj.unitCost)
      ..writeByte(6)
      ..write(obj.unitCostInUSD)
      ..writeByte(7)
      ..write(obj.sellingPrice)
      ..writeByte(8)
      ..write(obj.onDiscountPrice)
      ..writeByte(9)
      ..write(obj.stock)
      ..writeByte(10)
      ..write(obj.alertQuantity)
      ..writeByte(11)
      ..write(obj.expireDate)
      ..writeByte(12)
      ..write(obj.isTaxable)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
