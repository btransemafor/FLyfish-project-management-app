import 'package:to_do/features/auth/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> searchUser(String keyword); 
}
