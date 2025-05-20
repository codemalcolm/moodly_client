import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FastiesScreen extends StatefulWidget {
  const FastiesScreen({super.key});
  @override
  State<FastiesScreen> createState() => _FastiesScreenState();
}

class _FastiesScreenState extends State<FastiesScreen> {
  late String todayKey;
  late String storedFastiesKey;
  late String completedFastiesKey;
  List<Map<String, dynamic>> allFasties = [];
  List<Map<String, dynamic>> fasties = [];
  List<String> completedFasties = [];
  Set<String> selectedCategories = {};
  @override
  void initState() {
    super.initState();
    todayKey = DateTime.now().toIso8601String().substring(0, 10);
    storedFastiesKey = 'dailyFasties_$todayKey';
    completedFastiesKey = 'completedFasties_$todayKey';
    loadFastiesAndPreferences();
  }

  List<Map<String, dynamic>> generateFastiesAndSave(
    SharedPreferences prefs,
    String todayKey,
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
    prefs.setString('dailyFasties_$todayKey', json.encode(selected));
    return selected;
  }

  Future<void> loadFastiesAndPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final selected =
        prefs.getStringList('selectedFastiesCategories') ??
        ['exercise', 'hydration', 'clean up'];
    selectedCategories = selected.toSet();
    final String jsonString = await rootBundle.loadString(
      'assets/data/fasties.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);
    allFasties = jsonList.cast<Map<String, dynamic>>();
    final stored = prefs.getString('dailyFasties_$today');
    if (stored != null) {
      fasties = List<Map<String, dynamic>>.from(json.decode(stored));
    } else {
      fasties = generateFastiesAndSave(prefs, today);
    }
    final completed = prefs.getStringList('completedFasties_$today') ?? [];
    setState(() {
      completedFasties = completed;
    });
  }

  void generateFasties() {
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
    setState(() {
      fasties = selected;
    });
  }

  void replaceFastie(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final eligible =
        allFasties
            .where(
              (f) =>
                  selectedCategories.contains(f['category']) &&
                  !fasties.any((e) => e['task'] == f['task']),
            )
            .toList();
    if (eligible.isNotEmpty) {
      eligible.shuffle();
      setState(() {
        fasties[index] = eligible.first;
      });
      await prefs.setString(storedFastiesKey, json.encode(fasties));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Don't forget to look after yourself today!",
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  'assets/images/moodly_speech.png',
                  width: 100,
                  height: 100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('About Fasties'),
                          content: const Text(
                            'Fasties are small, spontaneous challenges designed to bring variety into your day. '
                            'They help you achieve your goals in a playful way while supporting your mental and physical well-being.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Got it'),
                            ),
                          ],
                        ),
                  );
                },
                icon: SvgPicture.asset(
                  'assets/icons/icon_info.svg',
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.secondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, '/fasties-settings');
                  await loadFastiesAndPreferences();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Fasties updated!',
                          style: theme.textTheme.bodyMedium,
                        ),
                        backgroundColor: theme.secondaryHeaderColor,
                      ),
                    );
                  }
                  await loadFastiesAndPreferences();
                },
                icon: SvgPicture.asset(
                  'assets/icons/icon_fasties_settings.svg',
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.secondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: List.generate(fasties.length, (index) {
              final item = fasties[index];
              return _buildFastieTaskCard(
                task: item['task'],
                category: item['category'],
                isCompleted: completedFasties.contains(item['task']),
                onCompletedOrDelete: (bool wasCompleted) async {
                  final prefs = await SharedPreferences.getInstance();
                  if (wasCompleted) {
                    final completed =
                        prefs.getStringList(completedFastiesKey) ?? [];
                    if (!completed.contains(item['task'])) {
                      completed.add(item['task']);
                      await prefs.setStringList(completedFastiesKey, completed);
                    }
                    setState(() {
                      completedFasties = completed;
                      fasties.removeAt(index);
                    });
                    final eligible =
                        allFasties
                            .where(
                              (f) =>
                                  selectedCategories.contains(f['category']) &&
                                  !fasties.any((e) => e['task'] == f['task']) &&
                                  !completedFasties.contains(f['task']),
                            )
                            .toList();
                    if (eligible.isNotEmpty) {
                      eligible.shuffle();
                      final newFastie = eligible.first;
                      setState(() {
                        fasties.insert(index, newFastie);
                      });
                      await prefs.setString(
                        storedFastiesKey,
                        json.encode(fasties),
                      );
                    } else {
                      await prefs.setString(
                        storedFastiesKey,
                        json.encode(fasties),
                      );
                    }
                  }
                },
              );
            }),
          ),
          const SizedBox(height: 24),
          if (completedFasties.isNotEmpty) ...[
            Text(
              "Today's completed fasties",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Column(
              children:
                  completedFasties.map((task) {
                    return Opacity(
                      opacity: 0.6,
                      child: _buildFastieTaskCard(
                        task: task,
                        category: '✔',
                        isCompleted: true,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFastieTaskCard({
    required String task,
    required String category,
    required bool isCompleted,
    void Function(bool isCompleted)? onCompletedOrDelete,
  }) {
    final textStyle = TextStyle(
      fontSize: 16,
      color: isCompleted ? Colors.grey : null,
      decoration: isCompleted ? TextDecoration.lineThrough : null,
    );

    return Opacity(
      opacity: isCompleted ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        height: 80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Text(task, style: textStyle)),
            const SizedBox(width: 12),
            Column(
              children: [
                if (!isCompleted && onCompletedOrDelete != null)
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: const Text('Delete Fastie?'),
                                  content: const Text(
                                    'Do you really want to delete this Fastie?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        onCompletedOrDelete(false);
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: Colors.grey,
                        iconSize: 20,
                      ),
                    ),
                  ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.center,
                    child: Checkbox(
                      value: isCompleted,
                      onChanged:
                          isCompleted
                              ? null
                              : (val) async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (ctx) => AlertDialog(
                                        title: const Text('Fastie completed?'),
                                        content: const Text(
                                          'Have you completed this fastie?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  ctx,
                                                ).pop(false),
                                            child: const Text('Not yet'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () =>
                                                    Navigator.of(ctx).pop(true),
                                            child: const Text('Yes'),
                                          ),
                                        ],
                                      ),
                                );
                                if (confirmed == true) {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  final completed =
                                      prefs.getStringList(
                                        completedFastiesKey,
                                      ) ??
                                      [];
                                  if (!completed.contains(task)) {
                                    completed.add(task);
                                    await prefs.setStringList(
                                      completedFastiesKey,
                                      completed,
                                    );
                                  }
                                  setState(() {
                                    completedFasties = completed;
                                  });
                                  onCompletedOrDelete?.call(true);
                                }
                              },
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
