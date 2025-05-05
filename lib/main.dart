import 'package:flutter/material.dart';
import 'package:moodly_client/screens/settings_account_screen.dart';
import 'package:moodly_client/theme/app_theme.dart';
import 'package:moodly_client/theme/theme_notifier.dart';
import 'package:moodly_client/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Flutter + Node + Mongo',
      theme: themeNotifier.theme,
      darkTheme: AppTheme.darkTheme(themeNotifier.primaryColor),
      themeMode: themeNotifier.themeMode,
      initialRoute: '/day-view',
      routes: {
        '/day-view': (context) => const AppScaffold(currentIndex: 0),
        '/fasties': (context) => const AppScaffold(currentIndex: 1),
        '/settings': (context) => const AppScaffold(currentIndex: 2),
        '/new-entry': (context) => const AppScaffold(currentIndex: 3),
        '/settings-account': (context) => const SettingsAccountScreen(),
      },
    );
  }
}
