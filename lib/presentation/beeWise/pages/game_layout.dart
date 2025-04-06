import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/presentation/app/blocs/game/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game/states.dart';
import 'package:gameboy/presentation/app/pages/game_content_page/game_layout.dart';
import 'package:gameboy/presentation/beeWise/bloc/events.dart';
import 'package:gameboy/presentation/beeWise/bloc/states.dart';
import 'package:gameboy/presentation/beeWise/extensions.dart';
import 'package:gameboy/presentation/beeWise/pages/stats_sheet.dart';
import 'package:gameboy/presentation/beeWise/widgets/game_results/animated_guess_result.dart';
import 'package:gameboy/presentation/beeWise/widgets/game_results/game_results.dart';
import 'package:gameboy/presentation/beeWise/widgets/letter_input_layout.dart';

class BeeWiseLayout implements GameLayout {
  var guessWordNotifier = ValueNotifier('');
  final _keyBoardFocusNode = FocusNode();
  static const _cutOffWidth = 800.0;
  final _lettersOTheDayNotifier = ValueNotifier('');

  @override
  BoxConstraints get constraints => const BoxConstraints(
      minWidth: 400.0, maxWidth: 1000.0, minHeight: 500.0, maxHeight: 1000.0);

  @override
  Widget buildGameLayout(
      BuildContext context, double layoutWidth, double layoutHeight) {
    _lettersOTheDayNotifier.value = context.getGameEngineData().lettersOfTheDay;
    return KeyboardListener(
      focusNode: _keyBoardFocusNode,
      autofocus: true,
      onKeyEvent: (keyEvent) => _handleKeyEvent(context, keyEvent),
      child: layoutWidth > _cutOffWidth
          ? _createSideBySideLayout(context, layoutWidth, layoutHeight)
          : _createSinglePageLayout(layoutWidth, layoutHeight),
    );
  }

  @override
  Widget buildStatsSheet(BuildContext context, Game game) {
    return BeeWiseStatsSheet(
      game: game,
    );
  }

  void _handleKeyEvent(BuildContext context, KeyEvent keyEvent) {
    if (keyEvent is! KeyUpEvent) {
      return;
    }
    if (keyEvent.logicalKey.keyLabel.isNotEmpty &&
        keyEvent.logicalKey.keyLabel.length == 1 &&
        keyEvent.logicalKey.keyLabel.toUpperCase().contains(RegExp(r'[A-Z]'))) {
      guessWordNotifier.value += keyEvent.logicalKey.keyLabel;
    } else if (keyEvent.logicalKey == LogicalKeyboardKey.backspace) {
      if (guessWordNotifier.value.isNotEmpty) {
        guessWordNotifier.value = guessWordNotifier.value
            .substring(0, guessWordNotifier.value.length - 1);
      }
    } else if (keyEvent.logicalKey == LogicalKeyboardKey.enter) {
      context.addGameEvent(SubmitWord(guessWordNotifier.value));
    }
  }

  Widget _createSideBySideLayout(
      BuildContext context, double layoutWidth, double layoutHeight) {
    _keyBoardFocusNode.requestFocus();
    return Row(
      children: [
        Expanded(
          child: _buildGameLayout(context, layoutWidth, layoutHeight),
        ),
        Expanded(
          child: MaximizedGameResults(),
        )
      ],
    );
  }

  Widget _createSinglePageLayout(double layoutWidth, double layoutHeight) {
    var gameLayoutVisibilityNotifier = ValueNotifier(true);
    return ValueListenableBuilder(
      valueListenable: gameLayoutVisibilityNotifier,
      builder: (BuildContext context, bool isGameLayoutVisible, Widget? child) {
        var gameResults = MinimizedGameResults(
          onGameResultsSizeToggled: () {
            var guessedWords = context.getGameEngineData().guessedWords;
            if (guessedWords.length > 1) {
              gameLayoutVisibilityNotifier.value =
                  !gameLayoutVisibilityNotifier.value;
            }
          },
          isExpandedInitially: !gameLayoutVisibilityNotifier.value,
        );
        if (isGameLayoutVisible) {
          _keyBoardFocusNode.requestFocus();
          return Column(
            children: [
              MinimizedGameResults(
                onGameResultsSizeToggled: () {
                  var guessedWords = context.getGameEngineData().guessedWords;
                  if (guessedWords.length > 1) {
                    gameLayoutVisibilityNotifier.value =
                        !gameLayoutVisibilityNotifier.value;
                  }
                },
                isExpandedInitially: !gameLayoutVisibilityNotifier.value,
              ),
              Expanded(
                child: _buildGameLayout(context, layoutWidth, layoutHeight),
              ),
            ],
          );
        }
        _keyBoardFocusNode.unfocus();

        return gameResults;
      },
    );
  }

  Widget _buildGameLayout(
      BuildContext context, double layoutWidth, double layoutHeight) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AnimatedGuessedWordResult(
            onAnimationComplete: () {
              guessWordNotifier.value = '';
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildGuessWordDisplay(),
            ),
          ),
          ValueListenableBuilder<String>(
            valueListenable: _lettersOTheDayNotifier,
            builder: (context, lettersOfTheDay, child) {
              return LetterInputLayout(
                sizeOfCell: layoutWidth > _cutOffWidth
                    ? layoutWidth / 8
                    : layoutWidth / 4,
                onLetterPressed: (letter) {
                  guessWordNotifier.value += letter;
                },
                lettersOfTheDay: lettersOfTheDay,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildButtonBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGuessWordDisplay() {
    return BlocConsumer<GameBloc, GameState>(
      builder: (BuildContext context, GameState state) {
        return ValueListenableBuilder(
          valueListenable: guessWordNotifier,
          builder: (context, value, child) {
            return Text(
              value.isEmpty ? '' : value.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge,
            );
          },
        );
      },
      buildWhen: (previous, current) {
        return current is GuessedWordResult;
      },
      listener: (BuildContext context, GameState state) {},
    );
  }

  Row _buildButtonBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton(
          heroTag: null,
          onPressed: () {
            var currentGuessWord = guessWordNotifier.value;
            if (currentGuessWord.isNotEmpty) {
              guessWordNotifier.value =
                  currentGuessWord.substring(0, currentGuessWord.length - 1);
            }
          },
          child: Icon(Icons.cancel_rounded),
        ),
        FloatingActionButton(
          heroTag: null,
          onPressed: () {
            var allLettersOfTheDay = _lettersOTheDayNotifier.value;
            var allLettersExceptTheFirstLetter =
                allLettersOfTheDay.substring(1);
            var shuffledLetters =
                (allLettersExceptTheFirstLetter.split('')..shuffle()).join();
            _lettersOTheDayNotifier.value =
                allLettersOfTheDay[0] + shuffledLetters;
          },
          child: Icon(Icons.sync_rounded),
        ),
        FloatingActionButton(
          heroTag: null,
          onPressed: () {
            context.addGameEvent(SubmitWord(guessWordNotifier.value));
          },
          child: Icon(Icons.keyboard_return_rounded),
        ),
      ],
    );
  }
}
