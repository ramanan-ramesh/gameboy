import 'package:gameboy/data/alphaBound/models/game_engine.dart';
import 'package:gameboy/data/alphaBound/models/game_state.dart'
    as alphaBoundState;
import 'package:gameboy/data/alphaBound/models/stats.dart';
import 'package:gameboy/presentation/app/blocs/game_state.dart';

abstract class AlphaBoundState extends GameState {
  bool hasGameMovedAhead() {
    if (this is AlphaBoundGameState) {
      var alphaBoundGameState = this as AlphaBoundGameState;
      return alphaBoundGameState.gameState is alphaBoundState.GameWon ||
          alphaBoundGameState.gameState is alphaBoundState.GameLost ||
          alphaBoundGameState.gameState is alphaBoundState.GuessMovesUp ||
          alphaBoundGameState.gameState is alphaBoundState.GuessMovesDown;
    }
    return false;
  }
}

class AlphaBoundLoading extends AlphaBoundState implements GameLoading {}

class AlphaBoundLoaded extends AlphaBoundState implements GameLoaded {
  @override
  final AlphaBoundStats statistics;

  @override
  final GameEngineData gameEngine;

  AlphaBoundLoaded({required this.statistics, required this.gameEngine});
}

class AlphaBoundGameState extends AlphaBoundState {
  final alphaBoundState.GameState gameState;
  final bool isStartup;

  AlphaBoundGameState({required this.gameState, this.isStartup = false});
}

class ShowStats extends AlphaBoundState {}
