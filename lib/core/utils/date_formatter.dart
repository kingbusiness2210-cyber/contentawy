import 'package:intl/intl.dart';

class DateFormatter {
  static String formatShort(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  static String formatFull(DateTime date) {
    return DateFormat('EEEE، d MMMM yyyy', 'ar').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes <= 1) return 'الآن';
        return 'منذ ${difference.inMinutes} دقيقة';
      }
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return DateFormat('yyyy/MM/dd').format(date);
    }
  }

  static String getDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'صباح الفل والإنتاجية 👋';
    } else if (hour >= 12 && hour < 18) {
      return 'مساء الخير والتوفيق 👋';
    } else {
      return 'مساء الجمال والروقان 👋';
    }
  }
}
