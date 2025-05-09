import 'package:flutter/material.dart';

class FastieTaskCard extends StatefulWidget {
  final String task;
  final String category;
  final VoidCallback onDelete;

  const FastieTaskCard({
    super.key,
    required this.task,
    required this.category,
    required this.onDelete,
  });
  @override
  State<FastieTaskCard> createState() => _FastieTaskCardState();
}

class _FastieTaskCardState extends State<FastieTaskCard> {
  bool isChecked = false;

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
                  widget.onDelete();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
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
          Expanded(
            child: Text(
              widget.task,
              style: TextStyle(
                fontSize: 16,
                decoration: isChecked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Column(
            children: [
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
                    value: isChecked,
                    onChanged: (val) {
                      setState(() {
                        isChecked = val ?? false;
                      });
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
