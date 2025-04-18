import 'package:equatable/equatable.dart';
import 'package:gameboy/data/wordsy/constants.dart';
import 'package:gameboy/data/wordsy/models/guess_letter.dart';

class GuessWord extends Equatable {
  final int index;
  final List<GuessLetter> guessLetters;

  const GuessWord({required this.index, required this.guessLetters});

  GuessWord.empty({required this.index})
      : guessLetters = List<GuessLetter>.generate(
            WordsyConstants.numberOfLettersInGuess,
            (index) => const GuessLetter.notYetGuessed());

  String get word {
    return guessLetters.map((e) => e.guessLetter).join();
  }

  GuessWord clone() {
    return GuessWord(
        index: index, guessLetters: List<GuessLetter>.from(guessLetters));
  }

  @override
  List<Object?> get props => [index, guessLetters];
}
