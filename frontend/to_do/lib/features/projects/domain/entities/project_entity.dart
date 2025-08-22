import 'package:to_do/features/auth/domain/entities/user_entity.dart';

class ProjectEntity {
  final String id; 
  final String name;
  final String description; 
  final DateTime startDate; 
  final DateTime? endDate; 
  final String status; 
  final String leader_id; 
  final UserEntity? leader; 
  final int numberMember; 
  final List<UserEntity> members; 
  final int numberTask; 
  final int numberCompletedTask; 
  const ProjectEntity({
    required this.id, 
    required this.name, 
    required this.description, 
    required this.startDate, 
    required this.status,
    required this.numberMember, 
    this.endDate, 
    required this.leader_id, 
    this.leader, 
    this.members = const [], // this.members = const [], // Default to empty list
    this.numberCompletedTask = 0, 
    this.numberTask = 0 
    
  }); 

  // CopyWith 
  ProjectEntity copyWith({
  String? id,
  String? name,
  String? description,
  DateTime? startDate,
  DateTime? endDate,
  String? status,
  String? leader_id,
  UserEntity? leader,
  int? numberMember,
  List<UserEntity>? members,
  int? numberTask,
  int? numberCompletedTask,
}) {
  return ProjectEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    status: status ?? this.status,
    leader_id: leader_id ?? this.leader_id,
    leader: leader ?? this.leader,
    numberMember: numberMember ?? this.numberMember,
    members: members ?? this.members,
    numberTask: numberTask ?? this.numberTask,
    numberCompletedTask: numberCompletedTask ?? this.numberCompletedTask,
  );
}

 @override
  String toString() {
    return 'ProjectEntity('
        'id: $id, '
        'name: $name, '
        'status: $status, '
        'startDate: $startDate, '
        'endDate: $endDate, '
        'leader_id: $leader_id, '
        'numberMember: $numberMember, '
        'numberTask: $numberTask, '
        'numberCompletedTask: $numberCompletedTask'
        ')';
  }


}

