import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/beeWise/models/guessed_word_state.dart';
import 'package:gameboy/presentation/app/blocs/game/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game/states.dart';
import 'package:gameboy/presentation/beeWise/bloc/states.dart';
import 'package:gameboy/presentation/beeWise/extensions.dart';
import 'package:gameboy/presentation/beeWise/widgets/game_results/guess_words_display.dart';
import 'package:gameboy/presentation/beeWise/widgets/game_results/score_bar.dart';

class MaximizedGameResults extends StatelessWidget {
  MaximizedGameResults({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      builder: (BuildContext context, GameState state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ScoreBar(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _createGuessWordsDisplay(context),
              ),
            ),
          ],
        );
      },
      listener: (BuildContext context, GameState state) {},
      buildWhen: (previous, current) {
        return current is GuessedWordResult &&
            current.guessedWordState == GuessedWordState.valid;
      },
    );
  }

  Widget _createGuessWordsDisplay(BuildContext context) {
    var guessedWords = context.getGameEngineData().guessedWords;
    var numberOfFoundWordsMessage = guessedWords.isEmpty
        ? 'You have not guessed any word yet!'
        : 'You have guessed ${guessedWords.length} words!';
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              numberOfFoundWordsMessage,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: GuessWordsDisplay(guessWords: guessedWords),
          ),
        ],
      ),
    );
  }
}

class MinimizedGameResults extends StatelessWidget {
  final VoidCallback onGameResultsSizeToggled;
  final bool isExpandedInitially;

  MinimizedGameResults(
      {super.key,
      required this.onGameResultsSizeToggled,
      required this.isExpandedInitially});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      builder: (BuildContext context, GameState state) {
        if (!isExpandedInitially) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ScoreBar(),
              ),
              _createGuessWordsDisplay(context),
            ],
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ScoreBar(),
            ),
            Expanded(
              child: _createGuessWordsDisplay(context),
            ),
          ],
        );
      },
      listener: (BuildContext context, GameState state) {},
      buildWhen: (previous, current) {
        return current is GuessedWordResult &&
            current.guessedWordState == GuessedWordState.valid;
      },
    );
  }

  Widget _createGuessWordsDisplay(BuildContext context) {
    var guessedWords = context.getGameEngineData().guessedWords;
    if (!isExpandedInitially) {
      var textToDisplay = guessedWords.isEmpty
          ? 'You have not guessed any word yet!'
          : guessedWords.join(' ').toUpperCase();
      return Container(
        height: 100,
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(textToDisplay,
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis),
            ),
            _buildExpander(Icons.arrow_circle_down_rounded),
          ],
        ),
      );
    } else {
      var numberOfFoundWordsMessage = guessedWords.isEmpty
          ? 'You have not guessed any word yet!'
          : 'You have guessed ${guessedWords.length} words!';
      return Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  numberOfFoundWordsMessage,
                  style: TextStyle(fontSize: 16),
                ),
                _buildExpander(Icons.arrow_circle_up_rounded),
              ],
            ),
            Expanded(
              child: GuessWordsDisplay(guessWords: guessedWords),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildExpander(IconData icon) {
    return IconButton(
      onPressed: () {
        onGameResultsSizeToggled();
      },
      icon: Icon(icon),
    );
  }
}
