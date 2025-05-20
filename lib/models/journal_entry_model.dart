class JournalEntry {
  final String id;
  final String name;
  final String entryText;
  final String entryDateAndTime;

  JournalEntry({
    required this.id,
    required this.name,
    required this.entryText,
    required this.entryDateAndTime,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['_id'],
      name: json['name'],
      entryText: json['entryText'],
      entryDateAndTime: json['entryDateAndTime'],
    );
  }
}
