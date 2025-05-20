class DailyTask {
  final String id;
  final String name;
  final bool isDone;

  DailyTask({required this.id, required this.name, required this.isDone});

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      id: json['_id'],
      name: json['name'],
      isDone: json['isDone'],
    );
  }
}