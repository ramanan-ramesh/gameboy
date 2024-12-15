extension DateTimeExt on DateTime {
  bool isOnSameDayAs(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

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

  String capitalizeFirstLettersOfWord() {
    String result = '';
    for (var word in split(' ')) {
      if (word.isEmpty) {
        continue;
      }
      if (word.length == 1) {
        result += '${word.toUpperCase()} ';
        continue;
      }
      result += '${word[0].toUpperCase()}${word.substring(1).toLowerCase()} ';
    }
    return result.trim();
  }
}
