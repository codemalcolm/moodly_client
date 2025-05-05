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

  static final List<String> _titles = [
    'Home',
    'Fasties',
    'Settings',
    'New Entry',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[currentIndex]), centerTitle: true),
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
            icon: SvgPicture.asset(
              'assets/icons/icon_home_outlined.svg',
              width: 30,
              height: 30,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/icon_home.svg',
              width: 30,
              height: 30,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary,
                BlendMode.srcIn,
              ),
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
            icon: SvgPicture.asset(
              'assets/icons/icon_settings_outlined.svg',
              width: 30,
              height: 30,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/icon_settings.svg',
              width: 30,
              height: 30,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
            label: 'Settings',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/icon_add_outlined.svg',
              width: 30,
              height: 30,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/icon_add.svg',
              width: 30,
              height: 30,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
            label: 'Add Entry',
          ),
        ],
      ),
    );
  }
}
