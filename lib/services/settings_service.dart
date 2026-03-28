import 'package:shared_preferences/shared_preferences.dart';
import '../model/sync_mod.dart';


class SettingsService {
  static const _key = "sync_mode";

  /// Save mode
  static Future<void> setSyncMode(SyncMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  /// Get mode
  static Future<SyncMode> getSyncMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);

    if (value == null) return SyncMode.automatic;

    return SyncMode.values.firstWhere(
          (e) => e.name == value,
      orElse: () => SyncMode.automatic,
    );
  }
}