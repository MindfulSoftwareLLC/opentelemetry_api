/// Converts a DateTime value to a string in the format:
/// "yyyy-MM-ddTHH:mm:ss.SSSZ"
/// Avoid intl dependency
String dateTimeToString(DateTime value) {
  final utc = value.toUtc();
  final year = utc.year.toString().padLeft(4, '0');
  final month = utc.month.toString().padLeft(2, '0');
  final day = utc.day.toString().padLeft(2, '0');
  final hour = utc.hour.toString().padLeft(2, '0');
  final minute = utc.minute.toString().padLeft(2, '0');
  final second = utc.second.toString().padLeft(2, '0');
  final millisecond = utc.millisecond.toString().padLeft(3, '0');
  return '$year-$month-${day}T$hour:$minute:$second.${millisecond}Z';
}

/*
A regex version would work too TODO - performance test
String dateTimeToString(DateTime value) {
  final isoString = value.toUtc().toIso8601String();
  // This regex truncates the fractional seconds to exactly 3 digits.
  final formatted = isoString.replaceFirst(RegExp(r'\.(\d{3})\d*'), '.$1');
  return formatted.endsWith('Z') ? formatted : '$formattedZ';
}
*/
