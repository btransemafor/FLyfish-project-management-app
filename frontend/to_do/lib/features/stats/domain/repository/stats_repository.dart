import 'package:to_do/features/stats/domain/entity/stats_overview_user_entity.dart';

abstract class StatsRepository {
  Future<StatsOverviewUserEntity> fetchStatsUser();
}