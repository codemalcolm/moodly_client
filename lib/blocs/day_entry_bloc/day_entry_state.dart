import 'package:equatable/equatable.dart';
import 'package:moodly_client/models/day_entry_model.dart';

abstract class DayEntryState extends Equatable {
  const DayEntryState();

  @override
  List<Object?> get props => [];
}

class DayEntryInitial extends DayEntryState {}

class DayEntryLoading extends DayEntryState {}

class DayEntryLoaded extends DayEntryState {
  final DayEntry dayEntry;

  const DayEntryLoaded(this.dayEntry);

  @override
  List<Object?> get props => [dayEntry];
}

class DayEntryError extends DayEntryState {
  final String message;

  const DayEntryError(this.message);

  @override
  List<Object?> get props => [message];
}
