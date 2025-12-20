import 'package:gameboy/data/app/models/stats.dart';

abstract class LexBoxStatistics extends Statistics {
  Iterable<String> get wordsSubmittedToday;
  String get lettersOfTheDay;
  int get winCount;
}

abstract class LexBoxStatsModifier extends LexBoxStatistics {
  Future<bool> trySubmitWord(String word);
  Future<bool> eraseLastWord();
}
