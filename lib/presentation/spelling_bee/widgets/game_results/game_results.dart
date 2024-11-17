import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_state.dart';
import 'package:gameboy/presentation/spelling_bee/bloc/states.dart';
import 'package:gameboy/presentation/spelling_bee/extensions.dart';
import 'package:gameboy/presentation/spelling_bee/widgets/game_results/guess_words_display.dart';
import 'package:gameboy/presentation/spelling_bee/widgets/game_results/score_bar.dart';

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
        return current is WordGuessed;
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

class MinimizedGameResults extends StatefulWidget {
  final VoidCallback onGameResultsSizeToggled;
  bool isExpanded;
  MinimizedGameResults(
      {super.key,
      required this.onGameResultsSizeToggled,
      this.isExpanded = false});

  @override
  State<MinimizedGameResults> createState() => _MinimizedGameResultsState();
}

class _MinimizedGameResultsState extends State<MinimizedGameResults> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      builder: (BuildContext context, GameState state) {
        if (!widget.isExpanded) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ScoreBar(),
              ),
              _createGuessWordsDisplay(),
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
              child: _createGuessWordsDisplay(),
            ),
          ],
        );
      },
      listener: (BuildContext context, GameState state) {},
      buildWhen: (previous, current) {
        return current is WordGuessed;
      },
    );
  }

  Widget _createGuessWordsDisplay() {
    var guessedWords = context.getGameEngineData().guessedWords;
    if (!widget.isExpanded) {
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
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                clipBehavior: Clip.hardEdge,
                children: guessedWords
                    .map((word) => Text(word, style: TextStyle(fontSize: 16)))
                    .toList(),
              ),
            ),
            _buildExpander(Icons.arrow_circle_down_rounded),
          ],
        ),
      );
    } else {
      var numberOfFoundWordsMessage = guessedWords.isEmpty
          ? 'You have not guessed any word yet!'
          : 'You have guessed ${guessedWords.length} words!';
      // convert each word's first letter to capital and the rest to lower case
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
        setState(() {
          widget.isExpanded != widget.isExpanded;
          widget.onGameResultsSizeToggled();
        });
      },
      icon: Icon(icon),
    );
  }
}
