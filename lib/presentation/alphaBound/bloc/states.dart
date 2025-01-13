import 'package:gameboy/data/alphaBound/models/game_status.dart';
import 'package:gameboy/presentation/app/blocs/game/states.dart';

class AlphaBoundGameState extends GameState {
  final AlphaBoundGameStatus gameStatus;
  final bool isStartup;

  AlphaBoundGameState({required this.gameStatus, this.isStartup = false});

  bool hasGameMovedAhead() {
    return gameStatus is GameWon ||
        gameStatus is GameLost ||
        gameStatus is GuessMovesUp ||
        gameStatus is GuessMovesDown && !isStartup;
  }
}
