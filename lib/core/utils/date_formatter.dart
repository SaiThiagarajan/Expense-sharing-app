const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Formats a date relative to today, e.g. `Today`, `Yesterday`, `3 days
/// ago`, `Tomorrow`, `In 2 days`, falling back to `Aug 12` for anything
/// further away in the current year and `Aug 12, 2025` for other years.
String formatRelativeDate(DateTime date, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final day = DateTime.utc(date.year, date.month, date.day);
  final reference = DateTime.utc(today.year, today.month, today.day);
  final diff = reference.difference(day).inDays;

  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff > 1 && diff < 7) return '$diff days ago';
  if (diff == -1) return 'Tomorrow';
  if (diff < -1 && diff > -7) return 'In ${-diff} days';

  final monthDay = '${_monthNames[date.month - 1]} ${date.day}';
  return date.year == today.year ? monthDay : '$monthDay, ${date.year}';
}

/// Formats a date as an activity feed section header, e.g. `AUGUST 2026`.
String formatMonthHeader(DateTime date) {
  return '${_monthNames[date.month - 1].toUpperCase()} ${date.year}';
}
