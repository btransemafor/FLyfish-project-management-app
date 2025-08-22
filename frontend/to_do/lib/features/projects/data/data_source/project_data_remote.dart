import 'package:dio/dio.dart';
import 'package:to_do/core/networks/dio_client.dart';
import 'package:to_do/features/auth/data/models/user_model.dart';
import 'package:to_do/features/projects/data/model/project_member_model.dart';
import 'package:to_do/features/projects/data/model/project_model.dart';

abstract class ProjectDataRemote {
  Future<List<ProjectModel>> fetchListProject([bool? isLeader]);
  Future<List<ProjectMemberModel>> fetchMemberByProject(String projectId);
  Future<ProjectModel> createProject(
    String name,
    String description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String leader_id,
  );

  Future<String> addMemberIntoProject(String user_id, String project_id); 
  Future<ProjectModel> fetchProjectById(String project_id);
}

class ProjectDataRemoteImpl extends ProjectDataRemote {
  final Dio _dioClient ;

  ProjectDataRemoteImpl(this._dioClient); 

  @override
  Future<List<ProjectModel>> fetchListProject([bool? isLeader]) async {
    try {
      var response = isLeader == true
          ? await _dioClient
              .get('/projects', queryParameters: {'is_leader': isLeader})
          : await _dioClient.get('/projects');

      final dataRaw = response.data as Map<String, dynamic>;
      if (dataRaw['data'] is! List) {
        throw Exception('Invalid data format');
      }

      final data = dataRaw['data'] as List;
      print(data); 

      return data.map((item) => ProjectModel.fromJson(item)).toList();
    } catch (error) {
      throw Exception('Failed to fetch project list: $error');
    }
  }

  @override
  Future<List<ProjectMemberModel>> fetchMemberByProject(
      String projectId) async {
    try {
      var response = await _dioClient.get('/projects/$projectId/members');

      final dataRaw = response.data;
      final data = dataRaw['data']['member'] as List;

      return data.map((item) => ProjectMemberModel.fromJson(item)).toList();
    } catch (error) {
      throw Exception('Fail $error');
    }
  }

  @override
  Future<ProjectModel> createProject(
    String name,
    String description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String leader_id,
  ) async {
    try {
      var response = await _dioClient.post('/projects', data: {
        'name': name,
        'description': description,
        'startDate': startDate.toString(),
        'endDate': endDate.toString(),
        'status': status,
        'leader_id': leader_id
      });

      final data = response.data['data'] as Map<String,dynamic> ;

      ProjectModel proModel = ProjectModel.fromJson(data); 
      print(proModel.description);

      return ProjectModel.fromJson(data);
    } catch (error) {
      throw Exception(error);
    }
  }

  @override    
  Future<String> addMemberIntoProject(String user_id, String project_id) async {
    try {
        final response = await _dioClient.post('/projects/add-member', data: {
            "user_id": user_id, 
            "project_id": project_id
        });



        if (response.statusCode == 201) {
          final data = response.data; 
          final result = data['data']; 
          return result; 
        }
        else {
          return '' ; 
        }
    }
    catch(error) {
        throw Exception('Error: No Can Added Member $error'); 
    }
  }

  @override
Future<ProjectModel> fetchProjectById(String project_id) async {
  try {
    final response = await _dioClient.get('/projects/$project_id'); 
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      final result = data['data'];
      return ProjectModel.fromJson(result);
    } else {
      // Trường hợp không phải 200/201
      throw Exception('Failed to fetch project: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Error: Cannot fetch project - $error');
  }
}

}
