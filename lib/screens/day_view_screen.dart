import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/svg.dart';
import 'package:moodly_client/widgets/calendar_tab.dart';
import 'package:moodly_client/widgets/custom_button_small.dart';
import 'package:moodly_client/widgets/daily_task_card.dart';
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

class DailyTask {
  final String id;
  final String name;
  final bool isDone;

  DailyTask({required this.id, required this.name, required this.isDone});

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      id: json['_id'],
      name: json['name'],
      isDone: json['isDone'],
    );
  }
}

class DayEntry {
  final String id;
  final String dayEntryDate;
  final int? mood;
  final List<JournalEntry> journalEntries;
  final List<DailyTask> dailyTasks;

  DayEntry({
    required this.id,
    required this.dayEntryDate,
    required this.mood,
    required this.journalEntries,
    required this.dailyTasks,
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
      dailyTasks:
          (json['dailyTasks'] as List<dynamic>)
              .map((e) => DailyTask.fromJson(e))
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
      "mood": -1,
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
            if (_dayEntry!.mood != -1) {
              setState(() {
                selectedMoodIndex = _dayEntry!.mood;
                showMoodSelector = false;
              });
            } else {
              setState(() {
                selectedMoodIndex = null;
                showMoodSelector = true;
              });
            }
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

  Future<void> updateMood(int moodIndex) async {
    final uri = Uri.parse('http://10.0.2.2:5000/api/v1/days/${_dayEntry!.id}');
    final Map<String, dynamic> requestBody = {"mood": moodIndex.toString()};

    try {
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode != 200) {
        _dayEntryError = "Failed to update mood:";
      }
    } catch (e) {
      setState(() {
        _dayEntryError = "Error updating mood: $e";
      });
    }
  }

  final DateTime _baseDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  Future<String> fetchMessage() async {
    final response = await http.get(Uri.parse(backendUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body)['message'];
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _createDailyTask(String dayId, String name) async {
    final url = Uri.parse(
      'http://10.0.2.2:5000/api/v1/days/$dayId/daily-tasks',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'isDone': false}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Task created: ${response.body}');
      // Optionally trigger a refresh of the UI
    } else {
      print('Failed to create task: ${response.body}');
    }
  }

  void _showCreateTaskDialog(BuildContext context, String dayId) {
    final TextEditingController taskNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(
              16.0,
            ), // Add padding for better visual spacing
            child: Column(
              mainAxisSize:
                  MainAxisSize
                      .min, // Ensure the column takes minimal vertical space
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align content to the start
              children: [
                Text(
                  'Add Daily Task',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: taskNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter task name',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween, // Align buttons to the end
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 150,
                      child: CustomButtonSmall(
                        onPressed: () async {
                          final name = taskNameController.text.trim();
                          if (name.isNotEmpty) {
                            await _createDailyTask(dayId, name);
                            Navigator.pop(context);
                          }
                        },
                        label: 'Create task',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _messageFuture = fetchMessage();
    fetchDayEntry(_selectedDate);
  }

  static const int _referencePage = 1000; // So we can scroll both ways
  final PageController _pageController = PageController(
    initialPage: _referencePage,
  );
  int _currentPage = _referencePage; // track current page

  DateTime _getDateFromPage(int pageIndex) {
    int offset = pageIndex - _referencePage;
    return DateTime.now().add(Duration(days: 7 * offset));
  }

  void _onPageChanged(int pageIndex) {
    final newDate = _getDateFromPage(pageIndex);
    setState(() {
      _selectedDate = newDate;
      _currentPage = pageIndex;
    });
    fetchDayEntry(newDate);
  }

  void _onDateSelected(DateTime date) {
    final int pageIndex =
        _referencePage + date.difference(DateTime.now()).inDays ~/ 7;
    setState(() {
      _selectedDate = date;
      _currentPage = pageIndex;
    });
    _pageController.jumpToPage(pageIndex);
    fetchDayEntry(date);
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
            onDateSelected: _onDateSelected,
            pageController: _pageController,
            currentPage: _currentPage,
            onPageChanged: _onPageChanged,
          ),

          Expanded(
            child:
                _isLoadingDayEntry
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
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
                          if (_dayEntry != null &&
                              (selectedMoodIndex == null || showMoodSelector))
                            Column(
                              children: [
                                MoodsCard(
                                  selectedMoodIndex: selectedMoodIndex,
                                  onMoodSelected: (index) async {
                                    setState(() {
                                      selectedMoodIndex = index;
                                      showMoodSelector = false;
                                    });

                                    await updateMood(index);

                                    setState(() {
                                      // Update the local _dayEntry object with new mood
                                      if (_dayEntry != null) {
                                        _dayEntry = DayEntry(
                                          id: _dayEntry!.id,
                                          dayEntryDate: _dayEntry!.dayEntryDate,
                                          mood: index,
                                          journalEntries:
                                              _dayEntry!.journalEntries,
                                          dailyTasks: _dayEntry!.dailyTasks,
                                        );
                                      }
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Daily tasks",
                                            style: TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          GestureDetector(
                                            onTap:
                                                () => _showCreateTaskDialog(
                                                  context,
                                                  _dayEntry!.id,
                                                ),
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                foregroundColor: Colors.white,
                                                child: const Icon(
                                                  Icons.add,
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      if (_dayEntry!.dailyTasks.isNotEmpty)
                                        ..._dayEntry!.dailyTasks.map(
                                          (task) => DailyTaskCard(
                                            dayId: _dayEntry!.id,
                                            taskId: task.id,
                                            name: task.name,
                                            isDone: task.isDone,
                                            onUpdated: () {
                                              setState(() {}); // Refresh view
                                            },
                                          ),
                                        )
                                      else
                                        const Text(
                                          'No daily tasks for this day.',
                                        ),
                                    ],
                                  ),
                                ),
                                if (_dayEntry != null &&
                                    selectedMoodIndex != null &&
                                    !showMoodSelector)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Today's mood",
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.secondary,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap:
                                            () => setState(
                                              () => showMoodSelector = true,
                                            ),
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
                                              MoodsCard
                                                  .moods[selectedMoodIndex!],
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
                          SizedBox(height: 16),
                          Expanded(
                            child: ListView(
                              children: [
                                Text(
                                  "Journal entries",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.secondary,
                                  ),
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
