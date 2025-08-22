// features/auth/data/datasources/auth_local_data_source.dart

import 'package:hive/hive.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  UserModel? getUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box<UserModel> userBox;

  AuthLocalDataSourceImpl(this.userBox);

  @override
  Future<void> saveUser(UserModel user) async {
    print('Đang tiến hành lưu user ${user.userId}');
    await userBox.put('loggedInUser', user);
  }

  @override
  UserModel? getUser() {
    return userBox.get('loggedInUser');
  }
}

