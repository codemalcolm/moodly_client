import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/svg.dart';
import 'package:moodly_client/widgets/calendar_tab.dart';
import 'package:moodly_client/widgets/moods_card.dart';

class JournalEntry {
  final String id;
  final String name;
  final String entryText;
  final String entryDateAndTime;

  JournalEntry({
    required this.id,
    required this.name,
    required this.entryText,
    required this.entryDateAndTime,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['_id'],
      name: json['name'],
      entryText: json['entryText'],
      entryDateAndTime: json['entryDateAndTime'],
    );
  }
}

class DayEntry {
  final String id;
  final String dayEntryDate;
  final String mood;
  final List<JournalEntry> journalEntries;

  DayEntry({
    required this.id,
    required this.dayEntryDate,
    required this.mood,
    required this.journalEntries,
  });

  factory DayEntry.fromJson(Map<String, dynamic> json) {
    return DayEntry(
      id: json['_id'],
      dayEntryDate: json['dayEntryDate'],
      mood: json['mood'],
      journalEntries:
          (json['journalEntries'] as List<dynamic>)
              .map((e) => JournalEntry.fromJson(e))
              .toList(),
    );
  }
}

class DayViewScreen extends StatefulWidget {
  const DayViewScreen({super.key});

  @override
  State<DayViewScreen> createState() => _DayViewScreenState();
}

class _DayViewScreenState extends State<DayViewScreen> {
  final String backendUrl = 'http://10.0.2.2:5000/api/v1/entries';
  late Future<String> _messageFuture;
  int? selectedMoodIndex;
  bool showMoodSelector = true;

  DayEntry? _dayEntry;
  bool _isLoadingDayEntry = false;
  String? _dayEntryError;

  Future<void> createDayEntry(String formattedDate) async {
    final uri = Uri.parse('http://10.0.2.2:5000/api/v1/days');
    final Map<String, dynamic> requestBody = {
      "dayEntryDate": formattedDate,
      "mood": "unfilled",
      "dailyTasks": [],
      "journalEntries": [],
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _dayEntry = DayEntry.fromJson(jsonResponse['dayEntry']);
          _dayEntryError = null;
        });
      } else {
        setState(() {
          _dayEntryError = 'Failed to create new day entry.';
        });
      }
    } catch (e) {
      setState(() {
        _dayEntryError = 'Error creating new day entry: $e';
      });
    }
  }

  Future<void> fetchDayEntry(DateTime date) async {
    setState(() {
      _isLoadingDayEntry = true;
      _dayEntryError = null;
      _dayEntry = null;
    });

    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final uri = Uri.parse(
      'http://10.0.2.2:5000/api/v1/days?date=$formattedDate',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['dayEntry'] != null) {
          setState(() {
            _dayEntry = DayEntry.fromJson(jsonResponse['dayEntry']);
          });
        } else {
          setState(() {
            _dayEntryError = 'No data found for this day.';
          });
        }
      } else {
        final errorJson = json.decode(response.body);
        if (errorJson['errorName'] == 'CastError') {
          setState(() {
            _dayEntryError = 'Undefined date provided';
          });
        } else {
          // Create new day entry if no CastError
          await createDayEntry(formattedDate);
        }
      }
    } catch (e) {
      setState(() {
        _dayEntryError = 'Error fetching data: $e';
      });
    } finally {
      setState(() {
        _isLoadingDayEntry = false;
      });
    }
  }

  final PageController _pageController = PageController(initialPage: 0);
  final DateTime _baseDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  int _currentPage = 0;

  Future<String> fetchMessage() async {
    final response = await http.get(Uri.parse(backendUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body)['message'];
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _messageFuture = fetchMessage();
    fetchDayEntry(_selectedDate);
  }

  List<DateTime> _getWeekDates(DateTime startDate) {
    final monday = startDate.subtract(Duration(days: startDate.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  DateTime _getDateFromPage(int pageIndex) {
    int offset = pageIndex - _currentPage;
    return _selectedDate.add(Duration(days: 7 * offset));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekStart = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    final month = DateFormat('MMMM').format(_selectedDate);
    final year = DateFormat('yyyy').format(_selectedDate);

    return Scaffold(
      body: Column(
        children: [
          CalendarTab(
            selectedDate: _selectedDate,
            onDateSelected: (newDate) {
              setState(() {
                _selectedDate = newDate;
              });
              fetchDayEntry(_selectedDate);
            },
            pageController: _pageController,
            currentPage: _currentPage,
            onPageChanged: (pageIndex) {
              setState(() {
                final newDate = _getDateFromPage(pageIndex);
                _selectedDate = newDate;
                _currentPage = pageIndex;
              });
              fetchDayEntry(_selectedDate);
            },
            // onPageChanged: (pageIndex) {
            //   setState(() {
            //     final newDate = _selectedDate.add(
            //       Duration(days: 7 * (pageIndex - _currentPage)),
            //     );
            //     _selectedDate = newDate;
            //     _currentPage = pageIndex;
            //   });
            // },
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 16,
                top: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      '${DateFormat('EEEE, dd/MM/yyyy').format(_selectedDate)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (selectedMoodIndex == null || showMoodSelector)
                    Column(
                      children: [
                        MoodsCard(
                          selectedMoodIndex: selectedMoodIndex,
                          onMoodSelected: (index) {
                            setState(() {
                              selectedMoodIndex = index;
                              showMoodSelector = false;
                            });
                          },
                        ),
                      ],
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Daily tasks",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              Container(height: 250, color: Colors.grey),
                            ],
                          ),
                        ),
                        if (selectedMoodIndex != null && !showMoodSelector)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Today's mood",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              GestureDetector(
                                onTap:
                                    () =>
                                        setState(() => showMoodSelector = true),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.colorScheme.surface,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: SvgPicture.asset(
                                      MoodsCard.moods[selectedMoodIndex!],
                                      width: 48,
                                      height: 48,
                                      colorFilter: ColorFilter.mode(
                                        theme.colorScheme.primary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  Expanded(
                    child:
                        _isLoadingDayEntry
                            ? const Center(child: CircularProgressIndicator())
                            : _dayEntry != null
                            ? ListView(
                              children: [
                                Text(
                                  'Mood: ${_dayEntry!.mood}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 10),
                                if (_dayEntry!.journalEntries.isNotEmpty)
                                  ..._dayEntry!.journalEntries.map(
                                    (entry) => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Name: ${entry.name}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text('Text: ${entry.entryText}'),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  )
                                else
                                  const Text(
                                    'No journal entries for this day.',
                                  ),
                              ],
                            )
                            : Center(
                              child: Text(
                                _dayEntryError ?? 'No data for selected day.',
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
