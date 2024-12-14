import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/alphaBound/models/constants.dart';
import 'package:gameboy/data/alphaBound/models/game_engine_driver.dart';
import 'package:gameboy/data/alphaBound/models/game_state.dart';
import 'package:gameboy/data/alphaBound/models/stats.dart';
import 'package:gameboy/presentation/alphaBound/bloc/events.dart';
import 'package:gameboy/presentation/alphaBound/bloc/states.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';

class _LoadGame extends AlphaBoundEvent {
  final String userId;
  _LoadGame(this.userId);
}

class AlphaBoundBloc extends GameBloc<AlphaBoundEvent, AlphaBoundState> {
  static late AlphaBoundStatsModifier alphaBoundStatsModifier;
  GameEngineDriver? gameEngineDriver;

  AlphaBoundBloc(String userId) : super(AlphaBoundLoading()) {
    on<_LoadGame>(_onLoadGame);
    on<SubmitGuessWord>(_onSubmitGuessWord);
    on<RequestStats>(_onRequestStats);
    add(_LoadGame(userId));
  }

  FutureOr<void> _onLoadGame(
      _LoadGame event, Emitter<AlphaBoundState> emitter) async {
    alphaBoundStatsModifier =
        await AlphaBoundStatsModifier.createInstance(event.userId);
    gameEngineDriver = await GameEngineDriver.createInstance(
        alphaBoundStatsModifier.todaysLowerBoundGuess,
        alphaBoundStatsModifier.todaysUpperBoundGuess,
        alphaBoundStatsModifier.numberOfWordsGuessed,
        alphaBoundStatsModifier.middleGuessedWord);
    emitter(AlphaBoundLoaded(
        statistics: alphaBoundStatsModifier, gameEngine: gameEngineDriver!));
    _tryEmitGameResultOnStartup(emitter);
  }

  FutureOr<void> _onSubmitGuessWord(
      SubmitGuessWord event, Emitter<AlphaBoundState> emit) async {
    if (gameEngineDriver!.numberOfWordsGuessed !=
        AlphaBoundConstants.numberOfAllowedGuesses) {
      if (event.guessWord.length ==
          AlphaBoundConstants.numberOfLettersInGuess) {
        var gameState = gameEngineDriver!.trySubmitGuess(event.guessWord);
        if (gameState is GuessMovesUp || gameState is GuessMovesDown) {
          await alphaBoundStatsModifier.tryUpdateLowerAndUpperBoundGuess(
              gameEngineDriver!.currentState.lowerBound,
              gameEngineDriver!.currentState.upperBound);
        } else if (gameState is GameWon || gameState is GameLost) {
          await alphaBoundStatsModifier.trySubmitGuessWordOnEndGame(
              event.guessWord, gameState is GameWon);
        }
        emit(AlphaBoundGameState(gameState: gameState));
      }
    }
  }

  void _tryEmitGameResultOnStartup(Emitter<AlphaBoundState> emitter) {
    if (gameEngineDriver!.currentState is GameWon ||
        gameEngineDriver!.currentState is GameLost) {
      emitter(AlphaBoundGameState(
          gameState: gameEngineDriver!.currentState, isStartup: true));
    }
  }

  FutureOr<void> _onRequestStats(
      RequestStats event, Emitter<AlphaBoundState> emit) {
    emit(ShowStats());
  }
}
