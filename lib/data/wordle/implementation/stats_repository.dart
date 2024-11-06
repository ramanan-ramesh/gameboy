import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:gameboy/data/wordle/constants.dart';
import 'package:gameboy/data/wordle/models/stat_modifier.dart';
import 'package:intl/intl.dart';

class StatsRepository extends StatModifier {
  static const _wordle = 'wordle';
  static const _userData = 'userData';
  static const _currentStreakField = 'currentStreak';
  static const _lastCompletedMatchDayField = 'lastCompletedMatchDay';
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static const _maxStreakField = 'maxStreak';
  static const _numberOfGamesPlayedField = 'numberOfGamesPlayed';
  static const _wonPositionsField = 'wonPositions';
  static const _lastGuessedWordsField = 'lastGuessedWords';
  static const _currentGuessEditingDayField = 'currentGuessEditingDay';

  static Future<StatsRepository> createInstance(String userId) async {
    var userDataReference = FirebaseDatabase.instance
        .ref()
        .child(_wordle)
        .child(_userData)
        .child(userId);
    var userDocumentData = await userDataReference.get();
    int currentStreak = 0, maxStreak = 0, numberOfGamesPlayed = 0;
    var wonPositions =
        List.generate(WordleConstants.numberOfGuesses, (index) => 0);
    DateTime? lastCompletedMatchDate, currentlyEditingGuessDay;
    List<String> lastGuessedWords = [];
    if (userDocumentData.exists) {
      var userData = userDocumentData.value as Map;
      if (userData.containsKey(_currentStreakField)) {
        currentStreak = int.parse(userData[_currentStreakField].toString());
      }
      if (userData.containsKey(_lastCompletedMatchDayField)) {
        var dateFieldValue = userData[_lastCompletedMatchDayField] as String;
        lastCompletedMatchDate = _dateFormat.parse(dateFieldValue);
      }
      if (userData.containsKey(_maxStreakField)) {
        maxStreak = int.parse(userData[_maxStreakField].toString());
      }
      if (userData.containsKey(_numberOfGamesPlayedField)) {
        numberOfGamesPlayed =
            int.parse(userData[_numberOfGamesPlayedField].toString());
      }
      if (userData.containsKey(_wonPositionsField)) {
        wonPositions = List.from(userData[_wonPositionsField])
            .map((e) => int.parse(e.toString()))
            .toList();
      }
      if (userData.containsKey(_lastGuessedWordsField)) {
        lastGuessedWords = List.from(userData[_lastGuessedWordsField])
            .map((e) => e.toString())
            .toList();
      }
      if (userData.containsKey(_currentGuessEditingDayField)) {
        var dateFieldValue = userData[_currentGuessEditingDayField] as String;
        currentlyEditingGuessDay = _dateFormat.parse(dateFieldValue);
      }

      if (lastCompletedMatchDate != null) {
        var currentDay = DateTime.now();
        var numberOfDaysElapsedSinceLastCompletedMatch =
            _getNumberOfDaysInBetween(currentDay, lastCompletedMatchDate);
        if (numberOfDaysElapsedSinceLastCompletedMatch > 0) {
          if (currentlyEditingGuessDay != null &&
              !_areDatesOnSameDay(currentlyEditingGuessDay, currentDay)) {
            await userDataReference.child(_lastGuessedWordsField).remove();
            lastGuessedWords.clear();
          }
        }
        if (numberOfDaysElapsedSinceLastCompletedMatch > 1) {
          await userDataReference.child(_currentStreakField).set(0);
          currentStreak = 0;
        }
      }
    }
    return StatsRepository._(
        currentStreak: currentStreak,
        lastCompletedMatchDay: lastCompletedMatchDate,
        maxStreak: maxStreak,
        numberOfGamesPlayed: numberOfGamesPlayed,
        wonPositions: wonPositions,
        lastGuessedWords: lastGuessedWords,
        userId: userId,
        currentGuessEditingDay: currentlyEditingGuessDay);
  }

  final String userId;

  final DateTime _initializedDateTime;

  DateTime? _currentGuessEditingDay;

  @override
  int currentStreak;

  @override
  DateTime? lastCompletedMatchDay;

  @override
  int maxStreak;

  @override
  int numberOfGamesPlayed;

