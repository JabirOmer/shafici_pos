import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/shared_prefs_keys.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/models/device_model.dart';
import 'package:shafici_pos/models/user_model.dart';
import 'package:shafici_pos/providers/products_provider.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';
import 'package:shafici_pos/services/shared_preferences_services.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

enum AuthStatusEnum { home, login, unVerified }

class AppInfoProvider extends ChangeNotifier {
  final ProductsProvider productsProvider;

  final CSecureStorageService _secureStorageService = CSecureStorageService();
  final CApiServices _apiServices = CApiServices();
  final CSharedPreferencesServices _sharedPreferencesServices = CSharedPreferencesServices();

  UserModel? _currentUser;
  DeviceModel? _deviceData;
  AuthStatusEnum? _authStatusEnum;
  String? _errorMessage;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  DeviceModel? get deviceData => _deviceData;
  AuthStatusEnum? get authStatusEnum => _authStatusEnum;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  bool get calculateVAT => _sharedPreferencesServices.getBool(CSharedPrefsKeys.calculateVAT) ?? false;
  bool get onDiscount => _sharedPreferencesServices.getBool(CSharedPrefsKeys.onDiscount) ?? false;
  // String? get exchangeRate => _sharedPreferencesServices.getString(CSharedPrefsKeys.onDiscount) ?? false;



  AppInfoProvider({
    required this.productsProvider
  });



  // - - - Func_1
  Future<void> getAuthStatusEnum() async {
    try {
      _isLoading = true;
      notifyListeners();

      // check device status
      final deviceIsActive = await checkDeviceStatus();
      if (!deviceIsActive) {
        _authStatusEnum = AuthStatusEnum.unVerified;
        notifyListeners();
        return;
      }

      // decode device token
      _deviceData = await _decodeDeviceToken();
      notifyListeners();
      if (_deviceData == null) {
        _authStatusEnum = AuthStatusEnum.unVerified;
        notifyListeners();
        return;
      }

      // decode user token
      _currentUser = await _decodeJWT();
      notifyListeners();

      _authStatusEnum = _currentUser == null ? AuthStatusEnum.login : AuthStatusEnum.home;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  // Future<void> getAppInfo() async {
  //   try {
  //     final response = await CApiServices.ap
  //   } catch (e) {
      
  //   }
  // }



  Future<DeviceModel?> _decodeDeviceToken() async {
    try {
      final token = await _secureStorageService.read(CSecureStrings.deviceToken);
      if (token == null) {
        print('error 1');
        return null;
      }

      // ensure token is not expired
      final isExpired = JwtDecoder.isExpired(token);
      if (isExpired) {
        return null;
      }
     
      // decode token
      final Map<String, dynamic>? decodedToken = JwtDecoder.tryDecode(token);
      if (decodedToken == null) {
        return null;
      }

      // success
      final device = DeviceModel.fromMap(decodedToken);
      return device;
    } catch (e) {
      return null;
    }
  }



  // - - - Func_3
  Future<bool> checkDeviceStatus() async {
    try {
      final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
      final response = await _apiServices.getRequest(url: CUrlStrings.checkTokenStatusUrl, authToken: deviceToken);      
      switch (response.statusCode) {
        case 400 || 401 || 403: {
          await _secureStorageService.delete(CSecureStrings.deviceToken);
          await _secureStorageService.delete(CSecureStrings.jwtKey);
          return false;
        }
        default: return true;
      }
    } catch (e) {
      return false;
    }
  }




  // - - - Func_4
  Future<UserModel?> _decodeJWT() async {
    try {
      // get the token from the secure store
      final String? token = await _secureStorageService.read(CSecureStrings.jwtKey);
      if (token == null) {
        return null;
      }

      // ensure token is not expired
      final isExpired = JwtDecoder.isExpired(token);
      if (isExpired) {
        return null;
      }
     
      // decode token
      final Map<String, dynamic>? decodedToken = JwtDecoder.tryDecode(token);
      if (decodedToken == null) {
        return null;
      }

      // success
      final userData = UserModel.fromMap(decodedToken);
      return userData;
    } catch (e) {
      return null;
    }
  }




  // - - - Func_5
  Future<bool> userLogout() async {
    try {
      await _secureStorageService.delete(CSecureStrings.jwtKey);
      _currentUser = null;
      _authStatusEnum = AuthStatusEnum.login;
      return true;
    } catch (e) {
      return false;
    }
  }

  
  
  
  // - - - Func_6
  Future<void> revokeDevice() async {
    await _secureStorageService.deleteAll();
    await getAuthStatusEnum();
  }





  // PREFES
  Future<void> setDafultPrefs() async {
    final CSharedPreferencesServices sharedPreferencesServices = CSharedPreferencesServices();
    final showMiniSideBar = CSharedPrefsKeys.showMiniSideBar;
    final onDiscount = CSharedPrefsKeys.onDiscount;
    final calculateVAT = CSharedPrefsKeys.calculateVAT;
    final serverPort = CSharedPrefsKeys.serverPort;
    final exchangeRate = CSharedPrefsKeys.exchangeRate;

    if (sharedPreferencesServices.getBool(showMiniSideBar) == null) {
      await sharedPreferencesServices.setBool(showMiniSideBar, true);
    }

    if (sharedPreferencesServices.getBool(onDiscount) == null) {
      await sharedPreferencesServices.setBool(onDiscount, false);
    }

    if (sharedPreferencesServices.getBool(calculateVAT) == null) {
      await sharedPreferencesServices.setBool(calculateVAT, false);
    }

    if (sharedPreferencesServices.getString(serverPort) == null) {
      await sharedPreferencesServices.setString(serverPort, '4040');
    }

    if (sharedPreferencesServices.getString(exchangeRate) == null) {
      await sharedPreferencesServices.setString(exchangeRate, '180');
    }
  }


  Future<void> setSharedPereferenceBool(String key, bool value) async {
    await _sharedPreferencesServices.setBool(key, value);
    notifyListeners();
  }
  
  Future<void> setSharedPereferenceString(String key, String value) async {
    await _sharedPreferencesServices.setString(key, value);
    notifyListeners();
  }


  // --- --- ---
  Future<void> toggleVAT() async {
    await setSharedPereferenceBool(CSharedPrefsKeys.calculateVAT, !calculateVAT);
    await productsProvider.manuallyRecalculate();
  }
}