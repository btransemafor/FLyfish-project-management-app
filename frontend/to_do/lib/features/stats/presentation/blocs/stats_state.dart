import 'package:equatable/equatable.dart';
import 'package:to_do/features/stats/domain/entity/stats_overview_user_entity.dart';

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

// Initial state
class StatsInitial extends StatsState {}

// Loading state
class StatsLoading extends StatsState {}

// Loaded state
class StatsLoaded extends StatsState {
  final StatsOverviewUserEntity data;
  const StatsLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

// Error state
class StatsError extends StatsState {
  final String message;
  const StatsError(this.message);

  @override
  List<Object?> get props => [message];
}
