import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:moodly_client/widgets/calendar_tab.dart';

class DayViewScreen extends StatefulWidget {
  const DayViewScreen({super.key});

  @override
  State<DayViewScreen> createState() => _DayViewScreenState();
}

class _DayViewScreenState extends State<DayViewScreen> {
  final String backendUrl = 'http://10.0.2.2:5000/api/v1/entries';
  late Future<String> _messageFuture;

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
            },
            pageController: _pageController,
            currentPage: _currentPage,
            onPageChanged: (pageIndex) {
              setState(() {
                final newDate = _selectedDate.add(
                  Duration(days: 7 * (pageIndex - _currentPage)),
                );
                _selectedDate = newDate;
                _currentPage = pageIndex;
              });
            },
          ),
          SizedBox(height: 16,),
          Text(
            'Selected Date: ${DateFormat('EEE, MMM d, yyyy').format(_selectedDate)}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
