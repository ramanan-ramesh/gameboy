import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/spelling_bee/models/guessed_word_state.dart';
import 'package:gameboy/presentation/app/blocs/game/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game/states.dart';
import 'package:gameboy/presentation/spelling_bee/bloc/states.dart';
import 'package:gameboy/presentation/spelling_bee/extensions.dart';
import 'package:gameboy/presentation/spelling_bee/widgets/game_results/text_animations.dart';

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
          return Container(height: 100);
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

        return Container(
          height: 100,
          child: Center(
            child: _buildAnimatedText(context, guessedWordResult, state),
          ),
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

  Widget _buildAnimatedText(BuildContext context,
      GuessedWordState guessedWordResult, GameState state) {
    final textStyle = Theme.of(context).textTheme.headlineLarge!.copyWith(
      color: Colors.red,
      shadows: [
        Shadow(
          offset: Offset(2.0, 2.0),
          blurRadius: 3.0,
          color: Colors.black.withOpacity(0.5),
        ),
      ],
    );

    switch (guessedWordResult) {
      case GuessedWordState.notInDictionary:
        return Shake(text: 'Not in dictionary', style: textStyle);
      case GuessedWordState.alreadyGuessed:
        return Blink(text: 'Already Guessed', style: textStyle);
      case GuessedWordState.tooShort:
        return ExpandAndShrink(
          text: 'Too short',
          containerColor: Colors.white12,
          style: textStyle,
        );
      case GuessedWordState.doesNotContainLettersOfTheDay:
        return Bounce(text: 'Bad letters', style: textStyle);
      case GuessedWordState.doesNotContainCenterLetter:
        return Scale(text: 'Missing center letter', style: textStyle);
      default:
        if (state is GuessWordAccepted) {
          var currentRank = context.getGameEngineData().currentScore.rank;
          if (state.guessedWordState == GuessedWordState.pangram) {
            return Rainbow(
              text: 'Pangram!',
              style: Theme.of(context).textTheme.headlineLarge!,
            );
          }
          return PopIn(
            text: '$currentRank! + ${state.score}',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  color: Colors.green,
                ),
          );
        }
        return Container();
    }
  }
}
