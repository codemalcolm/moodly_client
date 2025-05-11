import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FastieTaskCard extends StatefulWidget {
  final String task;
  final String category;
  final void Function(bool isCompleted)? onCompletedOrDelete;

  const FastieTaskCard({
    super.key,
    required this.task,
    required this.category,
    required bool isCompleted,
    this.onCompletedOrDelete,
  });

  @override
  State<FastieTaskCard> createState() => _FastieTaskCardState();
}

class _FastieTaskCardState extends State<FastieTaskCard> {
  bool isCompleted = false;
  late String todayKey;

  @override
  void initState() {
    super.initState();
    todayKey = DateTime.now().toIso8601String().substring(0, 10);
    _loadCompletionState();
  }

  Future<void> _loadCompletionState() async {
    final prefs = await SharedPreferences.getInstance();
    final completedFasties =
        prefs.getStringList('completedFasties_$todayKey') ?? [];
    setState(() {
      isCompleted = completedFasties.contains(widget.task);
    });
  }

  Future<void> _completeFastie() async {
    final prefs = await SharedPreferences.getInstance();
    final completedFasties =
        prefs.getStringList('completedFasties_$todayKey') ?? [];

    if (!completedFasties.contains(widget.task)) {
      completedFasties.add(widget.task);
      await prefs.setStringList('completedFasties_$todayKey', completedFasties);
      setState(() {
        isCompleted = true;
      });
      widget.onCompletedOrDelete?.call(true);
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Fastie?'),
            content: const Text('Do you really want to delete this Fastie?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  widget.onCompletedOrDelete?.call(false);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 16,
      color: isCompleted ? Colors.grey : null,
      decoration: isCompleted ? TextDecoration.lineThrough : null,
    );

    return Opacity(
      opacity: isCompleted ? 0.4 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        height: 80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Text(widget.task, style: textStyle)),
            const SizedBox(width: 12),
            Column(
              children: [
                if (!isCompleted && widget.onCompletedOrDelete != null)
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: _showDeleteDialog,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: Colors.grey,
                        iconSize: 20,
                      ),
                    ),
                  ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.center,
                    child: Checkbox(
                      value: isCompleted,
                      onChanged:
                          isCompleted
                              ? null
                              : (val) {
                                if (val == true) _completeFastie();
                              },
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
