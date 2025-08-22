import 'dart:async';

import 'package:to_do/core/socket/socket_manager.dart';
import 'package:to_do/core/storage/token_manage.dart';
import 'package:to_do/features/auth/data/data_source/auth_data_remote.dart';
import 'package:to_do/features/auth/data/data_source/auth_local_data_source.dart';
import 'package:to_do/features/auth/data/data_source/remember_account_local_data_scource.dart';
import 'package:to_do/features/auth/data/models/user_model.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/auth/domain/repositories/auth_repository.dart';
import 'package:to_do/injection.dart' as di;

class AuthRepositoriesImpl implements AuthRepository {
  final AuthDataRemote _authDataRemote;
  final AuthLocalDataSource _authLocalDataSource;
  final RememberAccountLocalDataScource _accountLocalDataScource;
  final StreamController<AuthStatus> _authStatusController;

  AuthRepositoriesImpl(this._accountLocalDataScource, this._authDataRemote,
      this._authLocalDataSource)
      : _authStatusController = StreamController<AuthStatus>.broadcast();

  @override
  Stream<AuthStatus> get authStatusStream => _authStatusController.stream;

  @override
  Future<UserEntity> loginWithEmail(String email, String password) async {
    try {
      final _userData = await _authDataRemote.loginWithEmail(email, password);
      await _authLocalDataSource.saveUser(_userData);

      di.getIt<TokenManage>().saveToken(_userData.accessToken);
      di.getIt<TokenManage>().saveRefreshToken(_userData.refreshToken!);

      // Initialize socket with the new token
      final SocketManager _socketManager = di.getIt<SocketManager>();
      await _socketManager.init();

      return UserEntity(
          avatar: _userData.avatar,
          birthDay: _userData.birthDay,
          userId: _userData.userId,
          name: _userData.name,
          email: _userData.email,
          phone: _userData.phone,
          active: _userData.active);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<UserEntity> getUserLocal() async {
    try {
      final _userData = await _authLocalDataSource.getUser();
      if (_userData != null) {
        return UserEntity(
          avatar: _userData.avatar,
          birthDay: _userData.birthDay,
          userId: _userData.userId,
          name: _userData.name,
          email: _userData.email,
          phone: _userData.phone,
          active: _userData.active,
        );
      } else {
        throw Exception("User not found in local");
      }
    } catch (error) {
      throw Exception('Load User Local Failure $error');
    }
  }

  @override
  Future<bool> logout() async {
    final result = await _authDataRemote.logout();
    if (result) {
      di.getIt<TokenManage>().clearToken();
    }
    return result;
  }

  @override
  Future<void> refreshAccessToken() async {
    final refreshToken = di.getIt<TokenManage>().getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      _authStatusController.add(AuthStatus.unauthenticated);
      throw Exception('Loi Roi');
    }
    final accessToken = await _authDataRemote.refreshAccessToken(refreshToken);

    // Lưu token mới

    if (accessToken != null) {
      await di.getIt<TokenManage>().saveToken(accessToken);
    }

    _authStatusController.add(AuthStatus.authenticated);
  }

  // Xử lý khi refresh token thất bại
  Future<void> _handleTokenRefreshFailure() async {
    await logout();
  }

  void dispose() {
    _authStatusController.close();
  }
}
