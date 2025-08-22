import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';

abstract class UserState extends Equatable {
  @override  
  List<Object> get props => []; 
}
class UserInitial extends UserState {}
class UserLoading extends UserState {}

class FilterUserSuccess extends UserState {
  final List<UserEntity> users; 
  
  FilterUserSuccess(this.users); 
  @override   
  List<Object> get props => [users]; 
}

class UserSearchedSuccess extends UserState {
  final List<UserEntity> users; 
  
  UserSearchedSuccess(this.users); 
  @override   
  List<Object> get props => [users]; 
}

class UserError extends UserState {
  final String error; 
  UserError(this.error); 
  @override   
  List<Object> get props => [error]; 
}