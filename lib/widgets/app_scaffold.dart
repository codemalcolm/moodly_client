import 'package:flutter/material.dart';
import '../screens/day_view_screen.dart';
import '../screens/all_entries_screen.dart';
import '../screens/calendar_view_screen.dart';
import '../screens/new_entry_screen.dart';
import '../screens/settings_screen.dart';

class AppScaffold extends StatelessWidget {
  final int currentIndex;
  const AppScaffold({super.key, required this.currentIndex});

  static final List<Widget> _pages = [
    DayViewScreen(),
    AllEntriesScreen(),
    CalendarViewScreen(),
    NewEntryScreen(),
    SettingsScreen(),
  ];

  static final List<String> _routes = [
    '/day-view',
    '/all-entries',
    '/calendar-view',
    '/new-entry',
    '/settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fullstack App')),
      body: _pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (int index) {
          if (index != currentIndex) {
            Navigator.pushReplacementNamed(context, _routes[index]);
          }
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.today_outlined), label: 'Day'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Entries'),
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: 'New',
          ),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
