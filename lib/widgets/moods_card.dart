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

  static List<Color> moodColors = [
    const Color.fromARGB(138, 207, 32, 88),
    const Color.fromARGB(138, 255, 117, 126),
    const Color.fromARGB(139, 0, 150, 135),
    const Color.fromARGB(138, 161, 27, 185),
    const Color.fromARGB(138, 255, 134, 41),
    const Color.fromARGB(137, 29, 18, 181),
    const Color.fromARGB(136, 73, 226, 42),
    const Color.fromARGB(137, 61, 38, 120),
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
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
              mainAxisExtent: 60,
            ),
            itemCount: moods.length,
            itemBuilder: (context, index) {
              final isSelected = selectedMoodIndex == index;
              return GestureDetector(
                onTap: () => onMoodSelected(index),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: moodColors[index],
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
          SizedBox(height: 5),
        ],
      ),
    );
  }
}
