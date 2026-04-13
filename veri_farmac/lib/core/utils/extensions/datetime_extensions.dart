// Extensions for DateTime.
extension DateTimeExtension on DateTime {
  // Short date: '15 Jan 2024'
  String get shortDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '$day ${months[month - 1]} $year';
  }

  // Relative date: 'Today', 'Yesterday' or the short date
  String get relativeDate {
    final today = DateTime.now();
    final diff = DateTime(today.year, today.month, today.day)
        .difference(DateTime(year, month, day))
        .inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return shortDate;
  }

  // Whether the date has already passed (useful for expired records)
  bool get isExpired => isBefore(DateTime.now());
}
