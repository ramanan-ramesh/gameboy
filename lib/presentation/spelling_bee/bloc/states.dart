import 'package:gameboy/data/spelling_bee/models/game_engine.dart';
import 'package:gameboy/data/spelling_bee/models/guessed_word_state.dart';
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

class GuessedWordResult extends SpellingBeeState {
  GuessedWordState guessedWordState;
  GuessedWordResult(this.guessedWordState);
}

class GuessWordAccepted extends GuessedWordResult {
  int score;
  GuessWordAccepted(super.guessedWordState, this.score);
}

class ShowStats extends SpellingBeeState {}
