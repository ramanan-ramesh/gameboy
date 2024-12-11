import 'package:gameboy/data/alphaBound/implementation/stats.dart';
import 'package:gameboy/data/app/models/stats.dart';

abstract class AlphaBoundStats extends Statistics {
  int get numberOfGamesPlayed;
  int get numberOfTimesWon;
  int get currentStreak;
  int get maximumStreak;
  int get numberOfWordsGuessed;
  String? get middleGuessedWord;
  String? get todaysUpperBoundGuess;
  String? get todaysLowerBoundGuess;
}

abstract class AlphaBoundStatsModifier extends AlphaBoundStats {
  Future<bool> tryUpdateLowerAndUpperBoundGuess(
      String lowerBoundGuess, String upperBoundGuess);
  Future<bool> trySubmitGuessWordOnEndGame(String guess, bool didWin);

  static Future<AlphaBoundStatsModifier> createInstance(String userId) async {
    return await AlphaBoundStatistics.create(userId);
  }
}
