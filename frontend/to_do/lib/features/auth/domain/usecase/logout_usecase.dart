import 'package:to_do/features/auth/domain/repositories/auth_repository.dart';

class LogoutUsecase {
  final AuthRepository _repo; 
  const LogoutUsecase(this._repo); 
  
  Future<bool> call() async {
    return await _repo.logout(); 
  }
}