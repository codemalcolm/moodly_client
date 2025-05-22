import 'package:moodly_client/models/image_model.dart';

class JournalEntry {
  final String id;
  final String name;
  final String entryText;
  final String entryDateAndTime;
  final List<ImageModel> images;

  JournalEntry({
    required this.id,
    required this.name,
    required this.entryText,
    required this.entryDateAndTime,
    required this.images,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['_id'] as String,
      name: json['name'] as String,
      entryText: json['entryText'] as String,
      entryDateAndTime: json['entryDateAndTime'] as String,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => ImageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
