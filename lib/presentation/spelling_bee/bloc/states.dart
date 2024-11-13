import 'package:gameboy/data/spelling_bee/models/game_engine.dart';
import 'package:gameboy/data/spelling_bee/models/stats.dart';
import 'package:gameboy/presentation/app/blocs/game_state.dart';

abstract class SpellingBeeState extends GameState {}

class SpellingBeeLoading extends SpellingBeeState implements GameLoading {}

class SpellingBeeLoaded extends SpellingBeeState implements GameLoaded {
  @override
  GameEngineData gameEngine;
  @override
  Stats statistics;

  SpellingBeeLoaded({required this.statistics, required this.gameEngine});
}

class WordAlreadyGuessed extends SpellingBeeState {}

class WordNotInDictionary extends SpellingBeeState {}

class WordGuessed extends SpellingBeeState {}
