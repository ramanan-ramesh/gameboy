import 'package:gameboy/data/app/models/stats.dart';

abstract class WordsyStatistics extends Statistics {
  int get numberOfGamesPlayed;

  Iterable<String> get lastGuessedWords;

  Iterable<int> get winCountsInPositions;

  int get maxStreak;

  int get currentStreak;

  int get winPercentage => numberOfGamesPlayed == 0
      ? 0
      : ((numberOfGamesWon / numberOfGamesPlayed) * 100).round();

  int get numberOfGamesWon => winCountsInPositions.fold(0, (a, b) => a + b);
}
