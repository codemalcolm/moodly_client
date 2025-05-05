import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onTap;

  const CustomCard({super.key, this.text, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (text != null)
          Text(
            text!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        if (icon != null) ...[
          const SizedBox(height: 12),
          Icon(icon, size: 32, color: colorScheme.onSurface),
        ],
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(112, 0, 0, 0),
              offset: const Offset(2, 0),
              blurRadius: 6,
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}
