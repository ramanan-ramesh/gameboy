import 'package:gameboy/data/app/models/stats.dart';

abstract class AlphaBoundStatistics extends Statistics {
  int get numberOfGamesPlayed;

  int get numberOfTimesWon => winCountsInPositions.reduce((a, b) => a + b);

  int get currentStreak;

  int get maximumStreak;

  Iterable<int> get winCountsInPositions;

  String? get finalGuessWord;

  String? get upperBound;

  String? get lowerBound;

  int get numberOfWordsGuessedToday;
}

abstract class AlphaBoundStatsModifier extends AlphaBoundStatistics {
  Future<bool> updateLowerAndUpperBound(
      String lowerBoundGuess, String upperBoundGuess);

  Future<bool> submitGuessOnEndGame(String guess, bool didWin);
}
