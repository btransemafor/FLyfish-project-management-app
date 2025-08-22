import 'package:to_do/features/task/domain/entities/task_entity.dart';

class StatsOverviewUserEntity {
  final int totalProject; 
  final int totalTask; 
  final int totalTodayTask; 
  final List<TaskEntity> listTaskToday; 

  const StatsOverviewUserEntity({
    this.totalProject = 0, 
    this.totalTask = 0, 
    this.totalTodayTask = 0, 
    this.listTaskToday = const []
  }); 
/*    "user_id": "5e53a3d9-369e-46b4-9562-2c627c4ef350",
        "totalProject": 18,
        "totalTask": 9,
        "totalTodayTask": 1,
        "listTaskToday": */
}