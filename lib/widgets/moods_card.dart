import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MoodsCard extends StatelessWidget {
  final List<String> moodIconPaths;
  final int? selectedMoodIndex;
  final ValueChanged<int> onMoodSelected;

  const MoodsCard({
    super.key,
    required this.moodIconPaths,
    required this.selectedMoodIndex,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
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
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // z. B. 4 Spalten
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: moodIconPaths.length,
            itemBuilder: (context, index) {
              final isSelected = selectedMoodIndex == index;

              return GestureDetector(
                onTap: () => onMoodSelected(index),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: SvgPicture.asset(
                    moodIconPaths[index],
                    width: 40,
                    height: 40,
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
