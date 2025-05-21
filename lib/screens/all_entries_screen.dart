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

class _AllEntriesScreenState extends State<AllEntriesScreen> {
  List<Map<String, dynamic>> dayEntries = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5000/api/v1/days/all?page=1&limit=50&sort=+dayEntryDate',
        ),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List<Map<String, dynamic>> parsedResults =
            List<Map<String, dynamic>>.from(decoded['results']);

        parsedResults.sort((a, b) {
          final dateA = DateTime.parse(a['dayEntryDate']);
          final dateB = DateTime.parse(b['dayEntryDate']);
          return dateB.compareTo(dateA);
        });

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
                itemCount: dayEntries.length,
                itemBuilder: (context, index) {
                  final day = dayEntries[index];
                  final mood = day['mood'];
                  final bgColor = MoodUtils.moodColors[index];
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
                              style: theme.textTheme.titleMedium,
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
                                      theme.brightness == Brightness.dark
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
                              theme.primaryColor,
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
}
