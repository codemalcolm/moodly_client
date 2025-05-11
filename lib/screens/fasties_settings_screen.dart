import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class FastiesSettingsScreen extends StatefulWidget {
  const FastiesSettingsScreen({super.key});
  @override
  State<FastiesSettingsScreen> createState() => _FastiesSettingsScreenState();
}

class _FastiesSettingsScreenState extends State<FastiesSettingsScreen> {
  List<String> allCategories = [];
  List<String> displayedCategories = [];
  Set<String> selectedCategories = {};
  final TextEditingController searchController = TextEditingController();
  final defaultCategories = {'exercise', 'hydration', 'clean up'};

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('selectedFastiesCategories');
    final String jsonString = await rootBundle.loadString(
      'assets/data/categories.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);
    allCategories =
        jsonList.map<String>((e) => e['category'] as String).toList();
    setState(() {
      selectedCategories =
          saved != null
              ? Set<String>.from(saved)
              : Set<String>.from(defaultCategories);
      displayedCategories = List.from(allCategories);
    });
  }

  Future<void> saveSelectedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'selectedFastiesCategories',
      selectedCategories.toList(),
    );
  }

  void toggleCategorySelection(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        if (selectedCategories.length > 4) {
          selectedCategories.remove(category);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please keep at least 3 categories selected.'),
            ),
          );
        }
      } else {
        selectedCategories.add(category);
      }
    });
    saveSelectedCategories();
  }

  void filterCategories(String query) {
    setState(() {
      displayedCategories =
          allCategories
              .where((c) => c.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await saveSelectedCategories();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Your Categories')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                onChanged: filterCategories,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search categories...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: displayedCategories.length,
                  itemBuilder: (context, index) {
                    final category = displayedCategories[index];
                    final isSelected = selectedCategories.contains(category);
                    return GestureDetector(
                      onTap: () => toggleCategorySelection(category),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? theme.primaryColor.withOpacity(0.3)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected ? theme.primaryColor : Colors.grey,
                          ),
                        ),
                        child: Text(
                          category,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
