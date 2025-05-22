class Fastie {
  final String task;
  final String category;

  Fastie({required this.task, required this.category});

  factory Fastie.fromJson(Map<String, dynamic> json) {
    return Fastie(task: json['task'], category: json['category']);
  }

  Map<String, dynamic> toJson() => {'task': task, 'category': category};
}
