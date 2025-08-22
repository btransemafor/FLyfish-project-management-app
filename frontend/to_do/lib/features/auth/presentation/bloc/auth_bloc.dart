import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/auth/domain/usecase/get_user_local_usecase.dart';
import 'package:to_do/features/auth/domain/usecase/login_with_email_usecase.dart';
import 'package:to_do/features/auth/domain/usecase/logout_usecase.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_event.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmailUsecase _loginWithEmailUsecase;
  final GetUserLocalUsecase _getUserLocalUsecase;
  final LogoutUsecase _logoutUsecase;
  String user_id = '';

  UserEntity? user;

  AuthBloc(this._loginWithEmailUsecase, this._getUserLocalUsecase,
      this._logoutUsecase)
      : super(AuthInitial()) {
    on<LoginWithEmail>(_onLoginWithEmail);
    on<GetLocalUser>(_onGetUserLocal);
    on<LogoutEvent>(_onLogout);
    on<LoadCacheUser>(_onLoadCacheUser);
  }

  Future<void> _onLoginWithEmail(
      LoginWithEmail event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    // await Future.delayed(Duration(seconds: 3)); //  Delay 3 giây

    try {
      final user =
          await _loginWithEmailUsecase.call(event.email, event.password);
      emit(UserLoginSuccess(user));
    } catch (e) {
      emit(UserLoginFailure(e.toString()));
    }
  }

  Future<void> _onGetUserLocal(
      GetLocalUser event, Emitter<AuthState> emit) async {
    try {
      emit(GetLocalUserLoading());
      final userLocal = await _getUserLocalUsecase.execute();
      user_id = userLocal.userId;
      user = userLocal;
      emit(GetLocalUserSuccess(userLocal));
    } catch (error) {
      emit(GetLocalUserFailure('Load User Local Failure!'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _logoutUsecase.call();

      if (result) {
        emit(AuthLogoutSuccess());
      } else {
        emit(AuthLogoutFailure('Đăng xuất không thành công'));
      }
    } catch (error) {
      emit(AuthLogoutFailure('Đăng xuất không thành công'));
    }
  }

  Future<void> _onLoadCacheUser(
      LoadCacheUser event, Emitter<AuthState> emit) async {
    if (user != null) {
      emit(GetLocalUserSuccess(user!));
    } else {
      final userLocal = await _getUserLocalUsecase.execute();
      user_id = userLocal.userId;
      user = userLocal;
      emit(GetLocalUserSuccess(userLocal));
    }
  }
}
