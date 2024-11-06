import 'package:gameboy/data/wordle/models/game__engine_data.dart';
import 'package:gameboy/data/wordle/models/stats.dart';

abstract class WordleState {}

class GameLoading extends WordleState {}

class WordleLoaded extends WordleState {
  GameEngineData gameEngineData;
  Stats wordleStats;

  WordleLoaded({required this.wordleStats, required this.gameEngineData});
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
