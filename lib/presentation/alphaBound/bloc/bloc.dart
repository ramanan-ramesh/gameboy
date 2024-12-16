import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/alphaBound/models/constants.dart';
import 'package:gameboy/data/alphaBound/models/game_engine_driver.dart';
import 'package:gameboy/data/alphaBound/models/game_state.dart';
import 'package:gameboy/data/alphaBound/models/stats.dart';
import 'package:gameboy/presentation/alphaBound/bloc/events.dart';
import 'package:gameboy/presentation/alphaBound/bloc/states.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_state.dart' as appGameState;

class AlphaBoundBloc extends GameBloc<AlphaBoundEvent, AlphaBoundState,
    AlphaBoundStatsModifier, GameEngineDriver> {
  AlphaBoundBloc(String userId) : super(userId: userId) {
    on<SubmitGuessWord>(_onSubmitGuessWord);
  }

  @override
  FutureOr<AlphaBoundState?> createGameResultOnStartup() {
    if (gameEngine.currentState is GameWon ||
        gameEngine.currentState is GameLost) {
      return AlphaBoundGameState(
          gameState: gameEngine.currentState, isStartup: true);
    }
    return null;
  }

  @override
  Future<GameEngineDriver> gameEngineCreator(
      AlphaBoundStatsModifier stats) async {
    return await GameEngineDriver.createInstance(
        stats.todaysLowerBoundGuess,
        stats.todaysUpperBoundGuess,
        stats.numberOfWordsGuessed,
        stats.middleGuessedWord);
  }

  @override
  Future<AlphaBoundStatsModifier> statisticsCreator() async {
    return await AlphaBoundStatsModifier.createInstance(userId);
  }

  FutureOr<void> _onSubmitGuessWord(
      SubmitGuessWord event, Emitter<appGameState.GameState> emit) async {
    if (gameEngine.numberOfWordsGuessed !=
        AlphaBoundConstants.numberOfAllowedGuesses) {
      if (event.guessWord.length ==
          AlphaBoundConstants.numberOfLettersInGuess) {
        var gameState = gameEngine.trySubmitGuess(event.guessWord);
        if (gameState is GuessMovesUp || gameState is GuessMovesDown) {
          await stats.tryUpdateLowerAndUpperBoundGuess(
              gameEngine.currentState.lowerBound,
              gameEngine.currentState.upperBound);
        } else if (gameState is GameWon || gameState is GameLost) {
          await stats.trySubmitGuessWordOnEndGame(
              event.guessWord, gameState is GameWon);
        }
        emit(AlphaBoundGameState(gameState: gameState));
      }
    }
  }
}
