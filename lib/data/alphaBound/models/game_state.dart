abstract class GameState {
  final String lowerBound, upperBound;

  GameState({required this.lowerBound, required this.upperBound});
}

class GuessNotInDictionary extends GameState {
  GuessNotInDictionary({required super.lowerBound, required super.upperBound});
}

class GuessNotInBounds extends GameState {
  GuessNotInBounds({required super.lowerBound, required super.upperBound});
}

class GameWon extends GameState {
  GameWon({required super.lowerBound, required super.upperBound});
}

class GameLost extends GameState {
  final String middleGuess;

  GameLost(
      {required super.lowerBound,
      required super.upperBound,
      required this.middleGuess});
}

class GuessMovesUp extends GameState {
  GuessMovesUp({required super.lowerBound, required super.upperBound});
}

class GuessMovesDown extends GameState {
  GuessMovesDown({required super.lowerBound, required super.upperBound});
}
