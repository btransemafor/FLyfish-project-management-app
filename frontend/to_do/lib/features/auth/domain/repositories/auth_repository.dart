import 'package:to_do/features/auth/domain/entities/user_entity.dart';
// 3. Auth Status Enum
enum AuthStatus {
  authenticated,
  unauthenticated,
  loading,
  tokenExpired
}
abstract class AuthRepository {
  Future<UserEntity> loginWithEmail(String email, String password); 
  Future<UserEntity> getUserLocal(); 
  Future<bool> logout();
  Future<void> refreshAccessToken();
  Stream<AuthStatus> get authStatusStream;
}