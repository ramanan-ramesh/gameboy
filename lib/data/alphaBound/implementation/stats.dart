import 'dart:math';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:gameboy/data/alphaBound/models/constants.dart';
import 'package:gameboy/data/alphaBound/models/stats.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:intl/intl.dart';

class AlphaBoundStatisticsImpl extends AlphaBoundStatsModifier {
  static const _alphaBoundField = 'alphaBound';
  static const _userDataField = 'userData';
  static const _lowerBoundField = 'lowerBound';
  static const _upperBoundField = 'upperBound';
  static const _numberOfGamesPlayedField = 'played';
  static const _numberOfWordsGuessedTodayField = 'guessCountToday';
  static const _finalGuessWordField = 'finalGuessWord';
  static const _lastPlayedAtField = 'lastPlayedAt';
  static const _currentStreakField = 'streak';
  static const _maximumStreakField = 'maxStreak';
  static const _winCountsInPositionsField = 'winCounts';
  static final _dateFormat = DateFormat('dd/MM/yyyy');

  static Future<AlphaBoundStatsModifier> create(String userId) async {
    var initializedDateTime = DateTime.now();
    int numberOfGamesPlayed = 0,
        numberOfWordsGuessedToday = 0,
        currentStreak = 0,
        maximumStreak = 0;
    String? lowerBound, upperBound, finalGuessWord;
    DateTime? lastPlayedDate;
    var userDataReference = FirebaseDatabase.instance
        .ref()
        .child(_alphaBoundField)
        .child(_userDataField)
        .child(userId);
    var userDocumentData = await userDataReference.get();
    List<int> winCountsInPositions =
        List.generate(AlphaBoundConstants.numberOfAllowedGuesses, (index) => 0);
    if (userDocumentData.exists) {
      var userData = userDocumentData.value as Map;
      if (userData.containsKey(_numberOfGamesPlayedField)) {
        numberOfGamesPlayed =
            int.parse(userData[_numberOfGamesPlayedField].toString());
      }
      if (userData.containsKey(_numberOfWordsGuessedTodayField)) {
        numberOfWordsGuessedToday =
            int.parse(userData[_numberOfWordsGuessedTodayField].toString());
      }
      if (userData.containsKey(_lowerBoundField)) {
        lowerBound = userData[_lowerBoundField];
      }
      if (userData.containsKey(_upperBoundField)) {
        upperBound = userData[_upperBoundField];
      }
      if (userData.containsKey(_finalGuessWordField)) {
        finalGuessWord = userData[_finalGuessWordField];
      }
      if (userData.containsKey(_lastPlayedAtField)) {
        lastPlayedDate = _dateFormat.parse(userData[_lastPlayedAtField]);
      }
      if (userData.containsKey(_currentStreakField)) {
        currentStreak = int.parse(userData[_currentStreakField].toString());
      }
      if (userData.containsKey(_maximumStreakField)) {
        maximumStreak = int.parse(userData[_maximumStreakField].toString());
      }
      if (userData.containsKey(_winCountsInPositionsField)) {
        var winCountsData = userData[_winCountsInPositionsField] as Map;
        for (var winCountInPosition in winCountsData.entries) {
          var positionName = winCountInPosition.key.toString();
          var position =
              int.parse(positionName.substring(3)); //'val10', 'val3' etc.
          winCountsInPositions[position] =
              int.parse(winCountInPosition.value.toString());
        }
      }
    }

    return AlphaBoundStatisticsImpl._(
        initializedDateTime: initializedDateTime,
        numberOfGamesPlayed: numberOfGamesPlayed,
        lowerBound: lowerBound,
        upperBound: upperBound,
        userId: userId,
        numberOfWordsGuessedToday: numberOfWordsGuessedToday,
        finalGuessWord: finalGuessWord,
        currentStreak: currentStreak,
        maximumStreak: maximumStreak,
        winCountsInPositions: winCountsInPositions,
        lastPlayedDate: lastPlayedDate);
  }

