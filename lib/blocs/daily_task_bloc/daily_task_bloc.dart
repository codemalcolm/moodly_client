import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:moodly_client/blocs/daily_task_bloc/daily_task_event.dart';
import 'package:moodly_client/blocs/daily_task_bloc/daily_task_repository.dart';
import 'package:moodly_client/blocs/daily_task_bloc/daily_task_state.dart';
import 'package:moodly_client/models/daily_task_model.dart';

class DailyTaskBloc extends Bloc<DailyTaskEvent, DailyTaskState> {
  DailyTaskBloc(DailyTaskRepository read) : super(DailyTaskInitial()) {
    on<LoadDailyTasks>(_onLoad);
    on<AddDailyTask>(_onAdd);
    on<ToggleTaskDone>(_onToggle);
    on<EditDailyTask>(_onEdit);
    on<DeleteDailyTask>(_onDelete);
  }

  Future<void> _onLoad(LoadDailyTasks event, Emitter emit) async {
    emit(DailyTaskLoading());
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/v1/days/${event.dayId}'),
      );
      final json = jsonDecode(response.body);
      final tasks =
          (json['dayEntry']['dailyTasks'] as List)
              .map((e) => DailyTask.fromJson(e))
              .toList();
      emit(DailyTaskLoaded(tasks));
    } catch (e) {
      emit(DailyTaskError('Failed to load tasks'));
    }
  }

  Future<void> _onAdd(AddDailyTask event, Emitter emit) async {
    try {
      final url = Uri.parse(
        'http://10.0.2.2:5000/api/v1/days/${event.dayId}/daily-tasks',
      );

      print("We are running !!!!");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': event.name, 'isDone': false}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final newTask = DailyTask.fromJson(decoded['dailyTask']);

        if (state is DailyTaskLoaded) {
          final currentTasks = List<DailyTask>.from(
            (state as DailyTaskLoaded).tasks,
          );
          currentTasks.add(newTask);
          emit(DailyTaskLoaded(currentTasks));
        } else {
          // fallback: reload all tasks from backend
          add(LoadDailyTasks(event.dayId));
        }
      } else {
        emit(DailyTaskError('Failed to create task: ${response.body}'));
      }
    } catch (e, stack) {
      print('❌ Error creating task: $e');
      print(stack);
      emit(DailyTaskError('Exception creating task: $e'));
    }
  }

  Future<void> _onToggle(ToggleTaskDone event, Emitter emit) async {
    try {
      await http.patch(
        Uri.parse(
          'http://10.0.2.2:5000/api/v1/days/${event.dayId}/daily-tasks/${event.taskId}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isDone': event.isDone}),
      );
      add(LoadDailyTasks(event.dayId));
    } catch (e) {
      emit(DailyTaskError('Failed to update task'));
    }
  }

  Future<void> _onEdit(EditDailyTask event, Emitter emit) async {
    try {
      await http.patch(
        Uri.parse(
          'http://10.0.2.2:5000/api/v1/days/${event.dayId}/daily-tasks/${event.taskId}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': event.newName}),
      );
      add(LoadDailyTasks(event.dayId));
    } catch (e) {
      emit(DailyTaskError('Failed to edit task'));
    }
  }

  Future<void> _onDelete(DeleteDailyTask event, Emitter emit) async {
    try {
      await http.delete(
        Uri.parse(
          'http://10.0.2.2:5000/api/v1/days/${event.dayId}/daily-tasks/${event.taskId}',
        ),
      );
      add(LoadDailyTasks(event.dayId));
    } catch (e) {
      emit(DailyTaskError('Failed to delete task'));
    }
  }
}
