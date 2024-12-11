import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/alphaBound/models/constants.dart';
import 'package:gameboy/presentation/alphaBound/bloc/states.dart';
import 'package:gameboy/presentation/alphaBound/extensions.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_state.dart' as gameAppState;

//Expects fixed height and unbounded width.
//TODO: Add expected layout constraints to other widgets doc like this as well.
class ProgressTracker extends StatelessWidget {
  const ProgressTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, gameAppState.GameState>(
      builder: (BuildContext context, gameAppState.GameState state) {
        var statistics = context.getStatsRepository();
        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _createNumberOfAttemptedGuessesWidget(
                  statistics.numberOfWordsGuessed),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _createNumberOfAttemptedGuessesTracker(
                    statistics.numberOfWordsGuessed),
              ),
            ),
          ],
        );
      },
      buildWhen: (previousState, currentState) {
        return currentState is AlphaBoundGameState &&
            currentState.hasGameMovedAhead();
      },
      listener: (BuildContext context, gameAppState.GameState state) {},
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

  Widget _createNumberOfAttemptedGuessesTracker(int numberOfGuesses) {
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      children: List.generate(
        AlphaBoundConstants.numberOfAllowedGuesses,
        (index) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            width: 20.0,
            height: 20.0,
            decoration: BoxDecoration(
              color: index < numberOfGuesses
                  ? Colors.red
                  : index == numberOfGuesses
                      ? Colors.green
                      : Colors.grey,
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }
}
