import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

enum SettingsType {
  API_URL,
  WS_URL,

  USE_UDP_IP,
  UDP_IP
}

extension SettingsTypeExtension on SettingsType {
  dynamic get defaultValue {
    switch (this) {
      case SettingsType.API_URL:
        return 'https://api.games.bunj.app';
      case SettingsType.WS_URL:
        return 'wss://api.games.bunj.app';
      case SettingsType.USE_UDP_IP:
        return true;
      case SettingsType.UDP_IP:
        return 'auto';
    }
  }
}

class SettingsService {

  SettingsService._();

  late SharedPreferences _sharedPreferences;

  static SettingsService? _instance;
  static Future<SettingsService> getInstance() async {
    if (_instance == null) {
      _instance = SettingsService._();
      _instance!._sharedPreferences = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  String getString(SettingsType type) {
    return _sharedPreferences.getString(type.toString()) ?? type.defaultValue;
  }

  Future<void> setString(SettingsType type, String value) async {
    await _sharedPreferences.setString(type.toString(), value);
  }

  bool getBool(SettingsType type) {
    return _sharedPreferences.getBool(type.toString()) ?? type.defaultValue;
  }

  Future<void> setBool(SettingsType type, bool value) async {
    await _sharedPreferences.setBool(type.toString(), value);
  }

}
