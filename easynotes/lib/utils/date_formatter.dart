import 'package:intl/intl.dart';

class AppDateFormatter {
  static String formatNoteDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0 && dateTime.day == now.day) {
      // Today: display time
      return DateFormat('hh:mm a').format(dateTime);
    } else if (difference.inDays <= 1 || (difference.inHours < 48 && dateTime.day == now.subtract(const Duration(days: 1)).day)) {
      // Yesterday
      return 'Yesterday, ${DateFormat('hh:mm a').format(dateTime)}';
    } else if (difference.inDays < 7) {
      // Within this week
      return DateFormat('EEE, MMM d').format(dateTime);
    } else if (dateTime.year == now.year) {
      // Same year
      return DateFormat('MMM d').format(dateTime);
    } else {
      // Different year
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }

  static String formatFullDate(DateTime dateTime) {
    return DateFormat('EEEE, MMMM d, yyyy • hh:mm a').format(dateTime);
  }
}