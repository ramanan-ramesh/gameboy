import 'package:flutter/material.dart';
import 'package:gameboy/data/wordsy/constants.dart';
import 'package:gameboy/data/wordsy/models/guess_letter.dart';
import 'package:gameboy/data/wordsy/models/guess_word.dart';
import 'package:gameboy/data/wordsy/models/letter_match_description.dart';
import 'package:gameboy/presentation/wordsy/widgets/extensions.dart';

class WordsyTutorialSheet extends StatelessWidget {
  static const _gameObjective =
      'Guess a word in ${WordsyConstants.numberOfGuesses} tries.';
  static const _guessLengthInstruction =
      'Each guess must be a valid ${WordsyConstants.numberOfLettersInGuess}-letter word.';
  static const _guessLetterColorInstruction =
      'The color of the tiles will change to show how close your guess was.';
  static const _newPuzzleReleaseText =
      'A new puzzle is released daily at midnight';
  const WordsyTutorialSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              _gameObjective,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: _createInstructions(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: _createExamples(context),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                _newPuzzleReleaseText,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: _createInstruction(_guessLengthInstruction),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: _createInstruction(_guessLetterColorInstruction),
        ),
      ],
    );
  }

  Widget _createExamples(BuildContext context) {
    var correctGuessWord = const GuessWord(
      index: 0,
      guessLetters: [
        GuessLetter(
            guessLetter: 'W',
            letterMatchDescription: LetterMatchDescription.rightPositionInWord),
        GuessLetter(
            guessLetter: 'O',
            letterMatchDescription: LetterMatchDescription.notInWord),
        GuessLetter(
            guessLetter: 'R',
            letterMatchDescription: LetterMatchDescription.notInWord),
        GuessLetter(
            guessLetter: 'D',
            letterMatchDescription: LetterMatchDescription.notInWord),
        GuessLetter(
            guessLetter: 'Y',
            letterMatchDescription: LetterMatchDescription.notInWord),
      ],
    );
    var incorrectlyPositionedGuessWord = const GuessWord(
      index: 0,
      guessLetters: [
        GuessLetter(
            guessLetter: 'F',
            letterMatchDescription: LetterMatchDescription.notInWord),
        GuessLetter(
            guessLetter: 'I',
            letterMatchDescription: LetterMatchDescription.wrongPositionInWord),
        GuessLetter(
            guessLetter: 'G',
            letterMatchDescription: LetterMatchDescription.notInWord),
        GuessLetter(
            guessLetter: 'H',
            letterMatchDescription: LetterMatchDescription.notInWord),
        GuessLetter(
            guessLetter: 'T',
            letterMatchDescription: LetterMatchDescription.notInWord),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            'Examples',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: _createGuessWord(
            correctGuessWord,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: _createGuessWord(
            incorrectlyPositionedGuessWord,
          ),
        ),
      ],
    );
  }

  Widget _createGuessWord(GuessWord guessWord) {
    var guessLettersInCorrectPosition = guessWord.guessLetters
        .where((guessLetter) =>
            guessLetter.letterMatchDescription ==
            LetterMatchDescription.rightPositionInWord)
        .map((guessLetter) => guessLetter.guessLetter);
    var guessLettersInWrongPosition = guessWord.guessLetters
        .where((guessLetter) =>
            guessLetter.letterMatchDescription ==
            LetterMatchDescription.wrongPositionInWord)
        .map((guessLetter) => guessLetter.guessLetter);
    var guessLettersNotInWord = guessWord.guessLetters
        .where((guessLetter) =>
            guessLetter.letterMatchDescription ==
            LetterMatchDescription.notInWord)
        .map((guessLetter) => guessLetter.guessLetter);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ...(guessWord.guessLetters.map((guessLetter) {
              return _createLetterBox(guessLetter);
            })),
          ],
        ),
        if (guessLettersInCorrectPosition.isNotEmpty)
          guessLettersInCorrectPosition.length > 1
              ? Text(
                  'The letters ${guessLettersInCorrectPosition.join(', ')} are in the correct position.',
                  style: const TextStyle(fontSize: 16),
                )
              : Text(
                  'The letter ${guessLettersInCorrectPosition.join(', ')} is in the correct position.',
                  style: const TextStyle(fontSize: 16),
                ),
        if (guessLettersInWrongPosition.isNotEmpty)
          guessLettersInWrongPosition.length > 1
              ? Text(
                  'The letters ${guessLettersInWrongPosition.join(', ')} are in the word but in the wrong position.',
                  style: const TextStyle(fontSize: 16),
                )
              : Text(
                  'The letter ${guessLettersInWrongPosition.join(', ')} is in the word but in the wrong position.',
                  style: const TextStyle(fontSize: 16),
                ),
        if (guessLettersNotInWord.isNotEmpty)
          guessLettersNotInWord.length > 1
              ? Text(
                  'The letters ${guessLettersNotInWord.join(', ')} are not in the word.',
                  style: const TextStyle(fontSize: 16),
                )
              : Text(
                  'The letter ${guessLettersNotInWord.join(', ')} is not in the word.',
                  style: const TextStyle(fontSize: 16),
                ),
      ],
    );
  }

  Widget _createLetterBox(GuessLetter guessLetter) {
    return Container(
      width: 40,
      height: 50,
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: guessLetter.getGuessTileBackgroundColor(),
      ),
      child: Center(
        child: Text(
          guessLetter.guessLetter.toUpperCase(),
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: guessLetter.getTextColor()),
        ),
      ),
    );
  }

  Widget _createInstruction(String instruction) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            instruction,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
