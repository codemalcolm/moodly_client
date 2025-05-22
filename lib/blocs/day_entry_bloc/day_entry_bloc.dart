import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:moodly_client/models/day_entry_model.dart';
import 'day_entry_event.dart';
import 'day_entry_state.dart';

class DayEntryBloc extends Bloc<DayEntryEvent, DayEntryState> {
  DayEntry? _currentDayEntry;

  DayEntryBloc() : super(DayEntryInitial()) {
    on<FetchDayEntry>(_onFetchDayEntry);
    on<CreateDayEntry>(_onCreateDayEntry);
    on<UpdateMood>(_onUpdateMood);
  }

  Future<void> _onFetchDayEntry(
    FetchDayEntry event,
    Emitter<DayEntryState> emit,
  ) async {
    emit(DayEntryLoading());

    final formattedDate = event.date.toIso8601String().split("T").first;
    final uri = Uri.parse(
      'http://10.0.2.2:5000/api/v1/days?date=$formattedDate',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['dayEntry'] != null) {
          final entry = DayEntry.fromJson(jsonResponse['dayEntry']);
          _currentDayEntry = entry;
          emit(DayEntryLoaded(entry));
        } else {
          add(CreateDayEntry(formattedDate));
        }
      } else {
        emit(DayEntryError("Failed to fetch day entry."));
      }
    } catch (e) {
      emit(DayEntryError("Error fetching day entry: $e"));
    }
  }

  Future<void> _onCreateDayEntry(
    CreateDayEntry event,
    Emitter<DayEntryState> emit,
  ) async {
    final uri = Uri.parse('http://10.0.2.2:5000/api/v1/days');
    final requestBody = {
      "dayEntryDate": event.formattedDate,
      "mood": -1,
      "dailyTasks": [],
      "journalEntries": [],
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        final entry = DayEntry.fromJson(jsonResponse['dayEntry']);
        _currentDayEntry = entry;
        emit(DayEntryLoaded(entry));
      } else {
        emit(DayEntryError("Failed to create new day entry."));
      }
    } catch (e) {
      emit(DayEntryError("Error creating new day entry: $e"));
    }
  }

  Future<void> _onUpdateMood(
    UpdateMood event,
    Emitter<DayEntryState> emit,
  ) async {
    if (_currentDayEntry == null) {
      emit(DayEntryError("No day entry available to update."));
      return;
    }

    final uri = Uri.parse(
      'http://10.0.2.2:5000/api/v1/days/${_currentDayEntry!.id}',
    );
    print("❗❗❗❗❗❗");
    final Map<String, dynamic> requestBody = {"mood": event.moodIndex.toString()};

    try {
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final updated = _currentDayEntry!.copyWith(mood: event.moodIndex);
        _currentDayEntry = updated;
        emit(DayEntryLoaded(updated));
      } else {
        emit(DayEntryError("Failed to update mood."));
      }
    } catch (e) {
      emit(DayEntryError("Error updating mood: $e"));
    }
  }
}

extension on DayEntry {
  DayEntry copyWith({int? mood}) {
    return DayEntry(
      id: id,
      dayEntryDate: dayEntryDate,
      mood: mood ?? this.mood,
      journalEntries: journalEntries,
      dailyTasks: dailyTasks,
    );
  }
}
