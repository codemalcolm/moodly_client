import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class JournalEntryEvent extends Equatable {
  const JournalEntryEvent();
  @override
  List<Object?> get props => [];
}

class CreateJournalEntry extends JournalEntryEvent {
  final String name;
  final String entryText;
  final DateTime entryDateAndTime;
  final List<File> images;

const CreateJournalEntry({
    required this.name,
    required this.entryText,
    required this.entryDateAndTime,
    this.images = const [],
  });

  @override
  List<Object?> get props => [name, entryText, entryDateAndTime, images];
}

class UpdateJournalEntry extends JournalEntryEvent {
  final String id;
  final String name;
  final String entryText;
  final DateTime entryDateAndTime;
  final List<String> imageIds; // Or base64 strings if replacing

  const UpdateJournalEntry({
    required this.id,
    required this.name,
    required this.entryText,
    required this.entryDateAndTime,
    this.imageIds = const [],
  });

  @override
  List<Object?> get props => [id, name, entryText, entryDateAndTime, imageIds];
}

class DeleteJournalEntry extends JournalEntryEvent {
  final String id;

  const DeleteJournalEntry(this.id);

  @override
  List<Object?> get props => [id];
}
