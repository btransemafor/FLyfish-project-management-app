import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/auth/domain/repositories/auth_repository.dart';

class GetUserLocalUsecase {
  final AuthRepository _repository; 
  const GetUserLocalUsecase(this._repository); 

  Future<UserEntity> execute() async {
    return await _repository.getUserLocal(); 
  }
}