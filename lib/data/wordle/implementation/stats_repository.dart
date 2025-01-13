import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:gameboy/data/wordle/constants.dart';
import 'package:gameboy/data/wordle/models/stat_modifier.dart';
import 'package:intl/intl.dart';

class WordleStatsRepo extends WordleStatsModifier {
  static const _wordleField = 'wordle';
  static const _userDataField = 'userData';
  static const _answersField = 'answers';
  static const _currentStreakField = 'currentStreak';
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static const _maxStreakField = 'maxStreak';
  static const _numberOfGamesPlayedField = 'played';
  static const _winCountsInPositionsField = 'winCounts';
  static const _lastGuessedWordsField = 'lastGuessedWords';
  static const _lastPlayedDayField = 'lastPlayedDay';
  static final _firstDay = DateTime(2024, 11, 6);

  static Future<WordleStatsRepo> createInstance(String userId) async {
    var userDataReference = FirebaseDatabase.instance
        .ref()
        .child(_wordleField)
        .child(_userDataField)
        .child(userId);
    var userDocumentData = await userDataReference.get();
    int currentStreak = 0, maxStreak = 0, numberOfGamesPlayed = 0;
    var wonPositions =
        List.generate(WordleConstants.numberOfGuesses, (index) => 0);
    DateTime? lastPlayedDay;
    var currentDay = DateTime.now();
    List<String> lastGuessedWords = [];
    if (userDocumentData.exists) {
      var userData = userDocumentData.value as Map;
      if (userData.containsKey(_currentStreakField)) {
        currentStreak = int.parse(userData[_currentStreakField].toString());
      }
      if (userData.containsKey(_maxStreakField)) {
        maxStreak = int.parse(userData[_maxStreakField].toString());
      }
      if (userData.containsKey(_numberOfGamesPlayedField)) {
        numberOfGamesPlayed =
            int.parse(userData[_numberOfGamesPlayedField].toString());
      }
      if (userData.containsKey(_winCountsInPositionsField)) {
        wonPositions = List.from(userData[_winCountsInPositionsField])
            .map((e) => int.parse(e.toString()))
            .toList();
      }
      if (userData.containsKey(_lastGuessedWordsField)) {
        lastGuessedWords = List.from(userData[_lastGuessedWordsField])
            .map((e) => e.toString())
            .toList();
      }
      if (userData.containsKey(_lastPlayedDayField)) {
        var dateFieldValue = userData[_lastPlayedDayField] as String;
        lastPlayedDay = _dateFormat.parse(dateFieldValue);
      }
    }
    var wordOfTheDay = await _getWordOfTheDay(currentDay);
    return WordleStatsRepo._(
        currentStreak: currentStreak,
        maxStreak: maxStreak,
        numberOfGamesPlayed: numberOfGamesPlayed,
        winCountsInPositions: wonPositions,
        lastGuessedWords: lastGuessedWords,
        userId: userId,
        wordOfTheDay: wordOfTheDay,
        initializedDateTime: currentDay,
        lastPlayedDate: lastPlayedDay);
  }

  @override
  Future reCalculate() async {
    if (_lastPlayedDate != null &&
        _lastPlayedDate!.numberOfDaysInBetween(initializedDateTime) > 0) {
      var jsonToUpdate = <String, Object?>{
        _lastGuessedWordsField: null,
        _lastPlayedDayField: null
      };
      if (_lastPlayedDate!.numberOfDaysInBetween(initializedDateTime) > 1) {
        jsonToUpdate[_currentStreakField] = 0;
      }
      var shouldResetStreak =
          _lastPlayedDate!.numberOfDaysInBetween(initializedDateTime) > 1;
      await _wordleUserDataReference.update({
        _lastGuessedWordsField: null,
        _lastPlayedDayField: null,
        if (shouldResetStreak) _currentStreakField: 0
      });
      lastGuessedWords.clear();
      _lastPlayedDate = null;
      if (shouldResetStreak) {
        currentStreak = 0;
      }
    }
  }

  DateTime? _lastPlayedDate;

  final String userId;

  @override
  int currentStreak;

  @override
  int maxStreak;

  @override
  int numberOfGamesPlayed;

  @override
  List<int> winCountsInPositions;

  @override
  List<String> lastGuessedWords;

  @override
  final DateTime initializedDateTime;

  @override
  String wordOfTheDay;

  @override
  Future<bool> registerGuess(int index, String word) async {
    var didUpdateGuess = false;
    await _wordleUserDataReference.update({
      '$_lastGuessedWordsField/$index': word,
      _lastPlayedDayField: _dateFormat.format(initializedDateTime)
    }).then((_) {
      didUpdateGuess = true;
      lastGuessedWords.add(word);
    }).onError((_, __) {
      didUpdateGuess = false;
    });

    return didUpdateGuess;
  }

  @override
  Future<bool> registerLoss() async {
    var didUpdateLoss = false;
    await _wordleUserDataReference
        .update({
          _currentStreakField: 0,
          _numberOfGamesPlayedField: numberOfGamesPlayed + 1,
        })
        .then((_) => didUpdateLoss = true)
        .onError((_, __) => didUpdateLoss = false);
    if (didUpdateLoss) {
      currentStreak = 0;
      numberOfGamesPlayed++;
    }
    return didUpdateLoss;
  }

  @override
  Future<bool> registerWin() async {
    var didUpdateWin = false;
    var newWonPositions = winCountsInPositions.toList();
    var wonPosition = lastGuessedWords.length - 1;
    newWonPositions[wonPosition]++;
    await _wordleUserDataReference
        .update({
          _currentStreakField: currentStreak + 1,
          _maxStreakField: max(maxStreak, currentStreak + 1),
          _numberOfGamesPlayedField: numberOfGamesPlayed + 1,
          _winCountsInPositionsField: newWonPositions
        })
        .then((_) => didUpdateWin = true)
        .onError((_, __) => didUpdateWin = false);
    if (didUpdateWin) {
      ++currentStreak;
      maxStreak = max(maxStreak, currentStreak);
      numberOfGamesPlayed++;
      winCountsInPositions[wonPosition]++;
    }
    return didUpdateWin;
  }

  DatabaseReference get _wordleUserDataReference => FirebaseDatabase.instance
      .ref()
      .child(_wordleField)
      .child(_userDataField)
      .child(userId);

  static Future<String> _getWordOfTheDay(DateTime currentDay) async {
    final daysDifference = currentDay.numberOfDaysInBetween(_firstDay);

    var wordOfTheDayDbRef = FirebaseDatabase.instance
        .ref()
        .child(_wordleField)
        .child(_answersField)
        .child(daysDifference.toString());
    var wordOfTheDayDoc = await wordOfTheDayDbRef.get();
    return wordOfTheDayDoc.value as String;
  }

  WordleStatsRepo._(
      {required this.currentStreak,
      required this.maxStreak,
      required this.numberOfGamesPlayed,
      required this.winCountsInPositions,
      required this.lastGuessedWords,
      required this.userId,
      required this.wordOfTheDay,
      required this.initializedDateTime,
      DateTime? lastPlayedDate})
      : _lastPlayedDate = lastPlayedDate;
}
