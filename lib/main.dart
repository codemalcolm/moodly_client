import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodly_client/blocs/daily_task_bloc/daily_task_repository.dart';
import 'package:moodly_client/screens/fasties_settings_screen.dart';
import 'package:moodly_client/screens/image_preview_screen.dart';
import 'package:moodly_client/screens/settings_account_screen.dart';
import 'package:moodly_client/theme/app_theme.dart';
import 'package:moodly_client/theme/theme_notifier.dart';
import 'package:moodly_client/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

void main() {
  final dailyTaskRepository = DailyTaskRepository();
  final themeNotifier = ThemeNotifier();

  runApp(
    RepositoryProvider<DailyTaskRepository>.value(
      value: dailyTaskRepository,
      child: ChangeNotifierProvider.value(
        value: themeNotifier,
        child: FutureBuilder(
          future: themeNotifier.isInitialized,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return const MyApp();
            } else {
              return const MaterialApp(
                home: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
            }
          },
        ),
      ),
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
        '/day-view':
            (context) => const AppScaffold(currentIndex: 0, showAppBar: false),
        '/all-entries': (context) => const AppScaffold(currentIndex: 1),
        '/new-entry':
            (context) => const AppScaffold(currentIndex: 2, showAppBar: false),
        '/fasties': (context) => const AppScaffold(currentIndex: 3),
        '/settings': (context) => const AppScaffold(currentIndex: 4),
        '/settings-account': (context) => const SettingsAccountScreen(),
        '/fasties-settings': (context) => const FastiesSettingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/image-preview') {
          final args = settings.arguments as File;
          return MaterialPageRoute(
            builder: (context) => ImagePreviewScreen(image: args),
          );
        }
        return MaterialPageRoute(
          builder:
              (context) =>
                  const Scaffold(body: Center(child: Text('Page not found'))),
        );
      },
    );
  }
}