  @override
  Iterable<int> get wonPositions => _wonPositions;
  List<int> _wonPositions;

  @override
  List<String> lastGuessedWords;

  @override
  Future<bool> registerGuess(int index, String word) async {
    var didUpdateGuess = false;
    await _databaseReference
        .child(_lastGuessedWordsField)
        .child(index.toString())
        .set(word)
        .then((_) => didUpdateGuess = true)
        .onError((_, __) => didUpdateGuess = false);
    if (didUpdateGuess) {
      lastGuessedWords.add(word);
      await _databaseReference
          .child(_currentGuessEditingDayField)
          .set(_dateFormat.format(_initializedDateTime))
          .then((_) => didUpdateGuess = true)
          .onError((_, __) => didUpdateGuess = false);
    }
    return didUpdateGuess;
  }

  @override
  Future<bool> registerLoss() async {
    var didUpdateLoss = false;
    await _databaseReference
        .update({
          _currentStreakField: 0,
          _numberOfGamesPlayedField: numberOfGamesPlayed + 1,
          _lastCompletedMatchDayField: _dateFormat.format(_initializedDateTime)
        })
        .then((_) => didUpdateLoss = true)
        .onError((_, __) => didUpdateLoss = false);
    if (didUpdateLoss) {
      currentStreak = 0;
      numberOfGamesPlayed++;
      lastCompletedMatchDay = _initializedDateTime;
    }
    return didUpdateLoss;
  }

  @override
  Future<bool> registerWin() async {
    var didUpdateWin = false;
    var newWonPositions = _wonPositions.toList();
    var wonPosition = lastGuessedWords.length - 1;
    newWonPositions[wonPosition] = newWonPositions[wonPosition] + 1;
    await _databaseReference
        .update({
          _currentStreakField: currentStreak + 1,
          _maxStreakField: max(maxStreak, currentStreak + 1),
          _numberOfGamesPlayedField: numberOfGamesPlayed + 1,
          _lastCompletedMatchDayField: _dateFormat.format(_initializedDateTime),
          _wonPositionsField: newWonPositions
        })
        .then((_) => didUpdateWin = true)
        .onError((_, __) => didUpdateWin = false);
    if (didUpdateWin) {
      ++currentStreak;
      maxStreak = max(maxStreak, currentStreak);
      numberOfGamesPlayed++;
      lastCompletedMatchDay = _initializedDateTime;
      _wonPositions[wonPosition]++;
    }
    return didUpdateWin;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (lastCompletedMatchDay != null) {
      json[_lastCompletedMatchDayField] =
          _dateFormat.format(lastCompletedMatchDay!);
    }
    if (currentStreak != 0) {
      json[_currentStreakField] = currentStreak;
    }
    if (maxStreak != 0) {
      json[_maxStreakField] = maxStreak;
    }
    if (numberOfGamesPlayed != 0) {
      json[_numberOfGamesPlayedField] = numberOfGamesPlayed;
    }
    if (wonPositions.isNotEmpty) {
      json[_wonPositionsField] = _wonPositions;
    }
    if (lastGuessedWords.isNotEmpty) {
      json[_lastGuessedWordsField] = lastGuessedWords;
    }
    if (_currentGuessEditingDay != null) {
      json[_currentGuessEditingDayField] =
          _dateFormat.format(_currentGuessEditingDay!);
    }
    return json;
  }

  DatabaseReference get _databaseReference => FirebaseDatabase.instance
      .ref()
      .child(_wordle)
      .child(_userData)
      .child(userId);

  static int _getNumberOfDaysInBetween(DateTime dateTime1, DateTime dateTime2) {
    var day1 = DateTime(dateTime1.year, dateTime1.month, dateTime1.day);
    var day2 = DateTime(dateTime2.year, dateTime2.month, dateTime2.day);
    return day1.difference(day2).inDays;
  }

  static bool _areDatesOnSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  StatsRepository._(
      {required this.currentStreak,
      required this.lastCompletedMatchDay,
      required this.maxStreak,
      required this.numberOfGamesPlayed,
      required List<int> wonPositions,
      required this.lastGuessedWords,
      required this.userId,
      DateTime? currentGuessEditingDay})
      : _wonPositions = wonPositions,
        _currentGuessEditingDay = currentGuessEditingDay,
        _initializedDateTime = DateTime.now();
}
