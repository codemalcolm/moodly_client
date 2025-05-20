import 'package:flutter/material.dart';
import 'package:moodly_client/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';

class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final theme = Theme.of(context);

    Widget buildOption(ThemeMode mode, IconData icon, String label) {
      final isSelected = themeNotifier.themeMode == mode;
      final selectedColor = getAccentBackgroundColor(theme.colorScheme.primary);
      final borderColor =
          isSelected ? theme.colorScheme.primary : Colors.transparent;

      return Expanded(
        child: GestureDetector(
          onTap: () => themeNotifier.setThemeMode(mode),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? selectedColor : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: theme.iconTheme.color),
                const SizedBox(height: 8),
                Text(label, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        buildOption(ThemeMode.system, Icons.computer, 'System'),
        const SizedBox(width: 8),
        buildOption(ThemeMode.light, Icons.light_mode, 'Light'),
        const SizedBox(width: 8),
        buildOption(ThemeMode.dark, Icons.dark_mode, 'Dark'),
      ],
    );
  }
}
