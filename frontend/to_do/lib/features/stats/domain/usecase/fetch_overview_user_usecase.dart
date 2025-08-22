import 'package:to_do/features/stats/domain/entity/stats_overview_user_entity.dart';
import 'package:to_do/features/stats/domain/repository/stats_repository.dart';

class FetchOverviewUserUsecase {
  final StatsRepository _repo; 
  const FetchOverviewUserUsecase(this._repo); 

  Future<StatsOverviewUserEntity> call() async {
    return await _repo.fetchStatsUser();
  }
}