import 'package:dio/dio.dart';
import 'package:to_do/core/networks/dio_client.dart';
import 'package:to_do/features/stats/data/models/stats_overview_user_model.dart';

abstract class StatsRemote {
  Future<StatsOverviewUserModel> fetchStatsUser(); 
}
class StatsRemoteImpl implements StatsRemote {
  final Dio dio; 
  StatsRemoteImpl(this.dio); 

  @override     
  Future<StatsOverviewUserModel> fetchStatsUser() async {
    final response = await dio.get('/users/stats-overview'); 

    final dataRaw = response.data; 
    final data = dataRaw['data']; 

    return StatsOverviewUserModel.fromJson(data); 
  }
}