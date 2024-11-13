import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:gameboy/data/wordle/constants.dart';
import 'package:gameboy/data/wordle/models/stat_modifier.dart';
import 'package:intl/intl.dart';

class StatsRepository extends StatModifier {
  static const _wordleField = 'wordle';
  static const _userDataField = 'userData';
  static const _answersField = 'answers';
  static const _currentStreakField = 'currentStreak';
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static const _maxStreakField = 'maxStreak';
  static const _numberOfGamesPlayedField = 'numberOfGamesPlayed';
  static const _wonPositionsField = 'wonPositions';
  static const _lastGuessedWordsField = 'lastGuessedWords';
  static const _currentGuessEditingDayField = 'currentGuessEditingDay';
  static final _firstDay = DateTime(2024, 11, 6);

  static Future<StatsRepository> createInstance(String userId) async {
    var userDataReference = FirebaseDatabase.instance
        .ref()
        .child(_wordleField)
        .child(_userDataField)
        .child(userId);
    var userDocumentData = await userDataReference.get();
    int currentStreak = 0, maxStreak = 0, numberOfGamesPlayed = 0;
    var wonPositions =
        List.generate(WordleConstants.numberOfGuesses, (index) => 0);
    DateTime? currentlyEditingGuessDay;
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

      if (currentlyEditingGuessDay != null &&
          !_areDatesOnSameDay(currentlyEditingGuessDay, currentDay)) {
        await userDataReference.child(_lastGuessedWordsField).remove();
        lastGuessedWords.clear();
        await userDataReference.child(_currentStreakField).set(0);
        currentStreak = 0;
      }
    }
    var wordOfTheDay = await _getWordOfTheDay(currentDay);
    return StatsRepository._(
        currentStreak: currentStreak,
        maxStreak: maxStreak,
        numberOfGamesPlayed: numberOfGamesPlayed,
        wonPositions: wonPositions,
        lastGuessedWords: lastGuessedWords,
        userId: userId,
        currentGuessEditingDay: currentlyEditingGuessDay,
        wordOfTheDay: wordOfTheDay,
        initializedDateTime: currentDay);
  }

  final String userId;

  @override
  DateTime? currentGuessEditingDay;

  @override
  int currentStreak;

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
  final DateTime initializedDateTime;

  @override
  Future<bool> registerGuess(int index, String word) async {
    var didUpdateGuess = false;
    await _wordleUserDataReference
        .child(_lastGuessedWordsField)
        .child(index.toString())
        .set(word)
        .then((_) => didUpdateGuess = true)
        .onError((_, __) => didUpdateGuess = false);
    if (didUpdateGuess) {
      lastGuessedWords.add(word);
      await _wordleUserDataReference
          .child(_currentGuessEditingDayField)
          .set(_dateFormat.format(initializedDateTime))
          .then((_) => didUpdateGuess = true)
          .onError((_, __) => didUpdateGuess = false);
      currentGuessEditingDay = initializedDateTime;
    }
    return didUpdateGuess;
  }

  @override
  Future<bool> registerLoss() async {
    var didUpdateLoss = false;
    await _wordleUserDataReference
        .update({
          _currentStreakField: 0,
          _numberOfGamesPlayedField: numberOfGamesPlayed + 1,
          _currentGuessEditingDayField: null,
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
    var newWonPositions = _wonPositions.toList();
    var wonPosition = lastGuessedWords.length - 1;
    newWonPositions[wonPosition] = newWonPositions[wonPosition] + 1;
    await _wordleUserDataReference
        .update({
          _currentStreakField: currentStreak + 1,
          _maxStreakField: max(maxStreak, currentStreak + 1),
          _numberOfGamesPlayedField: numberOfGamesPlayed + 1,
          _wonPositionsField: newWonPositions
        })
        .then((_) => didUpdateWin = true)
        .onError((_, __) => didUpdateWin = false);
    if (didUpdateWin) {
      ++currentStreak;
      maxStreak = max(maxStreak, currentStreak);
      numberOfGamesPlayed++;
      _wonPositions[wonPosition]++;
    }
    return didUpdateWin;
  }

  @override
  String wordOfTheDay;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
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
    if (currentGuessEditingDay != null) {
      json[_currentGuessEditingDayField] =
          _dateFormat.format(currentGuessEditingDay!);
    }
    return json;
  }

  DatabaseReference get _wordleUserDataReference => FirebaseDatabase.instance
      .ref()
      .child(_wordleField)
      .child(_userDataField)
      .child(userId);

  static Future<String> _getWordOfTheDay(DateTime today) async {
    final daysDifference = _getNumberOfDaysInBetween(today, _firstDay);

    var wordOfTheDayDbRef = FirebaseDatabase.instance
        .ref()
        .child(_wordleField)
        .child(_answersField)
        .child(daysDifference.toString());
    var wordOfTheDayDoc = await wordOfTheDayDbRef.get();
    return wordOfTheDayDoc.value as String;
  }

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
      required this.maxStreak,
      required this.numberOfGamesPlayed,
      required List<int> wonPositions,
      required this.lastGuessedWords,
      required this.userId,
      required this.wordOfTheDay,
      this.currentGuessEditingDay,
      required this.initializedDateTime})
      : _wonPositions = wonPositions;
}
