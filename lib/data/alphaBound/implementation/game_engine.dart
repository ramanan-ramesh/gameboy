import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gameboy/data/alphaBound/models/constants.dart';
import 'package:gameboy/data/alphaBound/models/game_engine.dart';
import 'package:gameboy/data/alphaBound/models/game_status.dart';
import 'package:gameboy/data/app/extensions.dart';

class AlphaBoundGameEngineImpl extends AlphaBoundGameEngineDriver {
  static const _pathToDictionary = 'assets/fiveLetterWordDictionary.txt';
  final List<String> _sortedDictionary;
  static final _firstDay = DateTime(2025, 3, 16);
  static const _defaultLowerBoundGuess = 'AAAAA';
  static const _defaultUpperBoundGuess = 'ZZZZZ';

  static Future<AlphaBoundGameEngineDriver> create(
      String? lowerBound,
      String? upperBound,
      String? lastGuessedWord,
      int numberOfWordsGuessed) async {
    var allowedGuesses = await _getAllowedGuesses();

    var currentDayIndex = _firstDay.numberOfDaysInBetween(DateTime.now());
    var wordOfTheDay = allowedGuesses[currentDayIndex];

    var displayUpperBoundGuess = upperBound ?? _defaultUpperBoundGuess,
        displayLowerBoundGuess = lowerBound ?? _defaultLowerBoundGuess;

    var startupGameState = _getStartupGameState(lastGuessedWord, wordOfTheDay,
        displayLowerBoundGuess, displayUpperBoundGuess);

    return AlphaBoundGameEngineImpl._(
        currentState: startupGameState,
        allowedGuesses: allowedGuesses,
        wordOfTheDay: allowedGuesses[currentDayIndex],
        numberOfWordsGuessedToday: numberOfWordsGuessed);
  }

  @override
  String wordOfTheDay;

  @override
  int numberOfWordsGuessedToday;

  @override
  AlphaBoundGameStatus get currentState => _currentState;
  AlphaBoundGameStatus _currentState;

  @override
  Future<AlphaBoundGameStatus> trySubmitGuess(String guess) async {
    if (!await compute(_isGuessInDictionary, guess)) {
      _currentState = GuessNotInDictionary(
          lowerBound: _currentState.lowerBound,
          upperBound: _currentState.upperBound,
          guess: guess);
      return _currentState;
    }

    if (guess.comparedTo(_currentState.lowerBound, false) <= 0 ||
        guess.comparedTo(_currentState.upperBound, false) >= 0) {
      _currentState = GuessNotInBounds(
          lowerBound: _currentState.lowerBound,
          upperBound: _currentState.upperBound);
      return _currentState;
    }

    numberOfWordsGuessedToday++;
    if (guess.isEqualTo(wordOfTheDay)) {
      _currentState = GameWon(
          lowerBound: _currentState.lowerBound,
          upperBound: _currentState.upperBound);
      return _currentState;
    } else {
      if (numberOfWordsGuessedToday ==
          AlphaBoundConstants.maximumGuessesAllowed) {
        _currentState = GameLost(
            lowerBound: _currentState.lowerBound,
            upperBound: _currentState.upperBound,
            finalGuess: guess);
        return _currentState;
      }

      if (guess.comparedTo(wordOfTheDay, false) > 0 &&
          guess.comparedTo(_currentState.upperBound, false) < 0) {
        _currentState = GuessReplacesUpperBound(
            lowerBound: _currentState.lowerBound, upperBound: guess);
        return _currentState;
      }

      _currentState = GuessReplacesLowerBound(
          lowerBound: guess, upperBound: _currentState.upperBound);
      return _currentState;
    }
  }

  @override
  double get wordOfTheDayProximityRatio {
    var lowerBoundIndex = _sortedDictionary
        .indexWhere((e) => e.isEqualTo(_currentState.lowerBound));
    var upperBoundIndex = _sortedDictionary
        .indexWhere((e) => e.isEqualTo(_currentState.upperBound));
    var guessIndex =
        _sortedDictionary.indexWhere((e) => e.isEqualTo(wordOfTheDay));
    var distanceRatio =
        (guessIndex - lowerBoundIndex) / (upperBoundIndex - lowerBoundIndex);
    return distanceRatio;
  }

  bool _isGuessInDictionary(String guess) {
    return _sortedDictionary.any((element) => element.isEqualTo(guess));
  }

  static AlphaBoundGameStatus _getStartupGameState(
      String? lastGuessedWord,
      String wordOfTheDay,
      String displayLowerBoundGuess,
      String displayUpperBoundGuess) {
    if (lastGuessedWord != null) {
      if (lastGuessedWord.isEqualTo(wordOfTheDay)) {
        return GameWon(
            lowerBound: displayLowerBoundGuess,
            upperBound: displayUpperBoundGuess);
      } else {
        return GameLost(
            lowerBound: displayLowerBoundGuess,
            upperBound: displayUpperBoundGuess,
            finalGuess: lastGuessedWord);
      }
    } else {
      return AlphaBoundGameStatus(
          lowerBound: displayLowerBoundGuess,
          upperBound: displayUpperBoundGuess);
    }
  }

  static Future<List<String>> _getAllowedGuesses() async {
    final String fileContent = await rootBundle.loadString(_pathToDictionary);
    return fileContent.split('\r\n');
  }

  AlphaBoundGameEngineImpl._(
      {required AlphaBoundGameStatus currentState,
      required List<String> allowedGuesses,
      required this.wordOfTheDay,
      required this.numberOfWordsGuessedToday})
      : _currentState = currentState,
        _sortedDictionary = allowedGuesses.toList()
          ..sort()
          ..insert(0, _defaultLowerBoundGuess)
          ..add(_defaultUpperBoundGuess);
}
