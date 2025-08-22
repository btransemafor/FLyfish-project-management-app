import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/auth/domain/repositories/auth_repository.dart';

class LoginWithEmailUsecase {
  final AuthRepository _repository; 
  LoginWithEmailUsecase(this._repository); 
  Future<UserEntity> call(String email, String password) async {
    print('OMGNICE'); 
    print(await _repository.loginWithEmail(email, password));
    return await _repository.loginWithEmail(email, password); 
  }
}