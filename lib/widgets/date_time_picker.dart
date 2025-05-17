import 'package:flutter/material.dart';

class DateTimePicker {
  static Future<DateTime?> pickDateTime({
    required BuildContext context,
    required DateTime initialDateTime,
  }) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) return null;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );

    if (pickedTime == null) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }
}
