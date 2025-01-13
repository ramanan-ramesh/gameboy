extension DateTimeExt on DateTime {
  int numberOfDaysInBetween(DateTime other) {
    var day1 = DateTime(year, month, day);
    var day2 = DateTime(other.year, other.month, other.day);
    return day1.difference(day2).abs().inDays;
  }
}

extension StringExt on String {
  bool isEqualTo(String other) {
    return toLowerCase() == other.toLowerCase();
  }

  int comparedTo(String other, bool isCaseSensitive) {
    if (!isCaseSensitive) {
      return toLowerCase().compareTo(other.toLowerCase());
    }
    return compareTo(other);
  }

  bool doesContain(String other) => toLowerCase().contains(other.toLowerCase());
}
