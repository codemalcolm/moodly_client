import 'package:flutter/material.dart';

class NewEntryScreen extends StatelessWidget {
  const NewEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Enter new mood', style: TextStyle(fontSize: 20)),
          SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              labelText: 'How do you feel?',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Entry',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Später: abspeichern
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Entry saved (not really 😄)')),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
