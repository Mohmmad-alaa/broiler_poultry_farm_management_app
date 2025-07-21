class DateFormatter {
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatDateWithTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String calculateAge(DateTime startDate, [DateTime? endDate]) {
    final end = endDate ?? DateTime.now();
    final difference = end.difference(startDate);
    final days = difference.inDays;

    if (days < 7) {
      return '$days يوم';
    } else {
      final weeks = (days / 7).floor();
      final remainingDays = days % 7;
      return '$weeks أسبوع${remainingDays > 0 ? ' و $remainingDays يوم' : ''}';
    }
  }
}