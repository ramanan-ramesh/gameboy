import 'package:gameboy/data/alphaBound/models/game_state.dart'
    as alphaBoundState;
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

class AlphaBoundGameState extends AlphaBoundState {
  final alphaBoundState.GameState gameState;
  final bool isStartup;

  AlphaBoundGameState({required this.gameState, this.isStartup = false});
}
