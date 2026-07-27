import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class StorageService {
  static const String _profileKey = 'user_profile_data';
  static const String _customTemplateKey = 'custom_email_template';
  static const String _customSubjectKey = 'custom_email_subject';
  static const String _lastRoleKey = 'last_chosen_role';
  static const String _lastCustomRoleKey = 'last_custom_role';
  static const String _lastRecipientKey = 'last_recipient_email';
  static const String _recentRecipientsKey = 'recent_recipients_list';
  static const String _lastCompanyKey = 'last_company_name';
  static const String _lastToneKey = 'last_email_tone';

  static Future<UserProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString(_profileKey);
    if (profileJson != null) {
      try {
        final map = jsonDecode(profileJson) as Map<String, dynamic>;
        return UserProfile.fromJson(map);
      } catch (e) {
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

  static Future<String?> getCustomSubject() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_customSubjectKey);
  }

  static Future<void> saveCustomSubject(String subject) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customSubjectKey, subject);
  }

  static Future<void> clearCustomSubject() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customSubjectKey);
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

    if (email.trim().isNotEmpty && email.contains('@')) {
      await addRecentRecipient(email.trim());
    }
  }

  static Future<List<String>> getRecentRecipients() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentRecipientsKey) ?? [];
  }

  static Future<void> addRecentRecipient(String email) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_recentRecipientsKey) ?? [];
    list.removeWhere((e) => e.toLowerCase() == email.toLowerCase());
    list.insert(0, email);
    if (list.length > 5) {
      list = list.sublist(0, 5);
    }
    await prefs.setStringList(_recentRecipientsKey, list);
  }

  static Future<String?> getLastCompanyName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastCompanyKey);
  }

  static Future<void> saveLastCompanyName(String company) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCompanyKey, company);
  }

  static Future<String?> getLastTone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastToneKey) ?? 'standard';
  }

  static Future<void> saveLastTone(String tone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastToneKey, tone);
  }
}
