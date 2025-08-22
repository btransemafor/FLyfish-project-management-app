import 'dart:math';

import 'package:dio/dio.dart';
import 'package:to_do/core/networks/dio_client.dart';
import 'package:to_do/core/storage/token_manage.dart';
import 'package:to_do/features/auth/data/models/user_model.dart';
import 'package:to_do/injection.dart';

abstract class AuthDataRemote {
  Future<UserModel> loginWithEmail(String email, String password);
  Future<bool> logout();
  Future<String> refreshAccessToken(String refreshToken);
}

class AuthDataSourceImpl implements AuthDataRemote {
  Dio dio; 
  AuthDataSourceImpl(this.dio);
  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final response = await dio
          .post('/auth/login', data: {'email': email, 'password': password});

      final data = response.data as Map<String, dynamic>;

      return UserModel.fromJson(data['data']);
    } catch (error) {
      throw '$error';
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final response = await dio.get('/auth/logout');
      final dataRaw = response.data;
      final result = dataRaw['success'];
      return result;
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  Future<String> refreshAccessToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '/auth/request-new-accessToken',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        print(response.data);
        final data = response.data['data'];
        print('[DATA: Get access Token: ${data} ');
        final newToken = data;
        /*  print(newToken); 

      if (newToken != null && newToken.isNotEmpty) {
        // Delete token cu 
        await getIt<TokenManage>().deleteToken();
        print('[DELETE] Đã xóa access Token cũ');
        await getIt<TokenManage>().saveToken(newToken);
        return true;
      } */
        return newToken;
      } else {
        throw Exception(e);
      }
    } catch (e, stack) {
      print('[ERROR] refreshAccessToken: $e');
      throw Exception();
    }
  }
}
