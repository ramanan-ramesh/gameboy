extension DateTimeExt on DateTime {
  bool isOnSameDayAs(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  int numberOfDaysInBetween(DateTime other) {
    var day1 = DateTime(year, month, day);
    var day2 = DateTime(other.year, other.month, other.day);
    return day1.difference(day2).inDays;
  }
}
