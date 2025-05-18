import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DailyTaskCard extends StatefulWidget {
  final String dayId;
  final String taskId;
  final String name;
  final bool isDone;
  final VoidCallback onUpdated;

  const DailyTaskCard({
    super.key,
    required this.dayId,
    required this.taskId,
    required this.name,
    required this.isDone,
    required this.onUpdated,
  });

  @override
  State<DailyTaskCard> createState() => _DailyTaskCardState();
}

class _DailyTaskCardState extends State<DailyTaskCard> {
  late bool _isDone;

  @override
  void initState() {
    super.initState();
    _isDone = widget.isDone;
  }

  Future<void> _toggleIsDone() async {
    final newStatus = !_isDone;

    final url = Uri.parse(
      'http://10.0.2.2:5000/api/v1/days/${widget.dayId}/daily-tasks/${widget.taskId}',
    );

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'isDone': newStatus}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _isDone = newStatus;
      });

      widget.onUpdated();
    } else {
      debugPrint('Failed to update daily task');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.symmetric(vertical: 4),
      width: double.infinity,
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(width: 1, color: Colors.transparent),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Checkbox(value: _isDone, onChanged: (_) => _toggleIsDone()),
          Text(
            widget.name,
            style: TextStyle(
              decoration: _isDone ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}
