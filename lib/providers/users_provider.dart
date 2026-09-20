import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shafici_pos/constants/hive_strings.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/models/user_model.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';

enum UserRolesEnum { admin, cashier }

class UsersProvider extends ChangeNotifier {
  final CSecureStorageService _secureStorageService = CSecureStorageService();
  final CApiServices _apiServices = CApiServices();
  final Box<UserModel> _usersBox = Hive.box(CHiveStrings.usersBox);

  final List<UserModel> _userList = [];
  final Map<String, String> _rolesMap = {};

  bool _isLoading = false;
  String? _errorMessage;

  List<UserModel> get userList => _userList;
  Map<String, String> get rolesMap => _rolesMap;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;



  // - - - S E T _ U S E R S
  Future<void> setUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _fetchUsersData();
      _setRolesMap();
    } catch (e) {
      _errorMessage = 'failed to get users data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  // - - - F E T C H _ U S E R S
  Future<void> _fetchUsersData() async {
    try {
      final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
      final response = await _apiServices.getRequest(url: CUrlStrings.getUsersUrl, authToken: deviceToken);

      switch (response.statusCode) {
        case 200: {
          final List<dynamic> data = response.data;
          final List<UserModel> users = data.map((user) => UserModel.fromMap(user)).toList();
          await _usersBox.clear();
          await _usersBox.addAll(users);
        }

        default: {
          throw Error();
        }
      }
    } catch (e) {
      throw Error();
    } finally {
      _userList.clear();
      _userList.addAll(_usersBox.values);
      notifyListeners();
    }
  }



  // - - - S E T _ R O L E S _ M A P
  void _setRolesMap() {
    final Map<String, String> roles = {};
    roles.addAll({
      for (var role in UserRolesEnum.values) (role).name : (role).name
    });
    _rolesMap.clear();
    _rolesMap.addAll(roles);
    notifyListeners();
  }

}