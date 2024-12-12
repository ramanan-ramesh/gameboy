import 'dart:math';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:gameboy/data/alphaBound/models/stats.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:intl/intl.dart';

class AlphaBoundStatistics extends AlphaBoundStatsModifier {
  static const _alphaBoundField = 'alphaBound';
  static const _userDataField = 'userData';
  static const _lowerBoundGuessField = 'lowerBoundGuess';
  static const _upperBoundGuessField = 'upperBoundGuess';
  static const _numberOfGamesPlayedField = 'numberOfGamesPlayed';
  static const _numberOfTimesWonField = 'numberOfTimesWon';
  static const _numberOfWordsGuessedField = 'numberOfWordsGuessed';
  static const _middleGuessedWordField = 'middleGuessedWord';
  static const _lastPlayedDateField = 'lastPlayedDate';
  static const _currentStreakField = 'currentStreak';
  static const _maximumStreakField = 'maximumStreak';
  static final _dateFormat = DateFormat('dd/MM/yyyy');

  static Future<AlphaBoundStatsModifier> create(String userId) async {
    var initializedDateTime = DateTime.now();
    int numberOfGamesPlayed = 0,
        numberOfTimesWon = 0,
        numberOfWordsGuessed = 0,
        currentStreak = 0,
        maximumStreak = 0;
    String? todaysLowerBoundGuess, todaysUpperBoundGuess, middleGuessedWord;
    DateTime? lastPlayedDate;
    var userDataReference = FirebaseDatabase.instance
        .ref()
        .child(_alphaBoundField)
        .child(_userDataField)
        .child(userId);
    var userDocumentData = await userDataReference.get();
    if (userDocumentData.exists) {
      var userData = userDocumentData.value as Map;
      if (userData.containsKey(_numberOfGamesPlayedField)) {
        numberOfGamesPlayed =
            int.parse(userData[_numberOfGamesPlayedField].toString());
      }
      if (userData.containsKey(_numberOfTimesWonField)) {
        numberOfTimesWon =
            int.parse(userData[_numberOfTimesWonField].toString());
      }
      if (userData.containsKey(_numberOfWordsGuessedField)) {
        numberOfWordsGuessed =
            int.parse(userData[_numberOfWordsGuessedField].toString());
      }
      if (userData.containsKey(_lowerBoundGuessField)) {
        todaysLowerBoundGuess = userData[_lowerBoundGuessField];
      }
      if (userData.containsKey(_upperBoundGuessField)) {
        todaysUpperBoundGuess = userData[_upperBoundGuessField];
      }
      if (userData.containsKey(_middleGuessedWordField)) {
        middleGuessedWord = userData[_middleGuessedWordField];
      }
      if (userData.containsKey(_lastPlayedDateField)) {
        lastPlayedDate = _dateFormat.parse(userData[_lastPlayedDateField]);
      }
      if (userData.containsKey(_currentStreakField)) {
        currentStreak = int.parse(userData[_currentStreakField].toString());
      }
      if (userData.containsKey(_maximumStreakField)) {
        maximumStreak = int.parse(userData[_maximumStreakField].toString());
      }

      if (lastPlayedDate != null) {
        var numberOfDaysInBetween =
            lastPlayedDate.numberOfDaysInBetween(initializedDateTime);
        var jsonToUpdate = <String, Object?>{
          _middleGuessedWordField: null,
          _lowerBoundGuessField: null,
          _upperBoundGuessField: null,
          _lastPlayedDateField: null
        };
        if (numberOfDaysInBetween >= 1) {
          if (numberOfDaysInBetween > 1) {
            jsonToUpdate[_currentStreakField] = 0;
          }
          await userDataReference.update(jsonToUpdate).then((_) {
            todaysLowerBoundGuess = null;
            todaysUpperBoundGuess = null;
            middleGuessedWord = null;
            lastPlayedDate = null;
            if (numberOfDaysInBetween > 1) {
              currentStreak = 0;
            }
          });
        }
      }
    }

    return AlphaBoundStatistics._(
        initializedDateTime: initializedDateTime,
        numberOfGamesPlayed: numberOfGamesPlayed,
        numberOfTimesWon: numberOfTimesWon,
        todaysLowerBoundGuess: todaysLowerBoundGuess,
        todaysUpperBoundGuess: todaysUpperBoundGuess,
        userId: userId,
        numberOfWordsGuessed: numberOfWordsGuessed,
        middleGuessedWord: middleGuessedWord,
        currentStreak: currentStreak,
        maximumStreak: maximumStreak);
  }

  final String userId;

  @override
  final DateTime initializedDateTime;

  @override
  int numberOfGamesPlayed;

  @override
  int numberOfTimesWon;

  @override
  String? todaysLowerBoundGuess;

  @override
  String? todaysUpperBoundGuess;

  @override
  int numberOfWordsGuessed;

  @override
  String? middleGuessedWord;

  @override
  int currentStreak;

  @override
  int maximumStreak;

  @override
  Future<bool> tryUpdateLowerAndUpperBoundGuess(
      String lowerBoundGuess, String upperBoundGuess) {
    return _trySubmitGuessWord({
      _lowerBoundGuessField: lowerBoundGuess,
      _upperBoundGuessField: upperBoundGuess
    }, () {
      todaysLowerBoundGuess = lowerBoundGuess;
      todaysUpperBoundGuess = upperBoundGuess;
    });
  }

  @override
  Future<bool> trySubmitGuessWordOnEndGame(String guess, bool didWin) async {
    var numberOfTimesWon =
        didWin ? this.numberOfTimesWon + 1 : this.numberOfTimesWon;
    var currentStreak = didWin ? this.currentStreak + 1 : 0;
    var maximumStreak = max(this.maximumStreak, currentStreak);
    return _trySubmitGuessWord({
      _middleGuessedWordField: guess,
      _numberOfTimesWonField: numberOfTimesWon,
      _currentStreakField: currentStreak,
      _maximumStreakField: maximumStreak,
      _numberOfGamesPlayedField: numberOfGamesPlayed + 1,
    }, () {
      middleGuessedWord = guess;
      this.numberOfTimesWon = numberOfTimesWon;
      this.currentStreak = currentStreak;
      this.maximumStreak = maximumStreak;
      numberOfGamesPlayed++;
    });
  }

  Future<bool> _trySubmitGuessWord(
      Map<String, Object?> map, VoidCallback successCallback) async {
    var didUpdate = false;
    await _userDataReference
        .update({
      _lastPlayedDateField: _dateFormat.format(initializedDateTime),
      _numberOfWordsGuessedField: numberOfWordsGuessed + 1
    }..addAll(map))
        .then((_) {
      successCallback();
      numberOfWordsGuessed++;
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

  AlphaBoundStatistics._(
      {required this.initializedDateTime,
      required this.numberOfGamesPlayed,
      required this.numberOfTimesWon,
      required this.todaysLowerBoundGuess,
      required this.todaysUpperBoundGuess,
      required this.userId,
      required this.numberOfWordsGuessed,
      required this.middleGuessedWord,
      required this.currentStreak,
      required this.maximumStreak});
}
