import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:moodly_client/widgets/fastie_task_card.dart';

class FastiesScreen extends StatefulWidget {
  const FastiesScreen({super.key});

  @override
  State<FastiesScreen> createState() => _FastiesScreenState();
}

class _FastiesScreenState extends State<FastiesScreen> {
  List<Map<String, dynamic>> allFasties = [];
  List<Map<String, dynamic>> fasties = [];

  @override
  void initState() {
    super.initState();
    loadFasties();
  }

  Future<void> loadFasties() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/fasties.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);
    allFasties = jsonList.cast<Map<String, dynamic>>();
    setState(() {
      fasties = allFasties.take(3).toList();
    });
  }

  void replaceFastie(int index) {
    final usedTasks = fasties.map((f) => f['task']).toSet();
    final remaining =
        allFasties.where((f) => !usedTasks.contains(f['task'])).toList();
    if (remaining.isNotEmpty) {
      setState(() {
        fasties[index] = remaining.first;
      });
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
            // crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  // TODO: show help dialog or info
                },
                icon: const Icon(Icons.help_outline),
                color: Colors.grey,
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/fasties-settings');
                },
                icon: const Icon(Icons.settings),
                color: Colors.grey,
              ),
            ],
          ),
          Column(
            children: List.generate(fasties.length, (index) {
              final item = fasties[index];
              return FastieTaskCard(
                task: item['task'],
                category: item['category'],
                onDelete: () => replaceFastie(index),
              );
            }),
          ),
        ],
      ),
    );
  }
}
