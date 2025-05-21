import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:moodly_client/theme/app_theme.dart';
import 'package:moodly_client/widgets/entry_card.dart';
import 'package:moodly_client/widgets/mood_utils.dart';

class AllEntriesScreen extends StatefulWidget {
  const AllEntriesScreen({super.key});

  @override
  State<AllEntriesScreen> createState() => _AllEntriesScreenState();
}

enum SortOption { dateAsc, dateDesc, moodAsc, moodDesc }

class _AllEntriesScreenState extends State<AllEntriesScreen> {
  List<Map<String, dynamic>> dayEntries = [];
  SortOption selectedSort = SortOption.dateDesc;

  final Map<SortOption, String> sortApiMap = {
    SortOption.dateAsc: '+dayEntryDate',
    SortOption.dateDesc: '-dayEntryDate',
    SortOption.moodAsc: '+mood',
    SortOption.moodDesc: '-mood',
  };

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final sortParam = sortApiMap[selectedSort];
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5000/api/v1/days/all?page=1&limit=50&sort=$sortParam',
        ),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List<Map<String, dynamic>> parsedResults =
            List<Map<String, dynamic>>.from(decoded['results']);

        setState(() {
          dayEntries = parsedResults;
        });
      } else {
        debugPrint('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body:
          dayEntries.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: dayEntries.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: SvgPicture.asset(
                              'assets/icons/icon_sorting.svg',
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.secondary,
                                BlendMode.srcIn,
                              ),
                            ),
                            onPressed: () => _showSortMenu(context),
                          ),
                        ],
                      ),
                    );
                  }

                  final day = dayEntries[index - 1];
                  final mood = day['mood'];
                  final bgColor = MoodUtils.moodColors[index - 1];

                  final journalEntries = List<Map<String, dynamic>>.from(
                    day['journalEntries'] ?? [],
                  )..sort(
                    (a, b) => DateTime.parse(
                      a['entryDateAndTime'],
                    ).compareTo(DateTime.parse(b['entryDateAndTime'])),
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat(
                                'dd.MM.yyyy',
                              ).format(DateTime.parse(day['dayEntryDate'])),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (mood != -1 && mood >= 0 && mood <= 7)
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: SvgPicture.asset(
                                    'assets/icons/icon_mood_$mood.svg',
                                    colorFilter: ColorFilter.mode(
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              )
                            else
                              const SizedBox(width: 36, height: 36),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...journalEntries.map((entry) {
                          final entryDate = DateTime.parse(
                            entry['entryDateAndTime'],
                          );
                          final time = DateFormat('HH:mm').format(entryDate);

                          final imagesData =
                              (entry['images'] as List<dynamic>? ?? [])
                                  .where(
                                    (img) =>
                                        img != null && img['imageData'] != null,
                                  )
                                  .map<Uint8List>(
                                    (img) => base64Decode(img['imageData']),
                                  )
                                  .toList();

                          return EntryCard(
                            title: entry['name'] ?? '',
                            text: entry['entryText'] ?? '',
                            time: time,
                            imageBytes: imagesData,
                            backgroundColor: getAccentBackgroundColor(
                              Theme.of(context).primaryColor,
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.dateAsc:
        return 'Date ↑';
      case SortOption.dateDesc:
        return 'Date ↓';
      case SortOption.moodAsc:
        return 'Mood ↑';
      case SortOption.moodDesc:
        return 'Mood ↓';
    }
  }

  void _showSortMenu(BuildContext context) async {
    final SortOption? selected = await showMenu<SortOption>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 100, 16, 0),
      items:
          SortOption.values.map((option) {
            return PopupMenuItem<SortOption>(
              value: option,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_getSortLabel(option)),
                  if (option == selectedSort)
                    const Icon(Icons.check, color: Colors.green, size: 16),
                ],
              ),
            );
          }).toList(),
    );

    if (selected != null && selected != selectedSort) {
      setState(() {
        selectedSort = selected;
      });
      await loadData();
    }
  }
}
