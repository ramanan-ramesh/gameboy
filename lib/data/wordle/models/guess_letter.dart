import 'package:gameboy/data/wordle/models/letter_match_description.dart';

class GuessLetter {
  String guessLetter;
  LetterMatchDescription? letterMatchDescription;

  GuessLetter(
      {required this.guessLetter, required this.letterMatchDescription});
}
