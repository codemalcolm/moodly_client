import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class FastiesSettingsScreen extends StatefulWidget {
  const FastiesSettingsScreen({super.key});

  @override
  State<FastiesSettingsScreen> createState() => _FastiesSettingsScreenState();
}

class _FastiesSettingsScreenState extends State<FastiesSettingsScreen> {
  List<String> allCategories = [];
  List<String> displayedCategories = [];
  Set<String> selectedCategories = {};
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/categories.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);
    allCategories =
        jsonList.map<String>((e) => e['category'] as String).toList();
    setState(() {
      displayedCategories = List.from(allCategories);
    });
  }

  void filterCategories(String query) {
    setState(() {
      displayedCategories =
          allCategories
              .where(
                (category) =>
                    category.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  void toggleCategorySelection(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Your Categories')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: searchController,
              onChanged: filterCategories,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Coming soon!',
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
                          color: isSelected ? theme.primaryColor : Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        category,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
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
    );
  }
}
