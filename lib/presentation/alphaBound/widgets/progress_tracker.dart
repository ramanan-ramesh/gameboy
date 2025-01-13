import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/alphaBound/models/constants.dart';
import 'package:gameboy/data/alphaBound/models/game_status.dart';
import 'package:gameboy/presentation/alphaBound/bloc/states.dart';
import 'package:gameboy/presentation/alphaBound/extensions.dart';
import 'package:gameboy/presentation/app/blocs/game/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game/states.dart';

//Expects fixed height and unbounded width.
//TODO: Add expected layout constraints to other widgets doc like this as well.
class ProgressTracker extends StatelessWidget {
  const ProgressTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      builder: (BuildContext context, GameState state) {
        var statistics = context.getStatsRepository();
        var gameState = context.getCurrentAlphaBoundGameStatus();
        return SizedBox(
          height: 100,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _createNumberOfAttemptedGuessesWidget(
                    statistics.numberOfWordsGuessedToday),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _createNumberOfAttemptedGuessesTracker(
                      statistics.numberOfWordsGuessedToday, gameState),
                ),
              ),
            ],
          ),
        );
      },
      buildWhen: (previousState, currentState) {
        return currentState is AlphaBoundGameState &&
            currentState.hasGameMovedAhead();
      },
      listener: (BuildContext context, GameState state) {},
    );
  }

  Widget _createNumberOfAttemptedGuessesWidget(int numberOfGuesses) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.contain,
          child: Text('GUESS'),
        ),
        Expanded(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Text(
                '$numberOfGuesses / ${AlphaBoundConstants.numberOfAllowedGuesses}'),
          ),
        ),
      ],
    );
  }

  Widget _createNumberOfAttemptedGuessesTracker(
      int numberOfGuesses, AlphaBoundGameStatus gameState) {
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      children: List.generate(
        AlphaBoundConstants.numberOfAllowedGuesses,
        (index) {
          Color backgroundColor = Colors.grey;
          if (index < numberOfGuesses) {
            backgroundColor = Colors.red;
            if (gameState is GameWon) {
              if (index == (numberOfGuesses - 1)) {
                backgroundColor = Colors.green;
              }
            }
          } else if (index == numberOfGuesses) {
            if (!(gameState is GameWon || gameState is GameLost)) {
              backgroundColor = Colors.green;
            }
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
