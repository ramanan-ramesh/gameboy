import 'package:gameboy/data/wordsy/models/stats.dart';

abstract class WordsyStatsModifier extends WordsyStatistics {
  Future<bool> registerGuess(int index, String guess);

  Future<bool> registerWin();

  Future<bool> registerLoss();
}
