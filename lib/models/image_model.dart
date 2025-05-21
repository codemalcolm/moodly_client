class ImageModel {
  final String id;
  final String journalEntryId;
  final String imageData;

  ImageModel({
    required this.id,
    required this.journalEntryId,
    required this.imageData,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['_id'] as String,
      journalEntryId: json['journalEntryId'] as String,
      imageData: json['imageData'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'journalEntryId': journalEntryId,
      'imageData': imageData,
    };
  }
}
