import 'package:gameboy/data/wordle/models/stats.dart';

abstract class WordleStatsModifier extends WordleStatistics {
  Future<bool> registerGuess(int index, String guess);

  Future<bool> registerWin();

  Future<bool> registerLoss();
}
