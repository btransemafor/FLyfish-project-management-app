import 'package:dio/dio.dart';
import 'package:to_do/core/networks/dio_client.dart';
import 'package:to_do/features/auth/data/models/user_model.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';

abstract class UserRemoteData {
  Future<List<UserEntity>> searchUser(String keyword); 
}

class UserRemoteDataImpl extends UserRemoteData {
  final Dio dio; 
  UserRemoteDataImpl(this.dio); 

  @override
  Future<List<UserModel>> searchUser(String keyword) async {
    try {
      final response = await dio.get('/users/search', queryParameters: {
        'keyword': keyword
      }); 

      if (response.statusCode == 200) {
        final dataRaw = response.data; 
        final data = dataRaw['data'] as List; 

        return data.map((item) => UserModel.fromJson(item)).toList() ?? []; 
      }
      else {
        throw Exception('Error'); 
      }
    }
    catch(error) {
      throw Exception(error); 
    }
    
  }

}