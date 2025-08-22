import 'package:to_do/features/stats/domain/entity/stats_overview_user_entity.dart';
import 'package:to_do/features/task/domain/entities/task_entity.dart';

class StatsOverviewUserModel extends StatsOverviewUserEntity {
  const StatsOverviewUserModel(
      {super.totalProject,
      super.totalTask,
      super.totalTodayTask,
      super.listTaskToday});

  factory StatsOverviewUserModel.fromJson(Map<String, dynamic> json) {
    return StatsOverviewUserModel(
      totalProject: json['totalProject'],
      totalTask: json['totalTask'],
      totalTodayTask: json['totalTodayTask'],
      listTaskToday: json['listTaskToday'] != null
          ? (json['listTaskToday'] as List)
              .map((item) => TaskEntity.fromJson(item))
              .toList()
          : [],
    );
  }
}
