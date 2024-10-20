import 'package:firebase_database/firebase_database.dart';
import 'package:gameboy/data/wordle/models/stat_modifier.dart';
import 'package:intl/intl.dart';

class StatsRepository extends StatModifier {
  static const _wordle = 'wordle';
  static const _userData = 'userData';
  static const _currentStreakField = 'currentStreak';
  static const _lastCompletedMatchDay = 'lastCompletedMatchDay';
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static const _maxStreakField = 'maxStreak';
  static const _numberOfGamesPlayedField = 'numberOfGamesPlayed';
  static const _wonPositionsField = 'wonPositions';
  static const _lastPlayedPositions = 'lastPlayedPositions';

  String userId;

  DatabaseReference get _databaseReference => FirebaseDatabase.instance
      .ref()
      .child(_wordle)
      .child(_userData)
      .child(userId);

  static Future<StatsRepository> createInstance(String userId) async {
    var userDataReference = FirebaseDatabase.instance
        .ref()
        .child(_wordle)
        .child(_userData)
        .child(userId);
    var userDocumentData = await userDataReference.get();
    int currentStreak, maxStreak, numberOfGamesPlayed;
    List<int> wonPositions;
    DateTime? lastCompletedMatchDate;
    List<String> lastPlayedPositions;
    if (!userDocumentData.exists) {
      currentStreak = 0;
      lastCompletedMatchDate = null;
      maxStreak = 0;
      numberOfGamesPlayed = 0;
      wonPositions = List<int>.generate(6, (index) => 0);
      lastPlayedPositions = [];
    } else {
      var userData = userDocumentData.value as Map;
      currentStreak = int.parse(userData[_currentStreakField].toString());
      if (userData.containsKey(_lastCompletedMatchDay)) {
        var dateFieldValue = userData[_lastCompletedMatchDay] as String;
        lastCompletedMatchDate = _dateFormat.parse(dateFieldValue);
      }
      maxStreak = int.parse(userData[_maxStreakField].toString());
      numberOfGamesPlayed =
          int.parse(userData[_numberOfGamesPlayedField].toString());
      wonPositions = List.from(userData[_wonPositionsField])
          .map((e) => int.parse(e.toString()))
          .toList();
      lastPlayedPositions = List.from(userData[_lastPlayedPositions])
          .map((e) => e.toString())
          .toList();

      if (lastCompletedMatchDate != null) {
        var currentDay = DateTime.now();
        var numberOfDaysElapsedSinceLastCompletedMatch =
            _getNumberOfDaysInBetween(currentDay, lastCompletedMatchDate);
        if (numberOfDaysElapsedSinceLastCompletedMatch > 0) {
          await userDataReference.child(_lastPlayedPositions).remove();
          lastPlayedPositions.clear();
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
        lastGuessedWords: lastPlayedPositions,
        userId: userId);
  }

  static int _getNumberOfDaysInBetween(DateTime dateTime1, DateTime dateTime2) {
    var day1 = DateTime(dateTime1.year, dateTime1.month, dateTime1.day);
    var day2 = DateTime(dateTime2.year, dateTime2.month, dateTime2.day);
    return day1.difference(day2).inDays;
  }

  StatsRepository._(
      {required this.currentStreak,
      required this.lastCompletedMatchDay,
      required this.maxStreak,
      required this.numberOfGamesPlayed,
      required this.wonPositions,
      required this.lastGuessedWords,
      required this.userId});

  @override
  int currentStreak;

  @override
  DateTime? lastCompletedMatchDay;

  @override
  int maxStreak;

  @override
  int numberOfGamesPlayed;

  @override
  List<int> wonPositions;

  @override
  List<String> lastGuessedWords;

  @override
  Future submitGame(int index, String word) async {
    lastGuessedWords.add(word);
    var updatedLastPlayedPositions = lastGuessedWords.toList()..add(word);
    await _databaseReference
        .child(_lastPlayedPositions)
        .set(updatedLastPlayedPositions);
    lastGuessedWords = updatedLastPlayedPositions;
  }

  @override
  Future registerLoss(int index, String word) async {
    var currentDateTime = DateTime.now();
    await _databaseReference.child(_currentStreakField).set(0);
    await _databaseReference
        .child(_numberOfGamesPlayedField)
        .set(numberOfGamesPlayed + 1);
    await submitGame(index, word);
    await _databaseReference
        .child(_lastCompletedMatchDay)
        .set(_dateFormat.format(currentDateTime));
    currentStreak = 0;
    numberOfGamesPlayed++;
    lastCompletedMatchDay = currentDateTime;
  }

  @override
  Future registerWin(int index, String word) async {
    await _databaseReference.child(_currentStreakField).set(currentStreak + 1);
    await _databaseReference
        .child(_numberOfGamesPlayedField)
        .set(numberOfGamesPlayed + 1);
    await submitGame(index, word);
    var currentDateTime = DateTime.now();
    await _databaseReference
        .child(_lastCompletedMatchDay)
        .set(_dateFormat.format(currentDateTime));
    if (currentStreak + 1 > maxStreak) {
      await _databaseReference.child(_maxStreakField).set(currentStreak + 1);
    }
    currentStreak++;
    numberOfGamesPlayed++;
    lastCompletedMatchDay = currentDateTime;
    wonPositions[index]++;
    if (currentStreak > maxStreak) {
      maxStreak = currentStreak;
    }
  }
}
