import '../../models/daily_task_model.dart';

abstract class DailyTaskState {}

class DailyTaskInitial extends DailyTaskState {}

class DailyTaskLoading extends DailyTaskState {}

class DailyTaskLoaded extends DailyTaskState {
  final List<DailyTask> tasks;
  DailyTaskLoaded(this.tasks);
}

class DailyTaskError extends DailyTaskState {
  final String message;
  DailyTaskError(this.message);
}
