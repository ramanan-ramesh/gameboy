import 'package:gameboy/data/app/models/game_engine.dart';
import 'package:gameboy/data/app/models/stats.dart';

abstract class GameState {}

abstract class GameLoading extends GameState {}

class GameLoaded extends GameState {
  final GameEngine gameEngine;
  final Statistics statistics;

  GameLoaded(this.gameEngine, this.statistics);
}
