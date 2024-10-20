import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/wordle/models/guess_letter.dart';
import 'package:gameboy/data/wordle/models/guess_word.dart';
import 'package:gameboy/data/wordle/models/letter_match_description.dart';
import 'package:gameboy/presentation/wordle/bloc/bloc.dart';
import 'package:gameboy/presentation/wordle/bloc/extensions.dart';
import 'package:gameboy/presentation/wordle/bloc/states.dart';

class GuessRow extends StatelessWidget {
  final int guessIndex;
  const GuessRow({super.key, required this.guessIndex});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WordleGameEngine, WordleState>(
      builder: (BuildContext context, WordleState state) {
        var gameEngineData = context.getGameEngineData();
        GuessWord guessWord =
            gameEngineData.guessWordUnderEdit?.index == guessIndex
                ? gameEngineData.guessWordUnderEdit!
                : gameEngineData.getAttemptedGuessWord(guessIndex);
        return Row(
          children: guessWord.guessLetters
              .map(
                (guessLetter) => Expanded(
                  child: _buildGuessLetter(context, guessLetter),
                ),
              )
              .toList(),
        );
      },
      buildWhen: (previousState, currentState) {
        var gameEngineData = context.getGameEngineData();
        if (currentState is GuessEdited) {
          return gameEngineData.guessWordUnderEdit?.index == guessIndex;
        } else if (currentState is SubmissionNotInDictionary) {
          return gameEngineData.guessWordUnderEdit?.index == guessIndex;
        } else if (currentState is GuessWordSubmitted) {
          return currentState.guessIndex == guessIndex;
        } else if (currentState is GameWon) {
          return currentState.guessedIndex == guessIndex;
        } else if (currentState is GameLost) {
          return currentState.guessedIndex == guessIndex;
        }
        return false;
      },
      listener: (BuildContext context, WordleState state) {},
    );
  }

  Widget _buildGuessLetter(
    BuildContext context,
    GuessLetter? guessLetter,
  ) {
    Color backgroundColor;
    if (guessLetter == null) {
      backgroundColor = Colors.white12;
    } else {
      switch (guessLetter.letterMatchDescription) {
        case LetterMatchDescription.notInWord:
          {
            backgroundColor = Colors.black12;
            break;
          }
        case LetterMatchDescription.inWordRightPosition:
          {
            backgroundColor = Colors.green;
            break;
          }
        case LetterMatchDescription.inWordWrongPosition:
          {
            backgroundColor = Colors.yellow;
            break;
          }
        default:
          backgroundColor = Colors.white12;
      }
    }
    return Container(
      color: backgroundColor,
      margin: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          guessLetter?.guessLetter ?? ' ',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
