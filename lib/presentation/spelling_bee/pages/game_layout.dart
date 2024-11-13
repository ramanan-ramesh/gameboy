import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_state.dart';
import 'package:gameboy/presentation/app/pages/game_content_page/game_layout.dart';
import 'package:gameboy/presentation/spelling_bee/bloc/events.dart';
import 'package:gameboy/presentation/spelling_bee/bloc/states.dart';
import 'package:gameboy/presentation/spelling_bee/extensions.dart';
import 'package:gameboy/presentation/spelling_bee/widgets/game_results/game_results.dart';
import 'package:gameboy/presentation/spelling_bee/widgets/letter_input_layout.dart';

class SpellingBeeLayout implements GameLayout {
  var guessWordNotifier = ValueNotifier('');

  @override
  BoxConstraints get constraints => const BoxConstraints(
      minWidth: 400.0, maxWidth: 1000.0, minHeight: 500.0, maxHeight: 1000.0);

  @override
  Widget buildActionButtonBar(BuildContext context) {
    return IconButton(onPressed: () {}, icon: Icon(Icons.query_stats_rounded));
  }

  @override
  Widget buildGameLayout(
      BuildContext context, double layoutWidth, double layoutHeight) {
    if (layoutWidth > 800) {
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
    var _gameLayoutVisibilityNotifier = ValueNotifier(true);
    return ValueListenableBuilder(
      valueListenable: _gameLayoutVisibilityNotifier,
      builder: (BuildContext context, bool value, Widget? child) {
        var gameResults = MinimizedGameResults(
          onGameResultsSizeToggled: () {
            _gameLayoutVisibilityNotifier.value =
                !_gameLayoutVisibilityNotifier.value;
          },
          isExpanded: !_gameLayoutVisibilityNotifier.value,
        );
        if (value) {
          return Column(
            children: [
              gameResults,
              Expanded(
                child: _buildGameLayout(context, layoutWidth, layoutHeight),
              ),
            ],
          );
        }

        return gameResults;
      },
    );
  }

  Widget _buildGameLayout(
      BuildContext context, double layoutWidth, double layoutHeight) {
    return FractionallySizedBox(
      heightFactor: 0.75,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildGuessWordDisplay(),
              ),
            ),
            LetterInputLayout(
              sizeOfCell: layoutWidth / 8,
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
      listener: (BuildContext context, GameState state) {
        if (state is WordGuessed) {
          guessWordNotifier.value = '';
        }
      },
      buildWhen: (previous, current) {
        return current is WordGuessed;
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
}
