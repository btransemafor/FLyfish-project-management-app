import 'package:json_annotation/json_annotation.dart';

class UserEntity {
  final String userId; 
  final String name; 
  final String phone; 
  final String email; 
  final DateTime? birthDay; 
  final String avatar; 
  final bool active; 
  

  const UserEntity(
    {
    required this.avatar, 
    required this.birthDay, 
    required this.userId,
    required this.name,
    required this.email, 
    required this.phone, 
    required this.active, 
    }); 

  factory UserEntity.fromJson(Map<String,dynamic> json) {
    return UserEntity(
      avatar: json['avatar'] ?? '',
     birthDay: json['birthDay'] != null ? DateTime.tryParse(json['birthDay']) : null,
     userId: json['id'] ?? '', 
     name: json['name'] ?? '', 
     email: json['email'] ?? '', 
     phone: json['phone'] ?? '', 
     active: json['active'] ?? true, 
     ); 
  }

  factory UserEntity.empty() {
    return UserEntity(
      active: true ,
      phone: '',
      birthDay: DateTime.now(),
      userId: '',
      name: 'Unknown',
      email: '',
      avatar: '',
    );
  }

  @override
  String toString() {
    return 'User(id: $userId, name: $name, email: $email, phone: $phone, birthday: $birthDay, avatar: $avatar, active: $active)'; 
  }

/*   UserEntity toEntity() {
    return UserEntity(avatar: avatar, birthDate: birthDate, userId: userId, name: name, email: email, phone: phone, active: active); 
  } */
}

class MemberEntity extends UserEntity {
  final String? role; 

  MemberEntity({
    required super.active, 
    required super.userId, 
    required super.name, 
    required super.phone, 
    required super.birthDay, 
    required super.avatar, 
    required super.email, 
    this.role
  }); 
}