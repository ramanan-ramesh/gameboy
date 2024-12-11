import 'package:flutter/services.dart';
import 'package:gameboy/data/alphaBound/models/constants.dart';
import 'package:gameboy/data/alphaBound/models/game_engine_driver.dart';
import 'package:gameboy/data/alphaBound/models/game_state.dart';
import 'package:gameboy/data/app/extensions.dart';

class _GameStateInternal extends GameState {
  _GameStateInternal({required super.lowerBound, required super.upperBound});
}

class AlphaBoundGameEngine extends GameEngineDriver {
  static const _pathToDictionary = 'assets/fiveLetterWordDictionary.txt';
  final List<String> _sortedDictionary;
  static final _firstDay = DateTime(2024, 26, 11);
  static const _defaultLowerBoundGuess = 'AAAAA';
  static const _defaultUpperBoundGuess = 'ZZZZZ';

  static Future<GameEngineDriver> create(
      String? lowerBoundGuess,
      String? upperBoundGuess,
      int numberOfWordsGuessed,
      String? middleGuessWord) async {
    var dictionary = await _getAllowedGuesses();
    var numberOfDaysInBetween = _firstDay.numberOfDaysInBetween(DateTime.now());
    var wordOfTheDay = dictionary[numberOfDaysInBetween];
    var displayUpperBoundGuess = upperBoundGuess ?? _defaultUpperBoundGuess,
        displayLowerBoundGuess = lowerBoundGuess ?? _defaultLowerBoundGuess;
    GameState gameState;
    if (middleGuessWord != null) {
      if (middleGuessWord.isEqualTo(wordOfTheDay)) {
        gameState = GameWon(
            lowerBound: displayLowerBoundGuess,
            upperBound: displayUpperBoundGuess);
      } else {
        gameState = GameLost(
            lowerBound: displayLowerBoundGuess,
            upperBound: displayUpperBoundGuess,
            middleGuess: middleGuessWord);
      }
    } else {
      gameState = _GameStateInternal(
          lowerBound: displayLowerBoundGuess,
          upperBound: displayUpperBoundGuess);
    }
    return AlphaBoundGameEngine._(
        currentState: gameState,
        dictionary: dictionary,
        wordOfTheDay: dictionary[numberOfDaysInBetween],
        numberOfWordsGuessed: numberOfWordsGuessed);
  }

  @override
  String wordOfTheDay;

  @override
  int numberOfWordsGuessed;

  @override
  GameState get currentState => _currentState;
  GameState _currentState;

  @override
  GameState trySubmitGuess(String guess) {
    if (!_sortedDictionary.any((element) => element.isEqualTo(guess))) {
      _currentState = GuessNotInDictionary(
          lowerBound: _currentState.lowerBound,
          upperBound: _currentState.upperBound);
      return _currentState;
    }

    if (guess.comparedTo(_currentState.lowerBound, false) <= 0 ||
        guess.comparedTo(_currentState.upperBound, false) >= 0) {
      _currentState = GuessNotInBounds(
          lowerBound: _currentState.lowerBound,
          upperBound: _currentState.upperBound);
      return _currentState;
    }

    numberOfWordsGuessed++;
    if (guess.isEqualTo(wordOfTheDay)) {
      _currentState = GameWon(
          lowerBound: _currentState.lowerBound,
          upperBound: _currentState.upperBound);
      return _currentState;
    } else {
      if (numberOfWordsGuessed == AlphaBoundConstants.numberOfAllowedGuesses) {
        _currentState = GameLost(
            lowerBound: _currentState.lowerBound,
            upperBound: _currentState.upperBound,
            middleGuess: guess);
        return _currentState;
      }

      if (distanceOfWordOfTheDayFromBounds < 0.5) {
        if (guess.comparedTo(wordOfTheDay, false) > 0 &&
            guess.comparedTo(_currentState.upperBound, false) < 0) {
          _currentState = GuessMovesDown(
              lowerBound: _currentState.lowerBound, upperBound: guess);
          return _currentState;
        }
        _currentState = GuessMovesUp(
            lowerBound: guess, upperBound: _currentState.upperBound);
        return _currentState;
      }

      if (guess.comparedTo(wordOfTheDay, false) > 0 &&
          guess.comparedTo(_currentState.upperBound, false) < 0) {
        _currentState = GuessMovesDown(
            lowerBound: _currentState.lowerBound, upperBound: guess);
        return _currentState;
      }
      _currentState =
          GuessMovesUp(lowerBound: guess, upperBound: _currentState.upperBound);
      return _currentState;
    }
  }

  double _calculatePositionOfWordInBounds(String word) {
    // leach
    var lowerBoundIndex = _sortedDictionary
        .indexWhere((e) => e.isEqualTo(_currentState.lowerBound)); // aaaaa
    var upperBoundIndex = _sortedDictionary
        .indexWhere((e) => e.isEqualTo(_currentState.upperBound)); //ratio
    var guessIndex = _sortedDictionary.indexWhere((e) => e.isEqualTo(word));
    var distancePercentage = (guessIndex - lowerBoundIndex) /
        (upperBoundIndex - lowerBoundIndex); //0.7
    return distancePercentage;
  }

  @override
  double get distanceOfWordOfTheDayFromBounds =>
      _calculatePositionOfWordInBounds(wordOfTheDay);

  static Future<List<String>> _getAllowedGuesses() async {
    final String fileContent = await rootBundle.loadString(_pathToDictionary);
    return fileContent.split('\r\n');
  }

  AlphaBoundGameEngine._(
      {required GameState currentState,
      required List<String> dictionary,
      required this.wordOfTheDay,
      required this.numberOfWordsGuessed})
      : _currentState = currentState,
        _sortedDictionary = dictionary.toList()
          ..sort()
          ..insert(0, _defaultLowerBoundGuess)
          ..add(_defaultUpperBoundGuess);
}
