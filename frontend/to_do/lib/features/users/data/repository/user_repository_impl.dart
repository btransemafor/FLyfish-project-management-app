import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/users/data/data_source/user_remote_data.dart';
import 'package:to_do/features/users/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteData userRemoteData; 
  const UserRepositoryImpl(this.userRemoteData); 
  @override
  Future<List<UserEntity>> searchUser(String keyword) async {
    final data = await userRemoteData.searchUser(keyword); 
    return data.map((e) => UserEntity(
      avatar: e.avatar, birthDay: e.birthDay, 
      userId: e.userId, name: e.name, email: e.email, phone: e.phone, active: e.active)).toList(); 
  }
}