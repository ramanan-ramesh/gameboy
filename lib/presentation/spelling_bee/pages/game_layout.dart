import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/presentation/app/blocs/bloc_extensions.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_event.dart';
import 'package:gameboy/presentation/app/blocs/game_state.dart' as appGameState;
import 'package:gameboy/presentation/app/blocs/game_state.dart';
import 'package:gameboy/presentation/app/pages/game_content_page/game_layout.dart';
import 'package:gameboy/presentation/spelling_bee/bloc/events.dart';
import 'package:gameboy/presentation/spelling_bee/bloc/states.dart';
import 'package:gameboy/presentation/spelling_bee/extensions.dart';
import 'package:gameboy/presentation/spelling_bee/widgets/game_results/animated_guess_result.dart';
import 'package:gameboy/presentation/spelling_bee/widgets/game_results/game_results.dart';
import 'package:gameboy/presentation/spelling_bee/widgets/letter_input_layout.dart';
import 'package:gameboy/presentation/spelling_bee/widgets/stats_sheet.dart';

class SpellingBeeLayout implements GameLayout {
  var guessWordNotifier = ValueNotifier('');
  final _focusNode = FocusNode();
  static const _cutOffWidth = 800.0;

  @override
  BoxConstraints get constraints => const BoxConstraints(
      minWidth: 400.0, maxWidth: 1000.0, minHeight: 500.0, maxHeight: 1000.0);

  @override
  Widget buildActionButtonBar(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.addGameEvent(RequestStats());
      },
      icon: Icon(Icons.query_stats_rounded),
    );
  }

  @override
  Widget buildGameLayout(
      BuildContext context, double layoutWidth, double layoutHeight) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (keyEvent) => _handleKeyEvent(context, keyEvent),
      child: layoutWidth > _cutOffWidth
          ? _createSideBySideLayout(context, layoutWidth, layoutHeight)
          : _createSinglePageLayout(context, layoutWidth, layoutHeight),
    );
  }

  Widget _createSideBySideLayout(
      BuildContext context, double layoutWidth, double layoutHeight) {
    _focusNode.requestFocus();
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

  Widget _createSinglePageLayout(
      BuildContext context, double layoutWidth, double layoutHeight) {
    var gameLayoutVisibilityNotifier = ValueNotifier(true);
    return ValueListenableBuilder(
      valueListenable: gameLayoutVisibilityNotifier,
      builder: (BuildContext context, bool value, Widget? child) {
        var gameResults = MinimizedGameResults(
          onGameResultsSizeToggled: () {
            gameLayoutVisibilityNotifier.value =
                !gameLayoutVisibilityNotifier.value;
          },
          isExpanded: !gameLayoutVisibilityNotifier.value,
        );
        if (value) {
          _focusNode.requestFocus();
          return Column(
            children: [
              gameResults,
              Expanded(
                child: _buildGameLayout(context, layoutWidth, layoutHeight),
              ),
            ],
          );
        }
        _focusNode.unfocus();

        return gameResults;
      },
    );
  }

  Widget _buildGameLayout(
      BuildContext context, double layoutWidth, double layoutHeight) {
    return FractionallySizedBox(
      heightFactor: 0.8,
      child: SingleChildScrollView(
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
            LetterInputLayout(
              sizeOfCell: layoutWidth > _cutOffWidth
                  ? layoutWidth / 8
                  : layoutWidth / 4,
              onLetterPressed: (letter) {
                guessWordNotifier.value += letter;
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildButtonBar(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuessWordDisplay() {
    return BlocConsumer<GameBloc, appGameState.GameState>(
      builder: (BuildContext context, appGameState.GameState state) {
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
      listener: (BuildContext context, appGameState.GameState state) {
        if (state is ShowStats) {
          var spellingBeeStats = context.getStatsRepository();
          var spellingBeeGame = context.currentGameData.game;
          showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return FractionallySizedBox(
                  heightFactor: 0.75,
                  child: SpellingBeeStatsSheet(
                    spellingBeeStats: spellingBeeStats,
                    game: spellingBeeGame,
                  ),
                );
              });
        }
      },
      buildWhen: (previous, current) {
        return current is GuessedWordResult;
      },
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
          onPressed: () {},
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
}
