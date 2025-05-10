import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarTab extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const CalendarTab({
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

  DateTime _getDateFromPage(int pageIndex) {
    int offset = pageIndex - currentPage;
    return selectedDate.add(Duration(days: 7 * offset));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final month = DateFormat('MMMM').format(selectedDate);
    final year = DateFormat('yyyy').format(selectedDate);

    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
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
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    year,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 60,
            child: PageView.builder(
              controller: pageController,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                final weekStart = _getDateFromPage(index)
                    .subtract(Duration(days: selectedDate.weekday - 1));
                final weekDates = _getWeekDates(weekStart);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: weekDates.map((date) {
                      final isSelected = date.day == selectedDate.day &&
                          date.month == selectedDate.month &&
                          date.year == selectedDate.year;

                      return GestureDetector(
                        onTap: () => onDateSelected(date),
                        child: Column(
                          children: [
                            Text(
                              DateFormat.E().format(date),
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 24,
                              height: 24,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text(
                                    date.day.toString(),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  if (isSelected)
                                    Container(
                                      width: 22,
                                      height: 22,
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
