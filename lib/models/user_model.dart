import 'package:hive_flutter/hive_flutter.dart';
import 'package:shafici_pos/constants/hive_type_ids.dart';

part 'adapters/user_model.g.dart';
const typeId = CHiveTypeIds.userTypeId;
@HiveType(typeId: typeId)

class UserModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String firstName;
  
  @HiveField(2)
  final String middleName;
  
  @HiveField(3)
  final String lastName;
  
  @HiveField(4)
  final String phoneNumber;
  
  @HiveField(5)
  final String userRole;

  @HiveField(6)
  final bool isActive;

  @HiveField(7)
  final bool canEditInventory;


  UserModel({
    required this.userId,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.phoneNumber,
    required this.userRole,
    required this.isActive,
    required this.canEditInventory,
  });


  factory UserModel.fromMap(Map<String, dynamic> user) {
    return UserModel(
      userId: user['user_id'],
      firstName: user['first_name'],
      middleName: user['middle_name'],
      lastName: user['last_name'],
      phoneNumber: user['phone_number'],
      userRole: user['user_role'],
      isActive: user['is_active'],
      canEditInventory: user['can_edit_inventory'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "first_name": firstName,
      "middle_name": middleName,
      "last_name": lastName,
      "phone_number": phoneNumber,
      "user_role": userRole,
      "is_active": isActive,
      "can_edit_inventory": canEditInventory,
    };
  }
}