import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:moodly_client/theme/app_theme.dart';
import 'package:moodly_client/widgets/entry_card.dart';

class AllEntriesScreen extends StatefulWidget {
  const AllEntriesScreen({super.key});

  @override
  State<AllEntriesScreen> createState() => _AllEntriesScreenState();
}

class _AllEntriesScreenState extends State<AllEntriesScreen> {
  List<Map<String, dynamic>> days = [];
  List<Map<String, dynamic>> journalEntries = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final daysData = await rootBundle.loadString('assets/data/days.json');
    final entriesData = await rootBundle.loadString(
      'assets/data/journalEntries.json',
    );

    final parsedDays = List<Map<String, dynamic>>.from(jsonDecode(daysData));
    final parsedEntries = List<Map<String, dynamic>>.from(
      jsonDecode(entriesData),
    );

    parsedDays.sort((a, b) {
      final dateA = DateTime.parse(a['dayEntry']['dayEntryDate']);
      final dateB = DateTime.parse(b['dayEntry']['dayEntryDate']);
      return dateB.compareTo(dateA);
    });

    setState(() {
      days = parsedDays;
      journalEntries = parsedEntries;
    });
  }

  List<Map<String, dynamic>> getEntriesForDay(DateTime date) {
    return journalEntries.where((entry) {
        final entryDate = DateTime.parse(entry['entryDateAndTime']);
        return entryDate.year == date.year &&
            entryDate.month == date.month &&
            entryDate.day == date.day;
      }).toList()
      ..sort(
        (a, b) => DateTime.parse(
          a['entryDateAndTime'],
        ).compareTo(DateTime.parse(b['entryDateAndTime'])),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body:
          days.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index]['dayEntry'];
                  final mood = day['mood'];
                  final date = DateTime.parse(day['dayEntryDate']);
                  final dayEntries = getEntriesForDay(date);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd.MM.yyyy').format(date),
                              style: theme.textTheme.titleMedium,
                            ),
                            SvgPicture.asset(
                              'assets/icons/icon_mood_$mood.svg',
                              width: 28,
                              height: 28,
                              colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.secondary,
                                BlendMode.srcIn,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...dayEntries.map((entry) {
                          final entryDate = DateTime.parse(
                            entry['entryDateAndTime'],
                          );
                          final time = DateFormat('HH:mm').format(entryDate);
                          final bgColor = AccentBackgroundColors.blue;
                          return EntryCard(
                            title: entry['name'] ?? '',
                            text: entry['entryText'] ?? '',
                            time: time,
                            images: List<String>.from(entry['images'] ?? []),
                            backgroundColor: bgColor,
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
