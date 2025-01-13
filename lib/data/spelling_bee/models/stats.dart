import 'package:gameboy/data/app/models/stats.dart';

abstract class Stats extends Statistics {
  Iterable<String> get wordsSubmittedToday;

  String get lettersOfTheDay;

  Iterable<MapEntry<String, int>> get rankingsCount;

  int get numberOfGamesPlayed;

  int get numberOfWordsSubmitted;

  int get numberOfPangrams;

  String? get longestSubmittedWord;
}

abstract class SpellingBeeStatsModifier extends Stats {
  Future<bool> trySubmitWord(String word);
}
