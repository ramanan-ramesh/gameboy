import 'package:gameboy/data/app/models/game_engine.dart';
import 'package:gameboy/data/app/models/stats.dart';
import 'package:gameboy/presentation/app/blocs/game_state.dart';

abstract class WordleState extends GameState {}

class WordleLoading extends GameLoading implements WordleState {}

class WordleLoaded extends WordleState implements GameLoaded {
  @override
  final Statistics statistics;

  @override
  final GameEngine gameEngine;

  WordleLoaded({required this.statistics, required this.gameEngine});
}

class GuessEdited extends WordleState {}

class SubmissionNotInDictionary extends WordleState {}

class GuessWordSubmitted extends WordleState {
  int guessIndex;

  GuessWordSubmitted({required this.guessIndex});
}

class GameWon extends WordleState {
  int guessedIndex;
  bool isStartup;
  GameWon({required this.guessedIndex, this.isStartup = false});
}

class GameLost extends WordleState {
  bool isStartup;
  GameLost({this.isStartup = false});
}

class ShowStats extends WordleState {}
