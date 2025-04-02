import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/alphaBound/models/constants.dart';
import 'package:gameboy/data/alphaBound/models/game_status.dart';
import 'package:gameboy/presentation/alphaBound/bloc/states.dart';
import 'package:gameboy/presentation/alphaBound/extensions.dart';
import 'package:gameboy/presentation/app/blocs/game/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game/states.dart';

class ProgressTracker extends StatelessWidget {
  const ProgressTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      builder: (BuildContext context, GameState state) {
        var statistics = context.getStatsRepository();
        var gameState = context.getCurrentAlphaBoundGameStatus();
        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _createAttemptedGuessesCountText(
                  statistics.numberOfWordsGuessedToday, context),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _createAttemptedGuessesCountTracker(
                    statistics.numberOfWordsGuessedToday, gameState),
              ),
            ),
          ],
        );
      },
      buildWhen: (previousState, currentState) {
        return currentState is AlphaBoundGameState &&
            currentState.hasGameMovedAhead();
      },
      listener: (BuildContext context, GameState state) {},
    );
  }

  Widget _createAttemptedGuessesCountText(
      int numberOfGuesses, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'GUESS',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        FittedBox(
          fit: BoxFit.contain,
          child: Text(
            '$numberOfGuesses / ${AlphaBoundConstants.maximumGuessesAllowed}',
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
      ],
    );
  }

  Widget _createAttemptedGuessesCountTracker(
      int numberOfGuessesAttempted, AlphaBoundGameStatus gameState) {
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      children: List.generate(
        AlphaBoundConstants.maximumGuessesAllowed,
        (index) {
          Color backgroundColor;
          if (index < numberOfGuessesAttempted) {
            backgroundColor = (gameState is GameWon &&
                    index == (numberOfGuessesAttempted - 1))
                ? Colors.green
                : Colors.red;
          } else {
            backgroundColor = (index == numberOfGuessesAttempted &&
                    !(gameState is GameWon || gameState is GameLost))
                ? Colors.green
                : Colors.grey;
          }
          return Container(
            margin: const EdgeInsets.all(4.0),
            width: 20.0,
            height: 20.0,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }
}
