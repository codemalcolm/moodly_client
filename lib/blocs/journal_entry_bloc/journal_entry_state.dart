import 'package:equatable/equatable.dart';

abstract class JournalEntryState extends Equatable {
  const JournalEntryState();

  @override
  List<Object?> get props => [];
}

class JournalEntryInitial extends JournalEntryState {}

class JournalEntryLoading extends JournalEntryState {}

class JournalEntrySuccess extends JournalEntryState {
  final String message;
  const JournalEntrySuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class JournalEntryFailure extends JournalEntryState {
  final String error;
  const JournalEntryFailure(this.error);

  @override
  List<Object?> get props => [error];
}