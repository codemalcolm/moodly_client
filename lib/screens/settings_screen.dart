import 'package:flutter/material.dart';
import 'package:moodly_client/theme/theme_notifier.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('App color', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children:
              [
                AccentColors.blue,
                AccentColors.red,
                AccentColors.orange,
                AccentColors.green,
                AccentColors.yellow,
                AccentColors.purple,
              ].map((color) {
                return GestureDetector(
                  onTap: () => themeNotifier.setPrimaryColor(color),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: color,
                    child:
                        themeNotifier.primaryColor == color
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                  ),
                );
              }).toList(),
        ),
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: themeNotifier.isDarkMode,
          onChanged: (value) {
            themeNotifier.toggleDarkMode(value);
          },
        ),
      ],
    );
  }
}
