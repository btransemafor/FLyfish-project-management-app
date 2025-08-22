// lib/core/storage/token_manage.dart
import 'package:hive/hive.dart';

class TokenManage {
  final String _boxName = 'authBox';
  final String _tokenKey = 'authToken';
  final String _refreshTokenKey = 'refreshToken'; 
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  Future<void> saveToken(String token) async {
    await _box.put(_tokenKey, token);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _box.put(_refreshTokenKey, refreshToken ); 
  }

  String? getRefreshToken() {
    return _box.get(_refreshTokenKey); 
  }

  String? getToken() {
    return _box.get(_tokenKey);
  }

  Future<void> deleteToken() async {
    await _box.delete(_tokenKey);
  }

  Future<void> clearToken() async {
    await _box.delete(_tokenKey);
    await _box.delete(_refreshTokenKey);
  }

  bool hasToken() {
    return _box.containsKey(_tokenKey);
  }

  Future<void> close() async {
    await _box.close();
  }
}