import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moodly_client/widgets/mood_utils.dart';

class Mood {
  final String name;
  final String iconPath;
  Mood({required this.name, required this.iconPath});
}

class MoodsCard extends StatelessWidget {
  final int? selectedMoodIndex;
  final ValueChanged<int> onMoodSelected;

  static List<String> moods = [
    'assets/icons/icon_mood_0.svg',
    'assets/icons/icon_mood_1.svg',
    'assets/icons/icon_mood_2.svg',
    'assets/icons/icon_mood_3.svg',
    'assets/icons/icon_mood_4.svg',
    'assets/icons/icon_mood_5.svg',
    'assets/icons/icon_mood_6.svg',
    'assets/icons/icon_mood_7.svg',
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
                    color: MoodUtils.moodColors[index],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isSelected
                              ? theme.colorScheme.onPrimary
                              : const Color.fromARGB(0, 0, 0, 0),
                      width: 2,
                    ),
                  ),
                  child: SvgPicture.asset(
                    moods[index],
                    colorFilter: ColorFilter.mode(
                      isSelected
                          ? theme.colorScheme.onPrimary
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
