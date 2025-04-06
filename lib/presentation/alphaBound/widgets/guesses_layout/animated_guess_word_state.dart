import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/alphaBound/models/game_engine.dart';
import 'package:gameboy/data/alphaBound/models/game_status.dart';
import 'package:gameboy/presentation/alphaBound/bloc/states.dart';
import 'package:gameboy/presentation/alphaBound/extensions.dart';
import 'package:gameboy/presentation/app/blocs/game/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game/states.dart'
    as appGameState;
import 'package:gameboy/presentation/app/widgets/text_animations.dart';

class AnimatedGuessWordState extends StatefulWidget {
  VoidCallback? onAnimationComplete;
  AnimatedGuessWordState({super.key, this.onAnimationComplete});

  @override
  State<AnimatedGuessWordState> createState() => _AnimatedGuessWordStateState();
}

class _AnimatedGuessWordStateState extends State<AnimatedGuessWordState> {
  var _animationComplete = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, appGameState.GameState>(
      listener: (context, state) {
        if (state is AlphaBoundGameState) {
          if (state.gameStatus is GuessNotInDictionary ||
              state.gameStatus is GuessNotInBounds) {
            _animationComplete = false;
          }
        }
      },
      builder: (context, state) {
        var gameEngineData = context.getGameEngineData();
        return Container(
          height: 100,
          child: _animationComplete
              ? null
              : _createAnimatedGuessWordState(gameEngineData),
        );
      },
      buildWhen: (previousState, currentState) {
        return currentState is AlphaBoundGameState &&
            !(currentState.gameStatus is GuessReplacesLowerBound ||
                currentState.gameStatus is GuessReplacesUpperBound);
      },
    );
  }

  Widget? _createAnimatedGuessWordState(AlphaBoundGameEngine gameEngineData) {
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
    Widget? animatedGuessWordState;
    var alphaBoundGameStatus = gameEngineData.currentState;
    var shouldResetAnimation = true;
    if (alphaBoundGameStatus is GuessNotInDictionary) {
      animatedGuessWordState =
          Shake(text: 'Not in dictionary!', style: textStyle);
    } else if (alphaBoundGameStatus is GuessNotInBounds) {
      animatedGuessWordState =
          Blink(text: 'Word outside bounds!', style: textStyle);
    } else if (alphaBoundGameStatus is GameWon) {
      shouldResetAnimation = false;
      animatedGuessWordState = PopIn(
        text: 'You won in ${gameEngineData.numberOfWordsGuessedToday} moves!',
        style: textStyle.copyWith(
          color: Colors.green,
        ),
      );
    } else if (alphaBoundGameStatus is GameLost) {
      shouldResetAnimation = false;
      animatedGuessWordState = Bounce(text: 'Game Over!', style: textStyle);
    }
    if (animatedGuessWordState != null) {
      Future.delayed(Duration(seconds: 2, milliseconds: 100), () {
        if (mounted) {
          setState(() {
            widget.onAnimationComplete?.call();
            _animationComplete = shouldResetAnimation;
          });
        }
      });
    }
    return animatedGuessWordState;
  }
}
