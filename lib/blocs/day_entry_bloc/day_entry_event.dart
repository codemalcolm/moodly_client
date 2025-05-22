import 'package:equatable/equatable.dart';

abstract class DayEntryEvent extends Equatable {
  const DayEntryEvent();

  @override
  List<Object?> get props => [];
}

class FetchDayEntry extends DayEntryEvent {
  final DateTime date;

  const FetchDayEntry(this.date);

  @override
  List<Object?> get props => [date];
}

class CreateDayEntry extends DayEntryEvent {
  final String formattedDate;

  const CreateDayEntry(this.formattedDate);

  @override
  List<Object?> get props => [formattedDate];
}

class UpdateMood extends DayEntryEvent {
  final int moodIndex;

  const UpdateMood(this.moodIndex);

  @override
  List<Object?> get props => [moodIndex];
}
