import 'package:gameboy/data/wordle/models/stats.dart';

abstract class StatModifier extends Stats {
  Future submitGame(int index, String word);
  Future registerWin(int index, String word);
  Future registerLoss(int index, String word);
}
