import 'package:gameboy/data/wordle/models/stats.dart';

abstract class WordleStatModifier extends WordleStats {
  Future<bool> registerGuess(int index, String word);
  Future<bool> registerWin();
  Future<bool> registerLoss();
}
