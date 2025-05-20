import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodly_client/blocs/daily_task_bloc/daily_task_bloc.dart';
import 'package:moodly_client/blocs/daily_task_bloc/daily_task_event.dart';
import 'package:moodly_client/models/daily_task_model.dart';

class DailyTaskCardBloc extends StatefulWidget {
  final String dayId;
  final DailyTask task;

  const DailyTaskCardBloc({
    super.key,
    required this.dayId,
    required this.task,
  });

  @override
  State<DailyTaskCardBloc> createState() => _DailyTaskCardBlocState();
}

class _DailyTaskCardBlocState extends State<DailyTaskCardBloc> {
  bool _showActions = false;
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleIsDone() {
    context.read<DailyTaskBloc>().add(
          ToggleTaskDone(
            widget.dayId,
            widget.task.id,
            !widget.task.isDone,
          ),
        );
  }

  void _editTask() {
    if (_isEditing) {
      final newName = _controller.text.trim();
      if (newName.isEmpty || newName == widget.task.name) return;

      context.read<DailyTaskBloc>().add(
            EditDailyTask(
              widget.dayId,
              widget.task.id,
              newName,
            ),
          );

      setState(() {
        _isEditing = false;
        _showActions = false;
      });
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  void _deleteTask() {
    context.read<DailyTaskBloc>().add(
          DeleteDailyTask(widget.dayId, widget.task.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onLongPress: () {
        setState(() => _showActions = true);
      },
      onTap: () {
        if (_showActions && !_isEditing) {
          setState(() => _showActions = false);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 4),
        width: double.infinity,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Checkbox(
              value: widget.task.isDone,
              onChanged: (_) => _toggleIsDone(),
            ),
            Expanded(
              child: _isEditing
                  ? TextField(
                      controller: _controller,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: InputBorder.none,
                      ),
                      autofocus: true,
                    )
                  : Text(
                      widget.task.name,
                      style: TextStyle(
                        decoration: widget.task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
            ),
            if (_showActions) ...[
              GestureDetector(
                onTap: _editTask,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    _isEditing ? Icons.check : Icons.edit,
                    size: 18,
                  ),
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
