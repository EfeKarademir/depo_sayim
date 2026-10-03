import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/kullanici_model.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _keyRemember = 'auth_remember_me';
  static const _keyUserJson = 'auth_user_json';

  Future<void> saveSession(Kullanici kullanici, {required bool hatirla}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRemember, hatirla);
    if (hatirla) {
      await prefs.setString(_keyUserJson, kullanici.toJsonString());
    } else {
      await prefs.remove(_keyUserJson);
    }
  }

  Future<Kullanici?> getSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final hatirla = prefs.getBool(_keyRemember) ?? false;
    if (!hatirla) return null;

    final json = prefs.getString(_keyUserJson);
    if (json == null) return null;
    return Kullanici.fromJsonString(json);
  }

  Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRemember) ?? false;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRemember);
    await prefs.remove(_keyUserJson);
  }
}
