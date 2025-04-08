import 'package:flutter/material.dart';
import 'package:gameboy/data/alphaBound/models/constants.dart';
import 'package:gameboy/data/alphaBound/models/game_status.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/presentation/alphaBound/bloc/events.dart';
import 'package:gameboy/presentation/alphaBound/extensions.dart';
import 'package:gameboy/presentation/alphaBound/pages/stats_sheet.dart';
import 'package:gameboy/presentation/alphaBound/widgets/guesses_layout/guesses_layout.dart';
import 'package:gameboy/presentation/alphaBound/widgets/keyboard_layout.dart';
import 'package:gameboy/presentation/alphaBound/widgets/progress_tracker.dart';
import 'package:gameboy/presentation/app/pages/game_content_page/game_layout.dart';

import 'tutorial_sheet.dart';

class AlphaBoundLayout extends GameLayout {
  final _guessWordNotifier = ValueNotifier<String>('');

  @override
  Widget buildGameLayout(
      BuildContext context, double layoutWidth, double layoutHeight) {
    _initializeAttemptedGuessWord(context);
    return Column(
      children: [
        const ProgressTracker(),
        Expanded(
          flex: 7,
          child: GuessesLayout(
              layoutWidth: layoutWidth,
              guessLetterValueNotifier: _guessWordNotifier),
        ),
        Expanded(
          flex: 3,
          child: KeyboardLayout(
            onLetterPressed: _onLetterPressed,
            onBackspacePressed: _onBackspacePressed,
            onEnterPressed: () {
              _onEnterPressed(context);
            },
          ),
        ),
      ],
    );
  }

  void _initializeAttemptedGuessWord(BuildContext context) {
    var gameEngineData = context.getGameEngineData();
    var gameStatus = gameEngineData.currentState;
    if (gameStatus is GameWon) {
      _guessWordNotifier.value = gameEngineData.wordOfTheDay;
    } else if (gameStatus is GameLost) {
      _guessWordNotifier.value = gameStatus.finalGuess;
    }
  }

  @override
  BoxConstraints get constraints => const BoxConstraints(
      minWidth: 300.0, maxWidth: 500.0, minHeight: 600.0, maxHeight: 1000.0);

  @override
  Widget buildStatsSheet(BuildContext context, Game game) {
    return AlphaBoundStatsSheet(
      game: game,
    );
  }

  @override
  Widget buildTutorialSheet(BuildContext context, Game game) {
    return const AlphaBoundTutorialSheet();
  }

  void _onLetterPressed(String letter) {
    if (_guessWordNotifier.value.length < AlphaBoundConstants.guessWordLength) {
      _guessWordNotifier.value += letter;
    }
  }

  void _onBackspacePressed() {
    if (_guessWordNotifier.value.isNotEmpty) {
      _guessWordNotifier.value = _guessWordNotifier.value
          .substring(0, _guessWordNotifier.value.length - 1);
    }
  }

  void _onEnterPressed(BuildContext context) {
    if (_guessWordNotifier.value.length ==
        AlphaBoundConstants.guessWordLength) {
      context.addGameEvent(SubmitGuessWord(_guessWordNotifier.value));
    }
  }
}
