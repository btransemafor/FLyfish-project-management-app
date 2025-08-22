import 'package:equatable/equatable.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';

abstract class UserEvent extends Equatable {
  @override   
  List<Object> get props => []; 
}

class FilterUserByRole extends UserEvent {
  final String role; 
  final List<UserEntity> users; 
  FilterUserByRole(this.role, this.users); 
  @override   
  List<Object> get props => [role, users]; 
}

class SearchUserByKeyWord extends UserEvent {
  final String keyword; 
  SearchUserByKeyWord(this.keyword); 
  @override   
  List<Object> get props => [keyword]; 
}
