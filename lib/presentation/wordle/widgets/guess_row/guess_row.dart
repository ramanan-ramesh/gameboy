import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/wordle/constants.dart';
import 'package:gameboy/data/wordle/models/guess_letter.dart';
import 'package:gameboy/data/wordle/models/guess_word.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_state.dart';
import 'package:gameboy/presentation/wordle/bloc/states.dart';
import 'package:gameboy/presentation/wordle/extensions.dart';
import 'package:gameboy/presentation/wordle/widgets/extensions.dart';
import 'package:gameboy/presentation/wordle/widgets/guess_row/dancing_guess_letter.dart';
import 'package:gameboy/presentation/wordle/widgets/guess_row/flipped_guess_letter.dart';
import 'package:gameboy/presentation/wordle/widgets/guess_row/shake_guess_letter.dart';

class GuessRow extends StatelessWidget {
  final int guessIndex;

  const GuessRow({super.key, required this.guessIndex});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      builder: (BuildContext context, GameState state) {
        var gameEngineData = context.getGameEngineData();
        GuessWord guessWord =
            gameEngineData.guessWordUnderEdit?.index == guessIndex
                ? gameEngineData.guessWordUnderEdit!
                : gameEngineData.getAttemptedGuessWord(guessIndex);
        if (state is GuessWordSubmitted && state.guessIndex == guessIndex) {
          return _FlippedGuessWords(
            guessWord: guessWord,
          );
        } else if ((state is SubmissionNotInDictionary) &&
            gameEngineData.guessWordUnderEdit!.index == guessIndex) {
          return _ShakingGuessWord(
            guessWord: guessWord,
          );
        } else if (state is GameWon && state.guessedIndex == guessIndex) {
          if (state.isStartup) {
            return _DancingGuessWord(
              guessWord: guessWord,
            );
          }
          return _FlippedGuessWordsWithDance(
            guessWord: guessWord,
          );
        } else if (state is GameLost &&
            guessIndex == WordleConstants.numberOfGuesses - 1) {
          if (state.isStartup) {
            return _ShakingGuessWord(
              guessWord: guessWord,
            );
          }
          return _FlippedGuessWordsWithDance(
            guessWord: guessWord,
          );
        }
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
          return WordleConstants.numberOfGuesses - 1 == guessIndex;
        }
        return false;
      },
      listener: (BuildContext context, GameState state) {},
    );
  }

  Widget _buildGuessLetter(
    BuildContext context,
    GuessLetter guessLetter,
  ) {
    var letterValue = guessLetter.guessLetter.isEmpty
        ? ' '
        : guessLetter.guessLetter.toUpperCase();
    return Container(
      color: guessLetter.getGuessTileBackgroundColor(),
      margin: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          letterValue,
          style: TextStyle(color: guessLetter.getTextColor()),
        ),
      ),
    );
  }
}

class _FlippedGuessWords extends StatefulWidget {
  final GuessWord guessWord;

  const _FlippedGuessWords({super.key, required this.guessWord});

  @override
  State<_FlippedGuessWords> createState() => _FlippedGuessWordsState();
}

class _FlippedGuessWordsState extends State<_FlippedGuessWords> {
  @override
  Widget build(BuildContext context) {
    List<Widget> guessLetterWidgets = [];
    for (var indexOfGuessLetter = 0;
        indexOfGuessLetter < widget.guessWord.guessLetters.length;
        indexOfGuessLetter++) {
      var guessLetter = widget.guessWord.guessLetters[indexOfGuessLetter];
      var guessLetterWidget = FlippedGuessLetter(
        guessLetter: guessLetter,
        indexOfGuessLetter: indexOfGuessLetter,
      );
      guessLetterWidgets.add(guessLetterWidget);
    }

    return Row(
      children: guessLetterWidgets
          .map(
            (guessLetterWidget) => Expanded(
              child: guessLetterWidget,
            ),
          )
          .toList(),
    );
  }
}

class _DancingGuessWord extends StatefulWidget {
  final GuessWord guessWord;

  const _DancingGuessWord({super.key, required this.guessWord});

  @override
  State<_DancingGuessWord> createState() => _DancingGuessWordState();
}

