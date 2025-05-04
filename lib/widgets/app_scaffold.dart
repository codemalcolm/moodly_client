import 'package:flutter/material.dart';
import 'package:moodly_client/screens/fasties_screen.dart';
import '../screens/day_view_screen.dart';
import '../screens/new_entry_screen.dart';
import '../screens/settings_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        indicatorColor: Colors.transparent,
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              size: 30.0,
              color: Theme.of(context).colorScheme.secondary,
            ),
            selectedIcon: Icon(
              Icons.home,
              size: 30.0,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/moodly_icon_outlined.svg',
              width: 30,
              height: 30,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/moodly_icon.svg',
              width: 30,
              height: 30,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
            label: 'Moodly',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
              size: 30.0,
              color: Theme.of(context).colorScheme.secondary,
            ),
            selectedIcon: Icon(
              Icons.settings,
              size: 30.0,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Settings',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.add_circle_outline,
              size: 30.0,
              color: Theme.of(context).colorScheme.secondary,
            ),
            selectedIcon: Icon(
              Icons.add_circle,
              size: 30.0,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Add Entry',
          ),
        ],
      ),
    );
  }
}
