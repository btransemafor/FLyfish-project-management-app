import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/users/domain/repository/user_repository.dart';

class SearchUserByKeywordUsecase {
  final UserRepository _repo; 
  SearchUserByKeywordUsecase(this._repo); 

  Future<List<UserEntity>> execute(String keyword)async {
    return await _repo.searchUser(keyword);
  }
}