  @override
  Future reCalculate() async {
    var shouldResetLastPlayedGameData = false;
    var shouldResetStreak = false;
    if (_lastPlayedDate != null) {
      var numberOfDaysInBetween =
          _lastPlayedDate!.numberOfDaysInBetween(initializedDateTime);
      if (numberOfDaysInBetween >= 1) {
        shouldResetLastPlayedGameData = true;
        if (numberOfDaysInBetween > 1) {
          shouldResetStreak = true;
        }
      }
    } else {
      shouldResetLastPlayedGameData = true;
      shouldResetStreak = true;
    }
    if (shouldResetLastPlayedGameData) {
      var jsonToUpdate = <String, Object?>{
        _finalGuessWordField: null,
        _lowerBoundField: null,
        _upperBoundField: null,
        _lastPlayedAtField: null,
        _numberOfWordsGuessedTodayField: null,
        if (shouldResetStreak) _currentStreakField: 0
      };
      await _userDataReference.update(jsonToUpdate).then((_) {
        lowerBound = null;
        upperBound = null;
        finalGuessWord = null;
        _lastPlayedDate = null;
        numberOfWordsGuessedToday = 0;
        if (shouldResetStreak) {
          currentStreak = 0;
        }
      });
    }
  }

  final String userId;

  DateTime? _lastPlayedDate;

  @override
  final DateTime initializedDateTime;

  @override
  int numberOfGamesPlayed;

  @override
  String? lowerBound;

  @override
  String? upperBound;

  @override
  int numberOfWordsGuessedToday;

  @override
  String? finalGuessWord;

  @override
  int currentStreak;

  @override
  int maximumStreak;

  @override
  Iterable<int> get winCountsInPositions => _winCountsInPositions;
  final List<int> _winCountsInPositions;

  @override
  Future<bool> updateLowerAndUpperBound(
      String lowerBoundGuess, String upperBoundGuess) {
    return _trySubmitGuessWord(
        {_lowerBoundField: lowerBoundGuess, _upperBoundField: upperBoundGuess},
        () {
      lowerBound = lowerBoundGuess;
      upperBound = upperBoundGuess;
    });
  }

  @override
  Future<bool> submitGuessOnEndGame(String guess, bool didWin) async {
    var currentStreak = didWin ? this.currentStreak + 1 : 0;
    var maximumStreak = max(this.maximumStreak, currentStreak);

    var jsonToUpdate = <String, Object?>{
      _finalGuessWordField: guess,
      _currentStreakField: currentStreak,
      _maximumStreakField: maximumStreak,
      _numberOfGamesPlayedField: numberOfGamesPlayed + 1,
    };
    if (didWin) {
      var newWonPositionsValue = <String, int>{};
      for (var index = 0; index < _winCountsInPositions.length; index++) {
        var winCount = _winCountsInPositions[index];
        if (didWin && (index == numberOfWordsGuessedToday - 1)) {
          newWonPositionsValue['val$index'] = winCount + 1;
        } else if (winCount > 0) {
          newWonPositionsValue['val$index'] = winCount;
        }
      }
      jsonToUpdate[_winCountsInPositionsField] = newWonPositionsValue;
    }
    return await _trySubmitGuessWord(jsonToUpdate, () {
      finalGuessWord = guess;
      this.currentStreak = currentStreak;
      this.maximumStreak = maximumStreak;
      numberOfGamesPlayed++;
      if (didWin) {
        _winCountsInPositions[numberOfWordsGuessedToday - 1]++;
      }
    });
  }

  Future<bool> _trySubmitGuessWord(
      Map<String, Object?> map, VoidCallback successCallback) async {
    var didUpdate = false;
    await _userDataReference
        .update({
      if (!map.containsKey(_lastPlayedAtField))
        _lastPlayedAtField: _dateFormat.format(initializedDateTime),
      _numberOfWordsGuessedTodayField: numberOfWordsGuessedToday + 1
    }..addAll(map))
        .then((_) {
      numberOfWordsGuessedToday++;
      successCallback();
      didUpdate = true;
    }).onError((error, stackTrace) {
      didUpdate = false;
    });
    return didUpdate;
  }

  DatabaseReference get _userDataReference => FirebaseDatabase.instance
      .ref()
      .child(_alphaBoundField)
      .child(_userDataField)
      .child(userId);

  AlphaBoundStatisticsImpl._(
      {required this.initializedDateTime,
      required this.numberOfGamesPlayed,
      required this.lowerBound,
      required this.upperBound,
      required this.userId,
      required this.numberOfWordsGuessedToday,
      required this.finalGuessWord,
      required this.currentStreak,
      required this.maximumStreak,
      required List<int> winCountsInPositions,
      required DateTime? lastPlayedDate})
      : _winCountsInPositions = winCountsInPositions,
        _lastPlayedDate = lastPlayedDate;
}
