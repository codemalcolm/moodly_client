import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodly_client/screens/calendar_overview_page.dart';

class CalendarTab extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  CalendarTab({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
  });

  List<DateTime> _getWeekDates(DateTime startDate) {
    final monday = startDate.subtract(Duration(days: startDate.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  // this is needed to scroll back !!!
  static const int _referencePage = 1000;
  final DateTime _referenceDate = DateTime.now(); //start date

  DateTime _getDateFromPage(int pageIndex) {
    final offset = pageIndex - CalendarTab._referencePage;
    return _referenceDate.add(Duration(days: 7 * offset));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final month = DateFormat('MMMM').format(selectedDate);
    final year = DateFormat('yyyy').format(selectedDate);

    return Container(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 8),
      decoration: BoxDecoration(color: theme.colorScheme.surface),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push<DateTime>(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => CalendarOverviewPage(initialDate: selectedDate),
                ),
              );
              if (result != null) {
                onDateSelected(result);
              }
            },
            child: Row(
              children: [
                Text(
                  month,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  year,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 80,
            child: PageView.builder(
              controller: pageController,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                final weekStart = _getDateFromPage(index);
                final weekDates = _getWeekDates(weekStart);

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:
                        weekDates.map((date) {
                          final isSelected =
                              date.day == selectedDate.day &&
                              date.month == selectedDate.month &&
                              date.year == selectedDate.year;

                          return GestureDetector(
                            onTap: () => onDateSelected(date),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat.E().format(date),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Text(
                                        date.day.toString(),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      if (isSelected)
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary
                                                .withAlpha(90),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
