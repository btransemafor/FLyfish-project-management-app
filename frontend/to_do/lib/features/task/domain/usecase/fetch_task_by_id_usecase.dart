import 'package:flutter/material.dart';
import 'package:to_do/features/task/domain/entities/task_entity.dart';
import 'package:to_do/features/task/domain/repository/task_repository.dart';

class FetchTaskByIdUsecase {
  final TaskRepository _repo;
  const FetchTaskByIdUsecase(this._repo); 

  Future<TaskEntity> execute(String id) async {
    return await _repo.fetchTaskById(id);
  }
}