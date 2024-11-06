import 'package:gameboy/data/wordle/models/stats.dart';

abstract class StatModifier extends Stats {
  Future<bool> registerGuess(int index, String word);
  Future<bool> registerWin();
  Future<bool> registerLoss();
}
