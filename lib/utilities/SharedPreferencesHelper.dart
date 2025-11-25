import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  // Singleton pattern to ensure a single instance
  static final SharedPreferencesHelper _instance = SharedPreferencesHelper._internal();

  factory SharedPreferencesHelper() {
    return _instance;
  }

  SharedPreferencesHelper._internal();

  // Save data method
  Future<void> setPref(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (value is String) {
      prefs.setString(key, value);
    }
    else if (value is int) {
      prefs.setInt(key, value);
    } else if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is double) {
      prefs.setDouble(key, value);
    } else if (value is List<String>) {
      prefs.setStringList(key, value);
    }
  }

  // Get data method
  Future<dynamic> getPref(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  // Remove a specific key
  Future<void> removePref(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  // Clear all preferences
  Future<void> clearPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
