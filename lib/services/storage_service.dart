import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class StorageService {
  static const String _profileKey = 'user_profile_data';
  static const String _customTemplateKey = 'custom_email_template';
  static const String _lastRoleKey = 'last_chosen_role';
  static const String _lastCustomRoleKey = 'last_custom_role';
  static const String _lastRecipientKey = 'last_recipient_email';

  static Future<UserProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString(_profileKey);
    if (profileJson != null) {
      try {
        final map = jsonDecode(profileJson) as Map<String, dynamic>;
        return UserProfile.fromJson(map);
      } catch (e) {
        // Fallback on parse error
        return UserProfile.defaultProfile();
      }
    }
    return UserProfile.defaultProfile();
  }

  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = jsonEncode(profile.toJson());
    await prefs.setString(_profileKey, profileJson);
  }

  static Future<String?> getCustomTemplate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_customTemplateKey);
  }

  static Future<void> saveCustomTemplate(String template) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customTemplateKey, template);
  }

  static Future<void> clearCustomTemplate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customTemplateKey);
  }

  static Future<String?> getLastChosenRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastRoleKey);
  }

  static Future<void> saveLastChosenRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastRoleKey, role);
  }

  static Future<String?> getLastCustomRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastCustomRoleKey);
  }

  static Future<void> saveLastCustomRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCustomRoleKey, role);
  }

  static Future<String?> getLastRecipientEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastRecipientKey);
  }

  static Future<void> saveLastRecipientEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastRecipientKey, email);
  }
}
