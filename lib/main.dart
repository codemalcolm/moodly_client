import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final String backendUrl =
      'http://10.0.2.2:5000/api/v1/entries'; // for emulator use 10.0.2.2

  Future<String> fetchMessage() async {
    final response = await http.delete(Uri.parse(backendUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body)['message'];
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter + Node + Mongo',
      home: Scaffold(
        appBar: AppBar(title: Text('Fullstack App')),
        body: FutureBuilder<String>(
          future: fetchMessage(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            return Center(child: Text(snapshot.data ?? 'No message'));
          },
        ),
      ),
    );
  }
}
