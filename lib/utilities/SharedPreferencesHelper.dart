import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  // Singleton pattern to ensure a single instance
  static final SharedPreferencesHelper _instance = SharedPreferencesHelper._internal();

  factory SharedPreferencesHelper() {
    return _instance;
  }

  SharedPreferencesHelper._internal();

  // Cache the SharedPreferences instance to avoid repeated getInstance() calls
  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences - call this once at app startup
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get the cached instance (or initialize if not done)
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Save data method - uses cached instance
  Future<void> setPref(String key, dynamic value) async {
    final prefs = await _getPrefs();

    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    }
  }

  // Get data method - uses cached instance
  Future<dynamic> getPref(String key) async {
    final prefs = await _getPrefs();
    return prefs.get(key);
  }

  // Synchronous get for when prefs is already initialized
  String? getString(String key) => _prefs?.getString(key);
  int? getInt(String key) => _prefs?.getInt(key);
  bool? getBool(String key) => _prefs?.getBool(key);
  double? getDouble(String key) => _prefs?.getDouble(key);

  // Remove a specific key
  Future<void> removePref(String key) async {
    final prefs = await _getPrefs();
    await prefs.remove(key);
  }

  // Clear all preferences
  Future<void> clearPref() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }

  // Batch save multiple values at once (more efficient than multiple setPref calls)
  Future<void> setMultiple(Map<String, dynamic> values) async {
    final prefs = await _getPrefs();
    for (final entry in values.entries) {
      if (entry.value is String) {
        await prefs.setString(entry.key, entry.value);
      } else if (entry.value is int) {
        await prefs.setInt(entry.key, entry.value);
      } else if (entry.value is bool) {
        await prefs.setBool(entry.key, entry.value);
      } else if (entry.value is double) {
        await prefs.setDouble(entry.key, entry.value);
      }
    }
  }
}
