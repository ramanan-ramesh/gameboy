import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/alphaBound/implementation/game_engine.dart';
import 'package:gameboy/data/alphaBound/implementation/stats.dart';
import 'package:gameboy/data/alphaBound/models/constants.dart';
import 'package:gameboy/data/alphaBound/models/game_engine.dart';
import 'package:gameboy/data/alphaBound/models/game_status.dart';
import 'package:gameboy/data/alphaBound/models/stats.dart';
import 'package:gameboy/presentation/alphaBound/bloc/events.dart';
import 'package:gameboy/presentation/alphaBound/bloc/states.dart';
import 'package:gameboy/presentation/app/blocs/game/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game/events.dart';
import 'package:gameboy/presentation/app/blocs/game/states.dart';

class AlphaBoundBloc extends GameBloc<GameEvent, GameState,
    AlphaBoundStatsModifier, AlphaBoundGameEngineDriver> {
  AlphaBoundBloc(String userId) : super(userId: userId) {
    on<SubmitGuessWord>(_onSubmitGuessWord);
  }

  @override
  FutureOr<AlphaBoundGameState?> getGameStateOnStartup() {
    if (gameEngine.currentState is GameWon ||
        gameEngine.currentState is GameLost) {
      return AlphaBoundGameState(
          gameStatus: gameEngine.currentState, isStartup: true);
    }
    return null;
  }

  @override
  Future<AlphaBoundGameEngineDriver> gameEngineCreator(
      AlphaBoundStatsModifier stats) async {
    return await AlphaBoundGameEngineImpl.create(
        stats.lowerBound,
        stats.upperBound,
        stats.finalGuessWord,
        stats.numberOfWordsGuessedToday);
  }

  @override
  Future<AlphaBoundStatsModifier> statisticsCreator() async {
    return await AlphaBoundStatsRepo.create(userId);
  }

  FutureOr<void> _onSubmitGuessWord(
      SubmitGuessWord event, Emitter<GameState> emit) async {
    if (gameEngine.numberOfWordsGuessedToday !=
        AlphaBoundConstants.numberOfAllowedGuesses) {
      if (event.guessWord.length ==
          AlphaBoundConstants.numberOfLettersInGuess) {
        var gameState = await gameEngine.trySubmitGuess(event.guessWord);
        if (gameState is GuessMovesUp || gameState is GuessMovesDown) {
          await stats.updateLowerAndUpperBound(
              gameEngine.currentState.lowerBound,
              gameEngine.currentState.upperBound);
        } else if (gameState is GameWon || gameState is GameLost) {
          await stats.submitGuessOnEndGame(
              event.guessWord, gameState is GameWon);
        }
        emit(AlphaBoundGameState(gameStatus: gameState));
      }
    }
  }
}
