import 'package:equatable/equatable.dart';
import 'package:gameboy/data/wordle/models/letter_match_description.dart';

class GuessLetter extends Equatable {
  final String guessLetter;
  final LetterMatchDescription letterMatchDescription;

  const GuessLetter(
      {required this.guessLetter, required this.letterMatchDescription});

  const GuessLetter.notYetGuessed()
      : guessLetter = '',
        letterMatchDescription = LetterMatchDescription.notYetMatched;

  @override
  List<Object?> get props => [guessLetter, letterMatchDescription];
}
