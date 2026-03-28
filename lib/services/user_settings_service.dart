import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// lib/services/settings_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _themeKey = "theme";

  /// Save theme locally
  static Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  /// Get theme locally
  static Future<String?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }
}

class UserSettingsService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String? get uid => FirebaseAuth.instance.currentUser?.uid;

  static DocumentReference<Map<String, dynamic>>? get _ref {
    final userId = uid;
    if (userId == null) return null;

    return _db
        .collection("users")
        .doc(userId)
        .collection("settings")
        .doc("config");
  }



  /// SAVE ALL SETTINGS (not only sync)
  static Future<void> saveSettings(Map<String, dynamic> data) async {
    final ref = _ref;
    if (ref == null) return;

    await ref.set(data, SetOptions(merge: true));
  }

  /// GET ALL SETTINGS
  static Future<Map<String, dynamic>?> getSettings() async {
    final ref = _ref;
    if (ref == null) return null;

    final doc = await ref.get();
    return doc.data();
  }
}