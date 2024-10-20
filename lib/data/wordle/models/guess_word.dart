import 'package:gameboy/data/wordle/models/guess_letter.dart';

class GuessWord {
  int index;
  List<GuessLetter?> guessLetters;

  GuessWord({required this.index, required this.guessLetters});

  String get word {
    return guessLetters.map((e) => e?.guessLetter ?? '').join();
  }
}
