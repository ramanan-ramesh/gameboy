import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:gameboy/data/wordle/constants.dart';
import 'package:gameboy/data/wordle/models/stat_modifier.dart';
import 'package:intl/intl.dart';

class StatsRepository extends WordleStatModifier {
  static const _wordleField = 'wordle';
  static const _userDataField = 'userData';
  static const _answersField = 'answers';
  static const _currentStreakField = 'currentStreak';
  static final _dateFormat = DateFormat('dd/MM/yyyy');
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
          !currentlyEditingGuessDay.isOnSameDayAs(currentDay)) {
        await userDataReference
            .update({_lastGuessedWordsField: null, _currentStreakField: 0});
        lastGuessedWords.clear();
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
        wordOfTheDay: wordOfTheDay,
        initializedDateTime: currentDay);
  }

  final String userId;

  @override
  int currentStreak;

  @override
  int maxStreak;

  @override
  int numberOfGamesPlayed;

  @override
  List<int> wonPositions;

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
      _currentGuessEditingDayField: _dateFormat.format(initializedDateTime)
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
    var newWonPositions = wonPositions.toList();
    var wonPosition = lastGuessedWords.length - 1;
    newWonPositions[wonPosition]++;
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
      wonPositions[wonPosition]++;
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

  StatsRepository._(
      {required this.currentStreak,
      required this.maxStreak,
      required this.numberOfGamesPlayed,
      required this.wonPositions,
      required this.lastGuessedWords,
      required this.userId,
      required this.wordOfTheDay,
      required this.initializedDateTime});
}
