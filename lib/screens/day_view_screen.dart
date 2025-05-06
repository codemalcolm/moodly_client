import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DayViewScreen extends StatefulWidget {
  const DayViewScreen({super.key});

  @override
  State<DayViewScreen> createState() => _DayViewScreenState();
}

class _DayViewScreenState extends State<DayViewScreen> {
  final String backendUrl = 'http://10.0.2.2:5000/api/v1/entries';

  late Future<String> _messageFuture;

  Future<String> fetchMessage() async {
    final response = await http.get(Uri.parse(backendUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body)['message'];
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _messageFuture = fetchMessage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _messageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return Center(
          child: Text(
            snapshot.data ?? 'No message received',
            style: const TextStyle(fontSize: 18),
          ),
        );
      },
    );
  }
}
