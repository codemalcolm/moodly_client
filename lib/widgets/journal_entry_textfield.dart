import 'package:flutter/material.dart';

class JournalEntryTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const JournalEntryTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.maxLines = 4,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(30, 0, 0, 0),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
