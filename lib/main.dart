import 'package:flutter/material.dart';
import 'package:moodly_client/widgets/app_scaffold.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter + Node + Mongo',
      initialRoute: '/day-view',
      routes: {
        '/day-view': (context) => const AppScaffold(currentIndex: 0),
        '/fasties': (context) => const AppScaffold(currentIndex: 1),
        '/settings': (context) => const AppScaffold(currentIndex: 2),
        '/new-entry': (context) => const AppScaffold(currentIndex: 3),
      },
    );
  }
}
