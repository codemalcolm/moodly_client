import 'package:flutter/material.dart';

class EntryCard extends StatelessWidget {
  final String title;
  final String text;
  final String time;
  final List<String> images;
  final Color backgroundColor;

  const EntryCard({
    super.key,
    required this.title,
    required this.text,
    required this.time,
    required this.images,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
              Text(time, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 4),
          Text(text, style: theme.textTheme.bodyMedium),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                return Image.network(images[index], fit: BoxFit.cover);
              },
            ),
          ],
        ],
      ),
    );
  }
}
