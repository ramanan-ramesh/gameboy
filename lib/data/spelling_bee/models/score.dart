class Score {
  int score;
  String rank;
  int get rankIndex => allRanks.indexOf(rank);
  Score({required this.score, required this.rank});

  static const allRanks = [
    'Beginner',
    'Good Start',
    'Moving Up',
    'Good',
    'Solid',
    'Nice',
    'Great',
    'Amazing'
  ];
}
