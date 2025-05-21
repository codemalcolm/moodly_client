import 'package:flutter/material.dart';

class MoodUtils {
  static const List<Color> moodColors = [
    Color.fromARGB(138, 207, 32, 88),
    Color.fromARGB(138, 255, 117, 126),
    Color.fromARGB(139, 0, 150, 135),
    Color.fromARGB(138, 161, 27, 185),
    Color.fromARGB(138, 255, 134, 41),
    Color.fromARGB(149, 83, 75, 203),
    Color.fromARGB(136, 73, 226, 42),
    Color.fromARGB(149, 81, 58, 139),
  ];

  static Color getBackgroundColorForMood(int? mood) {
    if (mood == null || mood < 0 || mood >= moodColors.length) {
      return Colors.transparent;
    }
    return moodColors[mood];
  }
}
