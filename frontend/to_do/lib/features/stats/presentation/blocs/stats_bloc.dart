import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do/features/stats/domain/usecase/fetch_overview_user_usecase.dart';
import 'stats_event.dart';
import 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final FetchOverviewUserUsecase _fetchOverviewUserUsecase; 

  StatsBloc(this._fetchOverviewUserUsecase) : super(StatsInitial()) {
    on<LoadStatsUser>(_onLoadStatsUser);
  }

  Future<void> _onLoadStatsUser(
    LoadStatsUser event,
    Emitter<StatsState> emit,
  ) async {
    emit(StatsLoading());
    try {
      final data = await _fetchOverviewUserUsecase.call(); 
      emit(StatsLoaded(data));
    } catch (e) {
      emit(StatsError(e.toString()));
    }
  }
}
