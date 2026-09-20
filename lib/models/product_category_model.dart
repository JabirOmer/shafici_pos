import 'package:hive_flutter/hive_flutter.dart';
import 'package:shafici_pos/constants/hive_type_ids.dart';

part 'adapters/product_category_model.g.dart';
const typeId = CHiveTypeIds.productCategoryTypeId;
@HiveType(typeId: typeId)

class ProductCategoryModel extends HiveObject {
  @HiveField(0)
  final String categoryId;

  @HiveField(1)
  final String categoryName;


  ProductCategoryModel({
    required this.categoryId,
    required this.categoryName,
  });


  factory ProductCategoryModel.fromMap(Map<String, dynamic> category) {
    return ProductCategoryModel(
      categoryId: category['category_id'], 
      categoryName: category['category_name']
    );
  }


  static Map<String, String> toDropDownMap(List<ProductCategoryModel> categories) {
    return { for (var category in categories) (category).categoryId : (category).categoryName };
  }
}