import 'package:gameboy/data/app/models/stats.dart';
import 'package:gameboy/data/wordle/implementation/stats_repository.dart';
import 'package:gameboy/data/wordle/models/stat_modifier.dart';

abstract class Stats extends Statistics {
  String get wordOfTheDay;
  int get numberOfGamesPlayed;
  Iterable<String> get lastGuessedWords;
  Iterable<int> get wonPositions;
  int get maxStreak;
  int get currentStreak;
  DateTime? currentGuessEditingDay;
  DateTime get initializedDateTime;
  int get winPercentage => numberOfGamesPlayed == 0
      ? 0
      : (wonPositions.reduce((a, b) => a + b) / numberOfGamesPlayed * 100)
          .round();
  int get numberOfGamesWon => wonPositions.fold(0, (a, b) => a + b);

  static Future<StatModifier> createInstance(String userId) async {
    return await StatsRepository.createInstance(userId);
  }
}
