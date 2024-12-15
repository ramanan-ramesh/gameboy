import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/spelling_bee/models/guessed_word_state.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_state.dart';
import 'package:gameboy/presentation/spelling_bee/bloc/states.dart';
import 'package:gameboy/presentation/spelling_bee/extensions.dart';

class AnimatedGuessedWordResult extends StatefulWidget {
  final VoidCallback onAnimationComplete;
  const AnimatedGuessedWordResult(
      {super.key, required this.onAnimationComplete});

  @override
  State<AnimatedGuessedWordResult> createState() =>
      _AnimatedGuessedWordResultState();
}

class _AnimatedGuessedWordResultState extends State<AnimatedGuessedWordResult> {
  var _animationComplete = true;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      builder: (BuildContext context, GameState state) {
        if (_animationComplete || state is! GuessedWordResult) {
          return Container(
            height: 100,
          );
        }

        var guessedWordResult = state.guessedWordState;
        _animationComplete = false;

        Future.delayed(Duration(seconds: 2, milliseconds: 100), () {
          if (mounted) {
            setState(() {
              widget.onAnimationComplete();
              _animationComplete = true;
            });
          }
        });

        if (guessedWordResult == GuessedWordState.notInDictionary) {
          return AnimatedContainer(
            height: 100,
            color: Colors.white12,
            curve: Curves.elasticInOut,
            duration: Duration(seconds: 2),
            child: Center(
              child: Text(
                'Not in dictionary!',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        } else if (guessedWordResult ==
            GuessedWordState.doesNotContainLettersOfTheDay) {
          return AnimatedContainer(
            height: 100,
            color: Colors.white12,
            curve: Curves.elasticInOut,
            duration: Duration(seconds: 2),
            child: Center(
              child: Text(
                'Bad letters!',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        } else if (guessedWordResult ==
            GuessedWordState.doesNotContainCenterLetter) {
          return AnimatedContainer(
            height: 100,
            color: Colors.white12,
            curve: Curves.elasticInOut,
            duration: Duration(seconds: 2),
            child: Center(
              child: Text(
                'Missing center letter!',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        } else if (state is GuessWordAccepted) {
          var currentRank = context.getGameEngineData().currentScore.rank;

          return AnimatedContainer(
            height: 100,
            color: Colors.white12,
            curve: Curves.bounceInOut,
            duration: Duration(seconds: 2),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(
                      '$currentRank!',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Text(
                    '+ ${state.score}',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          height: 100,
        );
      },
      listener: (BuildContext context, GameState state) {},
      buildWhen: (previous, current) {
        if (current is GuessedWordResult) {
          _animationComplete = false;
          return true;
        }
        return false;
      },
    );
  }
}
