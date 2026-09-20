import 'package:shared_preferences/shared_preferences.dart';

class CSharedPreferencesServices {
  static final CSharedPreferencesServices _instance = CSharedPreferencesServices._internal();
  factory CSharedPreferencesServices() => _instance;
  CSharedPreferencesServices._internal();

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Generic methods
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Set<String> getKeys() {
    return _prefs.getKeys();
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
  
}