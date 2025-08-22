import 'package:equatable/equatable.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object> get props => []; 
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  
}

class UserLogoutSuccess extends AuthState {}

class UserLoginSuccess extends AuthState {

  final UserEntity user; 
  UserLoginSuccess(this.user); 
  @override
  List<Object> get props => [user]; 
}

class UserLoginFailure extends AuthState {
  final String message;
  UserLoginFailure(this.message); 
  @override
  List<Object> get props => [message];
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  
  @override
  List<Object> get props => [message];
}

// Khi đang lấy dữ liệu user từ local
class GetLocalUserLoading extends AuthState {}

// Khi lấy user local thành công
class GetLocalUserSuccess extends AuthState {
  final UserEntity user;

  GetLocalUserSuccess(this.user);

  @override
  List<Object> get props => [user];
}

// Khi thất bại
class GetLocalUserFailure extends AuthState {
  final String message;

  GetLocalUserFailure(this.message);

  @override
  List<Object> get props => [message];
}

class AuthLogoutSuccess extends AuthState {}

class AuthLogoutFailure extends AuthState {
  final String message; 
  AuthLogoutFailure(this.message); 
  @override
  List<Object> get props => [message];
}

class CacheUserLoaded extends AuthState {
  final UserEntity user;
  CacheUserLoaded(this.user); 
  @override    
  List<Object> get props => [user];
}