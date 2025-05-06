import 'package:flutter/material.dart';

class SectionDivider extends StatelessWidget {
  final String label;

  const SectionDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;

    return Row(
      children: [
        const SizedBox(width: 8),
        Expanded(child: Divider(color: color, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(child: Divider(color: color, thickness: 1)),
        const SizedBox(width: 8),
      ],
    );
  }
}
