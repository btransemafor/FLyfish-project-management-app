import 'package:equatable/equatable.dart';
abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => []; 
}

class LoginWithEmail extends AuthEvent {
  final String email; 
  final String password; 

  LoginWithEmail(this.email, this.password); 
  @override   
  List<Object> get props => [email,password]; 
}

class GetLocalUser extends AuthEvent {
  
}

class LogoutEvent extends AuthEvent {}

class LoadCacheUser extends AuthEvent {
  
}