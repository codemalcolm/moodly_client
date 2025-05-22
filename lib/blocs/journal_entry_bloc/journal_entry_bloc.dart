import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'journal_entry_event.dart';
import 'journal_entry_state.dart';

class JournalEntryBloc extends Bloc<JournalEntryEvent, JournalEntryState> {
  JournalEntryBloc() : super(JournalEntryInitial()) {
    on<CreateJournalEntry>(_onCreateJournalEntry);
    on<UpdateJournalEntry>(_onUpdateJournalEntry);
    on<DeleteJournalEntry>(_onDeleteJournalEntry);
  }

  final _baseUrl = 'http://10.0.2.2:5000/api/v1';

  Future<void> _onCreateJournalEntry(
    CreateJournalEntry event,
    Emitter<JournalEntryState> emit,
  ) async {
    emit(JournalEntryLoading());

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/entries'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': event.name,
          'entryText': event.entryText,
          'entryDateAndTime': "${event.entryDateAndTime.toIso8601String()}+00:00",
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final journalEntryId = data['journalEntry']['_id'];

        if (event.images.isNotEmpty) {
          final uploadUri = Uri.parse(
            '$_baseUrl/entries/$journalEntryId/images',
          );
          final uploadRequest = http.MultipartRequest('POST', uploadUri);

          for (final image in event.images) {
            final mimeType =
                lookupMimeType(image.path)?.split('/') ?? ['image', 'jpeg'];
            uploadRequest.files.add(
              await http.MultipartFile.fromPath(
                'file',
                image.path,
                contentType: MediaType(mimeType[0], mimeType[1]),
              ),
            );
          }

          final uploadResponse = await uploadRequest.send();
          if (uploadResponse.statusCode != 200 &&
              uploadResponse.statusCode != 201) {
            throw Exception('Image upload failed');
          }
        }

        emit(const JournalEntrySuccess('Journal entry created'));
      } else {
        throw Exception('Failed to create journal entry');
      }
    } catch (e) {
      emit(JournalEntryFailure(e.toString()));
    }
  }

  Future<void> _onUpdateJournalEntry(
    UpdateJournalEntry event,
    Emitter<JournalEntryState> emit,
  ) async {
    emit(JournalEntryLoading());

    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/entries/${event.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': event.name,
          'entryText': event.entryText,
          'entryDateAndTime': event.entryDateAndTime.toIso8601String(),
          'images': event.imageIds,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(const JournalEntrySuccess('Journal entry updated'));
      } else {
        throw Exception('Failed to update journal entry');
      }
    } catch (e) {
      emit(JournalEntryFailure(e.toString()));
    }
  }

  Future<void> _onDeleteJournalEntry(
    DeleteJournalEntry event,
    Emitter<JournalEntryState> emit,
  ) async {
    emit(JournalEntryLoading());

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/entries/${event.id}'),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(const JournalEntrySuccess('Journal entry deleted'));
      } else {
        throw Exception('Failed to delete journal entry');
      }
    } catch (e) {
      emit(JournalEntryFailure(e.toString()));
    }
  }
}
