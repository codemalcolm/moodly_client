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
  bool _showActions = false;
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _isDone = widget.isDone;
    _controller = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  Future<void> _editTask() async {
    if (_isEditing) {
      final newName = _controller.text.trim();

      if (newName.isEmpty) return;

      final url = Uri.parse(
        'http://10.0.2.2:5000/api/v1/days/${widget.dayId}/daily-tasks/${widget.taskId}',
      );

      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': newName}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isEditing = false;
          _showActions = false;
        });

        widget.onUpdated();
      } else {
        debugPrint('Failed to edit daily task');
      }
    } else {
      // Enter editting mode
      setState(() {
        _isEditing = true;
      });
    }
  }

  Future<void> _deleteTask() async {
    final url = Uri.parse(
      'http://10.0.2.2:5000/api/v1/days/${widget.dayId}/daily-tasks/${widget.taskId}',
    );

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      widget.onUpdated();
    } else {
      debugPrint('Failed to delete daily task');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _showActions = true;
        });
      },
      onTap: () {
        if (_showActions && !_isEditing) {
          setState(() {
            _showActions = false;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 4),
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
            Expanded(
              child:
                  _isEditing
                      ? TextField(
                        style: TextStyle(fontSize: 14),
                        controller: _controller,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          border: InputBorder.none,
                        ),
                        autofocus: true,
                      )
                      : Text(
                        widget.name,
                        style: TextStyle(
                          decoration:
                              _isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
            ),
            if (_showActions) ...[
              GestureDetector(
                onTap: _editTask,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(_isEditing ? Icons.check : Icons.edit, size: 18),
                ),
              ),
              GestureDetector(
                onTap: _deleteTask,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.delete, size: 18, color: Colors.red),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ],
        ),
      ),
    );
  }
}
