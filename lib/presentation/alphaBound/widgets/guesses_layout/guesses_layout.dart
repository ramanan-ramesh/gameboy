import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/alphaBound/models/game_status.dart';
import 'package:gameboy/presentation/alphaBound/bloc/states.dart';
import 'package:gameboy/presentation/alphaBound/extensions.dart';
import 'package:gameboy/presentation/alphaBound/widgets/guess_letter_range/guess_letter_range_layout.dart';
import 'package:gameboy/presentation/alphaBound/widgets/guesses_layout/animated_guess_word_state.dart';
import 'package:gameboy/presentation/alphaBound/widgets/guesses_layout/guess_word_range_layout.dart';
import 'package:gameboy/presentation/app/blocs/game/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game/states.dart';

class GuessesLayout extends StatelessWidget {
  final double letterSize;
  final ValueNotifier<String> guessLetterValueNotifier;

  const GuessesLayout(
      {super.key,
      required this.guessLetterValueNotifier,
      required this.letterSize});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _createGuessLetterRangeLayout(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 75,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: AnimatedGuessWordState(
                    onAnimationComplete: () {
                      var gameStatus = context.getCurrentAlphaBoundGameStatus();
                      if (gameStatus is GuessNotInDictionary ||
                          gameStatus is GuessNotInBounds) {
                        guessLetterValueNotifier.value = '';
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: GuessWordLayout(
                      letterSize: letterSize,
                      guessWordNotifier: guessLetterValueNotifier),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _createGuessLetterRangeLayout() {
    return BlocConsumer<GameBloc, GameState>(
      builder: (BuildContext context, GameState state) {
        var currentGameState = context.getGameEngineData().currentState;
        var lowerBoundStartLetters = currentGameState.lowerBound[0];
        var upperBoundStartLetters = currentGameState.upperBound[0];
        for (var index = 0;
            index < currentGameState.lowerBound.length;
            index++) {
          if (currentGameState.lowerBound[index] !=
              currentGameState.upperBound[index]) {
            lowerBoundStartLetters =
                currentGameState.lowerBound.substring(0, index + 1);
            upperBoundStartLetters =
                currentGameState.upperBound.substring(0, index + 1);
            break;
          }
        }
        return GuessLetterRangeLayout(
            letterSize: letterSize,
            proximityRatio:
                context.getGameEngineData().wordOfTheDayProximityRatio,
            lowerBoundLetters: lowerBoundStartLetters,
            upperBoundLetters: upperBoundStartLetters);
      },
      listener: (BuildContext context, GameState state) {},
      buildWhen: (previousState, currentState) {
        return (currentState is AlphaBoundGameState) &&
            currentState.hasGameMovedAhead();
      },
    );
  }
}
