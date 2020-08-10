import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

DateTime getNow() {
  final DateTime now = DateTime.now();
  return now;
}

DateTime getToday() {
  final DateTime now = getNow();
  final DateTime today = DateTime(now.year, now.month, now.day);
  return today;
}

DateTime getTomorrow() {
  final DateTime now = getNow();
  final DateTime tomorrow = DateTime(now.year, now.month, (now.day + 1));
  return tomorrow;
}

DateTime getDaysAgo(int days) {
  final DateTime now = getNow();
  final DateTime date =
      DateTime(now.year, now.month, now.day).subtract(Duration(days: days));
  return date;
}

DateTime getFirstDayOfWeek() {
  final DateTime today = getToday();
  return today.subtract(Duration(days: today.weekday));
}

DateTime getLastDayOfWeek({
  int offset = 1,
}) {
  final DateTime today = getToday();
  final DateTime lastDayOfWeek = today
    ..add(Duration(days: (DateTime.sunday - today.weekday)));
  return DateTime(
      lastDayOfWeek.year, lastDayOfWeek.month, (lastDayOfWeek.day + offset));
}

Timestamp toTimestamp(
  DateTime date,
) {
  return Timestamp.fromDate(date);
}

String formatTimestamp(
  Timestamp timestamp,
  String format,
) {
  if (timestamp == null) {
    return null;
  }

  return formatDateTime(timestamp.toDate(), format);
}

String formatEpoch(
  int epoch,
  String format, {
  isUtc: false,
}) {
  if (epoch == null) {
    return null;
  }

  DateTime date = DateTime.fromMillisecondsSinceEpoch(epoch, isUtc: isUtc);
  return formatDateTime(date, format);
}

String formatDateTime(
  DateTime date,
  String format,
) {
  return DateFormat(format).format(date);
}

String formatDateStr(
  String dateStr,
  String format,
) {
  if (dateStr == null) {
    return null;
  }

  return formatDateTime(DateTime.parse(dateStr), format);
}

String getDateFormat(
  DateTime date,
) {
  String dateFormat;
  DateTime now = DateTime.now();
  DateTime lastMidnight = DateTime(now.year, now.month, now.day);
  if (date.isBefore(lastMidnight)) {
    dateFormat = 'M/d/yy \'at\' hh:mm a';
  } else {
    dateFormat = 'hh:mm a';
  }

  return dateFormat;
}

DateTime epochToDateTime(
  int epoch,
) {
  DateTime date = DateTime.fromMicrosecondsSinceEpoch(epoch * 1000);
  return date;
}

int dayDiff(
  DateTime date1,
  DateTime date2,
) {
  if ((date1 != null) && (date1 != null)) {
    return date2.difference(date1).inDays;
  }

  return 0;
}
