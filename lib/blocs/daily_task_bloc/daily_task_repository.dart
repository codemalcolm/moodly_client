import 'dart:convert';
import 'package:http/http.dart' as http;

class DailyTaskRepository {
  final String baseUrl = 'http://10.0.2.2:5000/api/v1';

  Future<void> toggleIsDone(String dayId, String taskId, bool isDone) async {
    final url = Uri.parse('$baseUrl/days/$dayId/daily-tasks/$taskId');
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'isDone': isDone}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task status');
    }
  }

  Future<void> editTask(String dayId, String taskId, String name) async {
    final url = Uri.parse('$baseUrl/days/$dayId/daily-tasks/$taskId');
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit task');
    }
  }

  Future<void> deleteTask(String dayId, String taskId) async {
    final url = Uri.parse('$baseUrl/days/$dayId/daily-tasks/$taskId');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }
}
