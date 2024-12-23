abstract class AlphaBoundGameStatus {
  final String lowerBound, upperBound;

  AlphaBoundGameStatus({required this.lowerBound, required this.upperBound});
}

class GuessNotInDictionary extends AlphaBoundGameStatus {
  final String guess;

  GuessNotInDictionary(
      {required super.lowerBound,
      required super.upperBound,
      required this.guess});
}

class GuessNotInBounds extends AlphaBoundGameStatus {
  GuessNotInBounds({required super.lowerBound, required super.upperBound});
}

class GameWon extends AlphaBoundGameStatus {
  GameWon({required super.lowerBound, required super.upperBound});
}

class GameLost extends AlphaBoundGameStatus {
  final String finalGuess;

  GameLost(
      {required super.lowerBound,
      required super.upperBound,
      required this.finalGuess});
}

class GuessMovesUp extends AlphaBoundGameStatus {
  GuessMovesUp({required super.lowerBound, required super.upperBound});
}

class GuessMovesDown extends AlphaBoundGameStatus {
  GuessMovesDown({required super.lowerBound, required super.upperBound});
}
