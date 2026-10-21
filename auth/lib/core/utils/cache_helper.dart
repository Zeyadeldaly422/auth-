import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? _sharedPreferences;

  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> saveData({
    required String key,
    required dynamic value,
  }) async {
    if (_sharedPreferences == null) {
      await init();
    }

    if (value is String) return await _sharedPreferences!.setString(key, value);
    if (value is int) return await _sharedPreferences!.setInt(key, value);
    if (value is bool) return await _sharedPreferences!.setBool(key, value);
    if (value is double) return await _sharedPreferences!.setDouble(key, value);
    return false;
  }

  static dynamic getData({required String key}) {
    return _sharedPreferences?.get(key);
  }

  static String? getString({required String key}) {
    return _sharedPreferences?.getString(key);
  }

  static Future<bool> removeData({required String key}) async {
    if (_sharedPreferences == null) {
      await init();
    }
    return await _sharedPreferences!.remove(key);
  }

  static Future<bool> clearData() async {
    if (_sharedPreferences == null) {
      await init();
    }
    return await _sharedPreferences!.clear();
  }
}

