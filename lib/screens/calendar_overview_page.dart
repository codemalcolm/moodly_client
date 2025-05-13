// This is the updated CalendarOverviewPage with weekday headers and a barrel-style month/year picker.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodly_client/widgets/custom_button.dart';

class CalendarOverviewPage extends StatefulWidget {
  final DateTime initialDate;

  const CalendarOverviewPage({super.key, required this.initialDate});

  @override
  State<CalendarOverviewPage> createState() => _CalendarOverviewPageState();
}

class _CalendarOverviewPageState extends State<CalendarOverviewPage> {
  late DateTime _displayedMonth;
  DateTime? _selectedDate;
  late bool _monthYearPickerShowing;

  @override
  void initState() {
    super.initState();

    _displayedMonth = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
    );
    _monthYearPickerShowing = false;
  }

  List<Widget> _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );
    final daysInMonth = DateUtils.getDaysInMonth(
      _displayedMonth.year,
      _displayedMonth.month,
    );
    final weekdayOffset =
        (firstDayOfMonth.weekday + 6) % 7; // Start from Monday

    return List.generate(weekdayOffset + daysInMonth, (index) {
      if (index < weekdayOffset) return const SizedBox();

      final day = index - weekdayOffset + 1;
      final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
      final isSelected =
          _selectedDate != null && _selectedDate!.isAtSameMomentAs(date);
      return GestureDetector(
        onTap: () => setState(() => _selectedDate = date),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isSelected)
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              Text(
                day.toString(),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showMonthYearPicker() async {
    int selectedYear = _displayedMonth.year;
    int selectedMonth = _displayedMonth.month;

    // Mark picker as showing
    setState(() {
      _monthYearPickerShowing = true;
    });

    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return SizedBox(
          height: 250,
          child: Row(
            children: [
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedMonth - 1,
                  ),
                  itemExtent: 32,
                  onSelectedItemChanged: (index) {
                    selectedMonth = index + 1;
                  },
                  children: List.generate(
                    12,
                    (index) => Center(
                      child: Text(
                        DateFormat.MMMM().format(DateTime(0, index + 1)),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedYear - 2020,
                  ),
                  itemExtent: 32,
                  onSelectedItemChanged: (index) {
                    selectedYear = 2020 + index;
                  },
                  children: List.generate(
                    31,
                    (index) => Center(child: Text((2020 + index).toString())),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // Picker was dismissed
    setState(() {
      _monthYearPickerShowing = false;
      _displayedMonth = DateTime(selectedYear, selectedMonth);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthYear = DateFormat.yMMMM().format(_displayedMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 12,
              bottom: 12,
              left: 24,
              right: 24,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _showMonthYearPicker,
                  child: Row(
                    children: [
                      Text(
                        monthYear,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _monthYearPickerShowing
                            ? Icons.chevron_right
                            : Icons.expand_more,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Weekday Headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children:
                  ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .map(
                        (day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),

          // Calendar Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              children: _buildCalendarGrid(),
            ),
          ),

          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Text("Data about day displayed here"),
                  const SizedBox(height: 220),
                  CustomButton(
                    onPressed: () => Navigator.pop(context, _selectedDate),
                    label: 'View Details',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
