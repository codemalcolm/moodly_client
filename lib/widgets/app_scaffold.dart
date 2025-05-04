import 'package:flutter/material.dart';
import 'package:moodly_client/screens/fasties_screen.dart';
import '../screens/day_view_screen.dart';
import '../screens/new_entry_screen.dart';
import '../screens/settings_screen.dart';

class AppScaffold extends StatelessWidget {
  final int currentIndex;
  const AppScaffold({super.key, required this.currentIndex});

  static final List<Widget> _pages = [
    DayViewScreen(),
    FastiesScreen(),
    SettingsScreen(),
    NewEntryScreen(),
  ];

  static final List<String> _routes = [
    '/day-view',
    '/fasties',
    '/settings',
    '/new-entry',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moodly')),
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
          NavigationDestination(icon: Icon(Icons.pets), label: 'Moodly'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: 'New',
          ),
        ],
      ),
    );
  }
}
