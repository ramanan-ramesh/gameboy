import 'package:gameboy/blocs/game/states.dart';
import 'package:gameboy/data/alphaBound/models/game_status.dart';

class AlphaBoundGameState extends GameState {
  final AlphaBoundGameStatus gameStatus;
  final bool isStartup;

  AlphaBoundGameState({required this.gameStatus, this.isStartup = false});

  bool hasGameMovedAhead() {
    return (gameStatus is GameWon ||
            gameStatus is GameLost ||
            gameStatus is GuessReplacesLowerBound ||
            gameStatus is GuessReplacesUpperBound) &&
        !isStartup;
  }
}
