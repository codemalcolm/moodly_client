import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter + Node + Mongo', home: MainPage());
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final String backendUrl = 'http://10.0.2.2:5000/api/v1/entries';

  Future<String> fetchMessage() async {
    final response = await http.get(Uri.parse(backendUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body)['message'];
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<Widget> get _pages => [
    FutureBuilder<String>(
      future: fetchMessage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));
        return Center(child: Text(snapshot.data ?? 'No message'));
      },
    ),
    Center(child: Text('Moody Page')),
    Center(child: Text('Settings Page')),
    Center(child: Text('Add Entry Page')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fullstack App')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: NavigationBar(
          height: 68.0,
          indicatorColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.home_outlined, size: 30.0),
              selectedIcon: Icon(Icons.home, size: 30.0),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.pets_outlined, size: 30.0),
              selectedIcon: Icon(
                Icons.pets_outlined,
                color: Colors.black,
                size: 30.0,
              ),
              label: 'Moody',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, size: 30.0),
              selectedIcon: Icon(Icons.settings, size: 30.0),
              label: 'Settings',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline, size: 30.0),
              selectedIcon: Icon(Icons.add_circle, size: 30.0),
              label: 'Add Entry',
            ),
          ],
        ),
      ),
    );
  }
}
