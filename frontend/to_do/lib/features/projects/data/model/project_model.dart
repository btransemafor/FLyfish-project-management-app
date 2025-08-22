// lib/features/projects/data/models/project_model.dart
import 'package:flutter/material.dart';
import 'package:to_do/features/auth/data/models/user_model.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/projects/domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity{
  final String id;
  final String name;
  final String description;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final String leaderId;
  final int numberMember; 
  final List<UserModel> members;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.leaderId,
    this.members = const [],
    required this.numberMember, 
    super.numberCompletedTask, 
    super.numberTask
  }):super(
    description: description,
     id: id,
      name: name,
       status: status, 
       startDate: startDate, 
       endDate: endDate, 
       leader_id: leaderId, 
       members: members, 
       numberMember: numberMember 
       ); 

/*   factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      numberMember: 0, // test
      id: json['project_id'],
      name: json['name'],
      description: json['description'] ?? '',
      status: json['status'] ?? 'unknown',
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null, // json['endData'] != null ? DateTime.parse(json['endDate']) : null,
      leaderId: json['leader_id'],
      //color: json['color'] ?? '#2196F3',
      members: (json['members'] as List?)?.map((m) => UserModel.fromJson(m)).toList() ?? [],

      numberCompletedTask: (json['numberCompletedTask'] is int) ? json['numberCompletedTask'] : int.tryParse(json['numberCompletedTask']), 
      numberTask: json['numberTask'] ?? 0 
    );
  }

 */

factory ProjectModel.fromJson(Map<String, dynamic> json) {
  return ProjectModel(
    numberMember: 0,
    id: json['project_id'],
    name: json['name'],
    description: json['description'] ?? '',
    status: json['status'] ?? 'unknown',
    startDate: json['startDate'] != null
        ? DateTime.tryParse(json['startDate']) ?? DateTime.now()
        : DateTime.now(),
    endDate: json['endDate'] != null
        ? DateTime.tryParse(json['endDate'])
        : null,
    leaderId: json['leader_id'],
    members: (json['members'] as List?)?.map((m) => UserModel.fromJson(m)).toList() ?? [],
    numberCompletedTask: (json['numberCompletedTask'] is int)
        ? json['numberCompletedTask']
        : int.tryParse(json['numberCompletedTask']?.toString() ?? '0') ?? 0,
    numberTask: (json['numberTask'] is int)
        ? json['numberTask']
        : int.tryParse(json['numberTask']?.toString() ?? '0') ?? 0,
  );
}



  ProjectEntity toEntity() {
    return ProjectEntity(
      numberMember: 0,
      id: id,
      name: name,
      description: description,
      status: status,
      startDate: startDate,
      endDate: endDate,
      leader_id: leaderId,
      //color: colorFromHex(color),
      
    );
  }
}

String colorToHex(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
}

Color colorFromHex(String hex) {
  final hexCode = hex.replaceFirst('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}