class _DancingGuessWordState extends State<_DancingGuessWord> {
  @override
  Widget build(BuildContext context) {
    List<Widget> guessLetterWidgets = [];
    for (var indexOfGuessLetter = 0;
        indexOfGuessLetter < widget.guessWord.guessLetters.length;
        indexOfGuessLetter++) {
      var guessLetter = widget.guessWord.guessLetters[indexOfGuessLetter];
      var guessLetterWidget = DancingGuessLetter(
        guessLetter: guessLetter,
        indexOfGuessLetter: indexOfGuessLetter,
      );
      guessLetterWidgets.add(guessLetterWidget);
    }

    return Row(
      children: guessLetterWidgets
          .map(
            (guessLetterWidget) => Expanded(
              child: guessLetterWidget,
            ),
          )
          .toList(),
    );
  }
}

class _ShakingGuessWord extends StatefulWidget {
  final GuessWord guessWord;

  const _ShakingGuessWord({super.key, required this.guessWord});

  @override
  State<_ShakingGuessWord> createState() => _ShakingGuessWordState();
}

class _ShakingGuessWordState extends State<_ShakingGuessWord> {
  @override
  Widget build(BuildContext context) {
    List<Widget> guessLetterWidgets = [];
    for (var indexOfGuessLetter = 0;
        indexOfGuessLetter < widget.guessWord.guessLetters.length;
        indexOfGuessLetter++) {
      var guessLetter = widget.guessWord.guessLetters[indexOfGuessLetter];
      var guessLetterWidget = ShakingGuessLetter(
        guessLetter: guessLetter,
        indexOfGuessLetter: indexOfGuessLetter,
      );
      guessLetterWidgets.add(guessLetterWidget);
    }

    return Row(
      children: guessLetterWidgets
          .map(
            (guessLetterWidget) => Expanded(
              child: guessLetterWidget,
            ),
          )
          .toList(),
    );
  }
}

class _FlippedGuessWordsWithDance extends StatefulWidget {
  final GuessWord guessWord;

  const _FlippedGuessWordsWithDance({super.key, required this.guessWord});

  @override
  State<_FlippedGuessWordsWithDance> createState() =>
      _FlippedGuessWordsWithDanceState();
}

class _FlippedGuessWordsWithDanceState
    extends State<_FlippedGuessWordsWithDance> {
  bool _shouldAnimateWin = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> guessLetterWidgets = [];
    for (var indexOfGuessLetter = 0;
        indexOfGuessLetter < widget.guessWord.guessLetters.length;
        indexOfGuessLetter++) {
      var guessLetter = widget.guessWord.guessLetters[indexOfGuessLetter];
      var guessLetterWidget = !_shouldAnimateWin
          ? FlippedGuessLetter(
              guessLetter: guessLetter, indexOfGuessLetter: indexOfGuessLetter)
          : DancingGuessLetter(
              guessLetter: guessLetter,
              indexOfGuessLetter: indexOfGuessLetter,
            );
      guessLetterWidgets.add(guessLetterWidget);
    }

    Future.delayed(Duration(seconds: 6, milliseconds: 250), () {
      if (mounted && !_shouldAnimateWin) {
        setState(() {
          _shouldAnimateWin = true;
        });
      }
    });
    return Row(
      children: guessLetterWidgets
          .map(
            (guessLetterWidget) => Expanded(
              child: guessLetterWidget,
            ),
          )
          .toList(),
    );
  }
}

class _FlippedGuessWordsWithShake extends StatefulWidget {
  final GuessWord guessWord;

  const _FlippedGuessWordsWithShake({super.key, required this.guessWord});

  @override
  State<_FlippedGuessWordsWithShake> createState() =>
      _FlippedGuessWordsWithShakeState();
}

class _FlippedGuessWordsWithShakeState
    extends State<_FlippedGuessWordsWithShake> {
  bool _shouldAnimateWin = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> guessLetterWidgets = [];
    for (var indexOfGuessLetter = 0;
        indexOfGuessLetter < widget.guessWord.guessLetters.length;
        indexOfGuessLetter++) {
      var guessLetter = widget.guessWord.guessLetters[indexOfGuessLetter];
      var guessLetterWidget = !_shouldAnimateWin
          ? FlippedGuessLetter(
              guessLetter: guessLetter, indexOfGuessLetter: indexOfGuessLetter)
          : ShakingGuessLetter(
              guessLetter: guessLetter,
              indexOfGuessLetter: indexOfGuessLetter,
            );
      guessLetterWidgets.add(guessLetterWidget);
    }

    Future.delayed(Duration(seconds: 6, milliseconds: 250), () {
      if (mounted && !_shouldAnimateWin) {
        setState(() {
          _shouldAnimateWin = true;
        });
      }
    });
    return Row(
      children: guessLetterWidgets
          .map(
            (guessLetterWidget) => Expanded(
              child: guessLetterWidget,
            ),
          )
          .toList(),
    );
  }
}
