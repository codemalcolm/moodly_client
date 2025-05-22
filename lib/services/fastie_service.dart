class FastieService {
  List<Map<String, dynamic>> generateFasties(
    List<Map<String, dynamic>> allFasties,
    Set<String> selectedCategories,
  ) {
    final filtered =
        allFasties
            .where((f) => selectedCategories.contains(f['category']))
            .toList();

    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in filtered) {
      grouped.putIfAbsent(item['category'], () => []).add(item);
    }

    final List<Map<String, dynamic>> selected = [];
    final categories = grouped.keys.toList()..shuffle();
    for (final cat in categories.take(3)) {
      final tasks = grouped[cat]!;
      tasks.shuffle();
      selected.add(tasks.first);
    }
    return selected;
  }

  Map<String, dynamic>? getReplacementFastie({
    required List<Map<String, dynamic>> allFasties,
    required List<Map<String, dynamic>> currentFasties,
    required List<String> completedFasties,
    required Set<String> selectedCategories,
  }) {
    final eligible =
        allFasties.where((f) {
          final task = f['task'];
          return selectedCategories.contains(f['category']) &&
              !currentFasties.any((e) => e['task'] == task) &&
              !completedFasties.contains(task);
        }).toList();

    if (eligible.isNotEmpty) {
      eligible.shuffle();
      return eligible.first;
    }
    return null;
  }
}
