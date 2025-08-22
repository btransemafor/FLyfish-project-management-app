import 'package:hive/hive.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel implements UserEntity {
  @HiveField(0)
  @override
  final String userId;

  @HiveField(1)
  @override
  final String name;

  @HiveField(2)
  @override
  final String email;

  @HiveField(3)
  @override
  final String phone;

  @HiveField(4)
  @override
  final DateTime birthDay;

  @HiveField(5)
  @override
  final String avatar;

  @HiveField(6)
  @override
  final bool active;

  @HiveField(7)
  final String accessToken;

  @HiveField(8)
  final String? refreshToken;

  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDay,
    required this.avatar,
    required this.active,
    required this.accessToken,
    required this.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      birthDay: DateTime.tryParse(json['birthday']) ?? DateTime(1970, 1, 1), 
      avatar: json['avatar'] ?? 'https://res.cloudinary.com/dehehzz2t/image/upload/v1754380108/z6875846732207_42d1b4240a1cb3a27f03f8ccf4b45030_ap9iai.jpg',
      active: json['active'] ?? true,
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
  return {
    'id': userId,
    'name': name,
    'email': email,
    'phone': phone,
    'birthday': birthDay.toIso8601String(),
    'avatar': avatar,
    'active': active,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
  };
}

}
