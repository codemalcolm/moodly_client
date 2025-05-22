class FastiesScreenState {
  final List<Map<String, dynamic>> allFasties;
  final List<Map<String, dynamic>> dailyFasties;
  final List<String> completedFasties;
  final Set<String> selectedCategories;

  FastiesScreenState({
    required this.allFasties,
    required this.dailyFasties,
    required this.completedFasties,
    required this.selectedCategories,
  });

  FastiesScreenState copyWith({
    List<Map<String, dynamic>>? allFasties,
    List<Map<String, dynamic>>? dailyFasties,
    List<String>? completedFasties,
    Set<String>? selectedCategories,
  }) {
    return FastiesScreenState(
      allFasties: allFasties ?? this.allFasties,
      dailyFasties: dailyFasties ?? this.dailyFasties,
      completedFasties: completedFasties ?? this.completedFasties,
      selectedCategories: selectedCategories ?? this.selectedCategories,
    );
  }
}
