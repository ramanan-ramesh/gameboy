import 'package:gameboy/data/app/models/game_engine.dart';
import 'package:gameboy/data/app/models/stats.dart';

abstract class GameState {}

class GameLoading extends GameState {}

class GameLoaded<TGameEngine extends GameEngine, TStats extends Statistics>
    extends GameState {
  final TGameEngine gameEngine;
  final TStats statistics;

  GameLoaded(this.gameEngine, this.statistics);
}

class ShowStats extends GameState {}

class ShowTutorial extends GameState {}
