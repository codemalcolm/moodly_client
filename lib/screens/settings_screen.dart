import 'package:flutter/material.dart';
import 'package:moodly_client/theme/theme_notifier.dart';
import 'package:moodly_client/widgets/section_divider.dart';
import 'package:moodly_client/widgets/theme_mode_selector.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/settings-account');
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(73, 36, 36, 36),
                    offset: const Offset(0, 2),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Username',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'user@moodly.com',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionDivider(label: 'Appearance'),
          const SizedBox(height: 14),
          Text('App color', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Center(
            child: Wrap(
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
                                ? const Icon(
                                  Icons.circle_outlined,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Theme mode', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const ThemeModeSelector(),
          // const SizedBox(height: 24),
          // const SectionDivider(label: 'Notifications'),
          // const SizedBox(height: 14),
        ],
      ),
    );
  }
}
