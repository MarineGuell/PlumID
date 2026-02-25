import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'token_storage.g.dart';

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  final SharedPreferences _prefs;

  TokenStorage(this._prefs);

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> deleteToken() async {
    await _prefs.remove(_tokenKey);
  }

  bool hasToken() {
    return _prefs.containsKey(_tokenKey);
  }
}

@riverpod
Future<TokenStorage> tokenStorage(TokenStorageRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  return TokenStorage(prefs);
}
