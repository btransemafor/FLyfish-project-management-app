import 'package:to_do/core/storage/token_manage.dart';
import 'package:to_do/features/auth/domain/repositories/auth_repository.dart';
import 'package:to_do/injection.dart';

class RefreshAccesstokenUsecase {
  final AuthRepository _repo; 
  const RefreshAccesstokenUsecase(this._repo); 
  Future<void> execute() async {
  final refreshToken = getIt<TokenManage>().getRefreshToken();
  await _repo.refreshAccessToken();
  print('[Refresh Access Token :${refreshToken}');
}
}