import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Mood {
  final String name;
  final String iconPath;
  Mood({required this.name, required this.iconPath});
}

class MoodsCard extends StatelessWidget {
  final int? selectedMoodIndex;
  final ValueChanged<int> onMoodSelected;

  static List<String> moods = [
    'assets/icons/icon_mood_angry.svg',
    'assets/icons/icon_mood_good.svg',
    'assets/icons/icon_mood_moody.svg',
    'assets/icons/icon_mood_loving.svg',
    'assets/icons/icon_mood_happy.svg',
    'assets/icons/icon_mood_sad.svg',
    'assets/icons/icon_mood_tired.svg',
    'assets/icons/icon_mood_anxious.svg',
  ];

  const MoodsCard({
    super.key,
    required this.selectedMoodIndex,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(126, 0, 0, 0),
            offset: const Offset(2, 0),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          Text('How do you feel?', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: moods.length,
            itemBuilder: (context, index) {
              final isSelected = selectedMoodIndex == index;
              return GestureDetector(
                onTap: () => onMoodSelected(index),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : const Color.fromARGB(0, 0, 0, 0),
                      width: 2,
                    ),
                  ),
                  child: SvgPicture.asset(
                    moods[index],
                    colorFilter: ColorFilter.mode(
                      isSelected
                          ? theme.colorScheme.primary
                          : theme.iconTheme.color ?? Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
