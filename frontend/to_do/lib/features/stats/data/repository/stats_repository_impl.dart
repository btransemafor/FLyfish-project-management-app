import 'package:to_do/features/stats/data/source/stats_remote.dart';
import 'package:to_do/features/stats/domain/entity/stats_overview_user_entity.dart';
import 'package:to_do/features/stats/domain/repository/stats_repository.dart';

class StatsRepositoryImpl implements StatsRepository {
  final StatsRemote statsRemote;
  const StatsRepositoryImpl(this.statsRemote); 
  @override
  Future<StatsOverviewUserEntity> fetchStatsUser() async {
    final model = await statsRemote.fetchStatsUser(); 
    return StatsOverviewUserEntity(
      totalProject: model.totalProject, 
      totalTask: model.totalTask, 
      totalTodayTask: model.totalTodayTask, 
      listTaskToday: model.listTaskToday
    );
  }
}