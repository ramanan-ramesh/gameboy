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
  GameWon({required this.guessedIndex});
}

class GameLost extends WordleState {
  int guessedIndex;
  GameLost({required this.guessedIndex});
}
