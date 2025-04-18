class BeeWiseConstants {
  static const numberOfLetters = 7;

  static String rankCalculator(int score) {
    if (score >= 105) {
      return 'Genius';
    } else if (score >= 75) {
      return 'Amazing';
    } else if (score >= 60) {
      return 'Great';
    } else if (score >= 38) {
      return 'Nice';
    } else if (score >= 23) {
      return 'Solid';
    } else if (score >= 12) {
      return 'Good';
    } else if (score >= 8) {
      return 'Moving Up';
    } else if (score >= 3) {
      return 'Good Start';
    } else {
      return 'Beginner';
    }
  }

  static List<String> get ranks => [
        'Beginner',
        'Good Start',
        'Moving Up',
        'Good',
        'Solid',
        'Nice',
        'Great',
        'Amazing',
        'Genius',
      ];
}
