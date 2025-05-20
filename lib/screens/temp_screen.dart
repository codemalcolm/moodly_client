import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:moodly_client/models/day_entry_model.dart';
import 'package:moodly_client/theme/app_theme.dart';

class AllEntriesScreen extends StatefulWidget {
  const AllEntriesScreen({super.key});

  @override
  State<AllEntriesScreen> createState() => _AllEntriesScreenState();
}

class _AllEntriesScreenState extends State<AllEntriesScreen> {
  final String backendUrl =
      'http://10.0.2.2:5000/api/v1/days/all?page=1&limit=50&sort=+dayEntryDate';
  List<DayEntry> _allDayEntries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchAllEntries();
  }

  Future<void> fetchAllEntries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(Uri.parse(backendUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> entriesJson = data['results'] ?? [];

        final entries =
            entriesJson.map((e) => DayEntry.fromJson(e)).toList()..sort(
              (a, b) => DateTime.parse(
                b.dayEntryDate,
              ).compareTo(DateTime.parse(a.dayEntryDate)),
            );

        setState(() {
          _allDayEntries = entries;
        });
      } else {
        setState(() {
          _error = 'Failed to load entries.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildMoodIcon(int? mood) {
    if (mood == null || mood < 0 || mood >= 8) return Container();

    final moodAssetPaths = [
      'assets/icons/icon_mood_angry.svg',
      'assets/icons/icon_mood_anxious.svg',
      'assets/icons/icon_mood_good.svg',
      'assets/icons/icon_mood_happy.svg',
      'assets/icons/icon_mood_loving.svg',
      'assets/icons/icon_mood_moody.svg',
      'assets/icons/icon_mood_sad.svg',
      'assets/icons/icon_mood_tired.svg',
    ];

    return SvgPicture.asset(
      moodAssetPaths[mood],
      width: 32,
      height: 32,
      colorFilter: ColorFilter.mode(
        Theme.of(context).colorScheme.onSurface,
        BlendMode.srcIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = getAccentBackgroundColor(theme.primaryColor);

    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _allDayEntries.length,
                itemBuilder: (context, index) {
                  final day = _allDayEntries[index];
                  final date = DateFormat(
                    'EEEE, dd MMM yyyy',
                  ).format(DateTime.parse(day.dayEntryDate));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              date,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _buildMoodIcon(day.mood),
                          ],
                        ),
                      ),

                      if (day.journalEntries.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            'No journal entries for this day.',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        )
                      else
                        ...day.journalEntries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          entry.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        DateFormat('HH:mm').format(
                                          DateTime.parse(
                                            entry.entryDateAndTime,
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(entry.entryText),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
    );
  }
}
