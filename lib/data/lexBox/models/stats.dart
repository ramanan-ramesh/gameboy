import 'package:gameboy/data/app/models/stats.dart';

abstract class LexBoxStatistics extends Statistics {
  Iterable<String> get wordsSubmittedToday;
  String get lettersOfTheDay;
  int get winCount;
  int get currentStreak;
  int get maximumStreak;
}

abstract class LexBoxStatsModifier extends LexBoxStatistics {
  /// Records a word submission (persistence only, no game logic)
  Future<bool> recordWord(String word);

  /// Records a win - updates winCount, streak, etc.
  Future<bool> registerWin();

  /// Erases the last word from persistence
  Future<bool> eraseLastWord();
}
