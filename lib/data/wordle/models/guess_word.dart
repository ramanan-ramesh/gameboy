import 'package:equatable/equatable.dart';
import 'package:gameboy/data/wordle/models/guess_letter.dart';

class GuessWord extends Equatable {
  int index;
  List<GuessLetter> guessLetters;

  GuessWord({required this.index, required this.guessLetters});

  GuessWord.empty({required this.index})
      : guessLetters = List<GuessLetter>.generate(
            5, (index) => GuessLetter.notYetGuessed());

  String get word {
    return guessLetters.map((e) => e.guessLetter).join();
  }

  @override
  List<Object?> get props => [index, guessLetters];
}
