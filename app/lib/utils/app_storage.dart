import 'package:shared_preferences/shared_preferences.dart';

/// Cached SharedPreferences singleton for fast access
class AppStorage {
  static SharedPreferences? _prefs;
  static const _firstLaunchKey = 'is_first_launch';
  static const _isAuthenticatedKey = 'is_authenticated';

  /// Initialize SharedPreferences - call this once in main()
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get the cached instance (throws if not initialized)
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('AppStorage.init() must be called before accessing prefs');
    }
    return _prefs!;
  }

  /// Check if this is the first launch (synchronous after init)
  bool isFirstLaunchSync() {
    return prefs.getBool(_firstLaunchKey) ?? true;
  }

  /// Check if user is authenticated (synchronous after init)
  bool isAuthenticatedSync() {
    return prefs.getBool(_isAuthenticatedKey) ?? false;
  }

  /// Legacy async method for compatibility
  Future<bool> isFirstLaunch() async {
    await init();
    return isFirstLaunchSync();
  }

  Future<void> setFirstLaunchFalse() async {
    await init();
    await prefs.setBool(_firstLaunchKey, false);
  }
}
