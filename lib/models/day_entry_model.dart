import 'package:moodly_client/models/daily_task_model.dart';
import 'package:moodly_client/models/journal_entry_model.dart';

class DayEntry {
  final String id;
  final String dayEntryDate;
  final int? mood;
  final List<JournalEntry> journalEntries;
  final List<DailyTask> dailyTasks;

  DayEntry({
    required this.id,
    required this.dayEntryDate,
    required this.mood,
    required this.journalEntries,
    required this.dailyTasks,
  });

  factory DayEntry.fromJson(Map<String, dynamic> json) {
    return DayEntry(
      id: json['_id'],
      dayEntryDate: json['dayEntryDate'],
      mood: json['mood'],
      journalEntries:
          (json['journalEntries'] as List<dynamic>)
              .map((e) => JournalEntry.fromJson(e))
              .toList(),
      dailyTasks:
          (json['dailyTasks'] as List<dynamic>)
              .map((e) => DailyTask.fromJson(e))
              .toList(),
    );
  }
}
