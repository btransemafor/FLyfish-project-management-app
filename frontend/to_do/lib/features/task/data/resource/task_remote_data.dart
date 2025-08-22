import 'package:dio/dio.dart';
import 'package:to_do/core/networks/dio_client.dart';
import 'package:to_do/features/task/data/models/task_model.dart';
import 'package:to_do/features/task/domain/entities/task_entity.dart';

abstract class TaskRemoteData {
  Future<List<TaskModel>> fetchTask([String? status, int? countNearestCurrent]);
  Future<List<TaskModel>> fetchTasksByProject([String? projectId]);
  Future<TaskModel> updateTask(
      String taskId, Map<String, dynamic> updateFields);
  Future<TaskModel> createTask(Map<String, dynamic> fieldTask);

  Future<TaskModel> fetchTaskById(String id);

  Future<bool> deteleTaskById(String id);
  Future<List<TaskModel>> fetchTaskToday(); 
  Future<bool> removeUserFromTask(String user_id, String task_id); 
}

class TaskRemoteDataImpl extends TaskRemoteData {
  final Dio dio; 
  TaskRemoteDataImpl(this.dio);

  @override
  Future<List<TaskModel>> fetchTask([
    String? status,
    int? countNearestCurrent,
  ]) async {
    try {

      print('[DEBUG] Status: ${status}'); 

      final response = countNearestCurrent != null && status == null 
          ? await dio.get('/tasks/nearest',
              queryParameters: {'count': countNearestCurrent})
          : await dio.get('/tasks',
              queryParameters: status != null ? {'status': status} : null);

      final rawData = response.data;
      final data = rawData['data'] as List<dynamic>;
      final assignees = data[0]['assignees'];
      print(assignees);

      print('DATA SAU KHI FETCH: ${data[0]}');

      return data.map((item) => TaskModel.fromJson(item)).toList();
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  @override
  Future<List<TaskModel>> fetchTasksByProject([String? projectId]) async {
    try {
      final response = await dio.get(
        projectId != null ? '/projects/${projectId}/tasks' : '/tasks',
      );

      final rawData = response.data;
      final data = rawData['data'] as List<dynamic>;

      return data.map((item) => TaskModel.fromJson(item)).toList();
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  @override
  Future<TaskModel> updateTask(
      String taskId, Map<String, dynamic> updateFields) async {
    try {
      print('[field update]: ${updateFields}'); 
      final response =
          await dio.patch('/tasks/$taskId', data: updateFields);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return TaskModel.fromJson(data);
      } else {
        // Nếu status code không phải 200, xử lý thủ công
        final message = response.data['message'] ?? 'Unknown error occurred';
        throw Exception('Error ${response.statusCode}: $message');
      }
    } on DioError catch (dioError) {
      if (dioError.response != null) {
        final status = dioError.response?.statusCode;
        final message = dioError.response?.data['message'] ??
            dioError.message ??
            'Unknown Dio error';
        throw Exception('Dio Error [$status]: $message');
      } else {
        throw Exception('Connection error: ${dioError.message}');
      }
    } catch (error) {
      throw Exception('Unexpected error: ${error.toString()}');
    }
  }

  @override
  Future<TaskModel> createTask(Map<String, dynamic> fieldTask) async {
    try {
      final response = await dio.post('/tasks', data: fieldTask);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final rawData = response.data;
        final data = rawData['result'];
        return TaskModel.fromJson(data);
      } else {
        throw Exception('Created Task Failure');
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  Future<TaskModel> fetchTaskById(String id) async {
    try {
      final response = await dio.get('/tasks/$id');
      final rawData = response.data;
      final data = rawData['data'];
      return TaskModel.fromJson(data);
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  Future<bool> deteleTaskById(String id) async {
    try {
      final response = await dio.delete('/tasks/$id');

      final dataRaw = response.data;
      final success = dataRaw['success'];
      return success;
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  Future<List<TaskModel>> fetchTaskToday() async {
    final response = await dio.get('/tasks/task-today');

    final dataRaw = response.data; 
    final data = dataRaw['data']; 
    // final taskToday = data['assignedTasks'] as List<dynamic> ??; 
    final taskToday = data as List<dynamic>; 

    return taskToday.map((item) => TaskModel.fromJson(item)).toList(); 
  }
  
  @override
  Future<bool> removeUserFromTask(String user_id, String task_id) async {
    final response = await dio.delete('/tasks/remove-user-from-task', 
      data: {
        'user_id': user_id, 
        'task_id': task_id
      }
    ); 
    if (response.statusCode == 200 ) {
      return true; 
    }
    return false; 
  }
}
