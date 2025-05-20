abstract class DailyTaskEvent {}

class LoadDailyTasks extends DailyTaskEvent {
  final String dayId;
  LoadDailyTasks(this.dayId);
}

class AddDailyTask extends DailyTaskEvent {
  final String dayId;
  final String name;
  AddDailyTask(this.dayId, this.name);
}

class ToggleTaskDone extends DailyTaskEvent {
  final String dayId;
  final String taskId;
  final bool isDone;
  ToggleTaskDone(this.dayId, this.taskId, this.isDone);
}

class EditDailyTask extends DailyTaskEvent {
  final String dayId;
  final String taskId;
  final String newName;
  EditDailyTask(this.dayId, this.taskId, this.newName);
}

class DeleteDailyTask extends DailyTaskEvent {
  final String dayId;
  final String taskId;
  DeleteDailyTask(this.dayId, this.taskId);
}