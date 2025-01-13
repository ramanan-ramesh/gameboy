import 'package:flutter/material.dart';
import 'package:gameboy/data/alphaBound/models/constants.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/presentation/alphaBound/bloc/events.dart';
import 'package:gameboy/presentation/alphaBound/extensions.dart';
import 'package:gameboy/presentation/alphaBound/pages/stats_sheet.dart';
import 'package:gameboy/presentation/alphaBound/widgets/guesses_layout/guesses_layout.dart';
import 'package:gameboy/presentation/alphaBound/widgets/keyboard_layout.dart';
import 'package:gameboy/presentation/alphaBound/widgets/progress_tracker.dart';
import 'package:gameboy/presentation/app/pages/game_content_page/game_layout.dart';

class AlphaBoundLayout extends GameLayout {
  final _guessLetterValueNotifier = ValueNotifier<String>('');

  @override
  Widget buildGameLayout(
      BuildContext context, double layoutWidth, double layoutHeight) {
    return Column(
      children: [
        ProgressTracker(),
        Expanded(
          flex: 7,
          child: Center(
            child: GuessesLayout(
                layoutWidth: layoutWidth,
                guessLetterValueNotifier: _guessLetterValueNotifier),
          ),
          // child: _createGuessesLayout(layoutWidth),
        ),
        Expanded(
          flex: 3,
          child: KeyboardLayout(
              onLetterPressed: _onLetterPressed,
              onBackspacePressed: _onBackspacePressed,
              onEnterPressed: () {
                _onEnterPressed(context);
              }),
        ),
      ],
    );
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

  void _onLetterPressed(String letter) {
    if (_guessLetterValueNotifier.value.length <
        AlphaBoundConstants.numberOfLettersInGuess) {
      _guessLetterValueNotifier.value += letter;
    }
  }

  void _onBackspacePressed() {
    if (_guessLetterValueNotifier.value.isNotEmpty) {
      _guessLetterValueNotifier.value = _guessLetterValueNotifier.value
          .substring(0, _guessLetterValueNotifier.value.length - 1);
    }
  }

  void _onEnterPressed(BuildContext context) {
    if (_guessLetterValueNotifier.value.length ==
        AlphaBoundConstants.numberOfLettersInGuess) {
      context.addGameEvent(SubmitGuessWord(_guessLetterValueNotifier.value));
    }
  }

  Widget _createGuessesLayout(double layoutWidth) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: GuessesLayout(
              layoutWidth: layoutWidth,
              guessLetterValueNotifier: _guessLetterValueNotifier),
        ),
        Expanded(
          flex: 1,
          child: Container(),
        ),
      ],
    );
  }
}
