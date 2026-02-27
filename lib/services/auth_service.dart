import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  SharedPreferences? _prefs;

  static const String _keyPasswordHash = 'password_hash';
  static const String _keyIsSetup = 'is_setup';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get isSetup => _prefs?.getBool(_keyIsSetup) ?? false;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<bool> setPassword(String password) async {
    try {
      final hash = _hashPassword(password);
      await _prefs?.setString(_keyPasswordHash, hash);
      await _prefs?.setBool(_keyIsSetup, true);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool verifyPassword(String password) {
    final savedHash = _prefs?.getString(_keyPasswordHash);
    if (savedHash == null) return false;
    
    final inputHash = _hashPassword(password);
    return inputHash == savedHash;
  }

  Future<void> resetPassword() async {
    await _prefs?.remove(_keyPasswordHash);
    await _prefs?.setBool(_keyIsSetup, false);
  }
}
