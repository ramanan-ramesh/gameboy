import 'package:firebase_database/firebase_database.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:gameboy/data/lexBox/models/stats.dart';
import 'package:intl/intl.dart';

class LexBoxStatsRepo extends LexBoxStatsModifier {
  static const _lexBoxRootField = 'lexBox';
  static const _lettersOfTheDayField = 'lettersOfTheDay';
  static const _lettersOfTheDayLengthField = 'lettersOfTheDayLength';
  static const _userDataField = 'userData';
  static const _winCountField = 'winCount';
  static const _currentStreakField = 'currentStreak';
  static const _maximumStreakField = 'maximumStreak';
  static const _lastPlayedMatchDateField = 'lastPlayedDate';
  static const _wordsSubmittedTodayField = 'lastGuessedWords';
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final _firstDay = DateTime(2025, 4, 28);

  static Future<LexBoxStatsModifier> createRepository(String userId) async {
    var lexBoxRootDBRef =
        FirebaseDatabase.instance.ref().child(_lexBoxRootField);
    var initializedDateTime = DateTime.now();
    var lettersOfTheDay = await _getLettersOfTheDay(initializedDateTime);
    var userDataDbRef = lexBoxRootDBRef.child(_userDataField).child(userId);
    var userDataValuesDoc = await userDataDbRef.get();
    var userData =
        userDataValuesDoc.exists ? userDataValuesDoc.value as Map : {};
    var winCount = _getIntegerStatistic(userData, _winCountField);
    var currentStreak = _getIntegerStatistic(userData, _currentStreakField);
    var maximumStreak = _getIntegerStatistic(userData, _maximumStreakField);
    List<String> lastSubmittedWords = [];
    DateTime? lastPlayedMatchDay;
    if (userData.containsKey(_lastPlayedMatchDateField)) {
      var dateFieldValue = userData[_lastPlayedMatchDateField] as String;
      lastPlayedMatchDay = _dateFormat.parse(dateFieldValue);

      if (userData.containsKey(_wordsSubmittedTodayField)) {
        var wordsSubmittedTodayValue =
            userData[_wordsSubmittedTodayField] as List;
        lastSubmittedWords = List.from(wordsSubmittedTodayValue)
            .map((e) => e as String)
            .toList();
      }
    }
    return LexBoxStatsRepo._(
        winCount: winCount,
        currentStreak: currentStreak,
        maximumStreak: maximumStreak,
        lettersOfTheDay: lettersOfTheDay,
        wordsSubmittedToday: lastSubmittedWords,
        userId: userId,
        lastCompletedMatchDay: lastPlayedMatchDay,
        initializedDateTime: initializedDateTime);
  }

  @override
  Future reCalculate() async {
    if (_lastCompletedMatchDay != null &&
        _lastCompletedMatchDay!.numberOfDaysInBetween(initializedDateTime) >
            0) {
      // Check if user had won on the last played day
      final hadWonLastDay = _isWin(wordsSubmittedToday);
      // Should reset streak if more than 1 day passed, or if 1 day passed without winning
      var shouldResetStreak =
          _lastCompletedMatchDay!.numberOfDaysInBetween(initializedDateTime) >
                  1 ||
              !hadWonLastDay;

      final updateData = <String, Object?>{
        _wordsSubmittedTodayField: null,
        _lastPlayedMatchDateField: null,
        if (shouldResetStreak) _currentStreakField: 0,
      };

      await _userDataReference.update(updateData).then((_) {
        wordsSubmittedToday.clear();
        _lastCompletedMatchDay = null;
        if (shouldResetStreak) {
          currentStreak = 0;
        }
      });
    }
  }

  @override
  int winCount;

  @override
  final String lettersOfTheDay;

  @override
  List<String> wordsSubmittedToday;

  final String _userId;

  DateTime? _lastCompletedMatchDay;

  @override
  final DateTime initializedDateTime;

  @override
  int currentStreak;

  @override
  int maximumStreak;

  @override
  Future<bool> trySubmitWord(String word) async {
    var didSubmitWord = false;
    final updatedWords = wordsSubmittedToday.toList()..add(word.toLowerCase());

    // Check if this word completes the game (uses all letters)
    final willWin = _isWin(updatedWords);

    final updateData = <String, dynamic>{
      _wordsSubmittedTodayField: updatedWords,
      _lastPlayedMatchDateField: _dateFormat.format(initializedDateTime),
    };

    // If this word causes a win, update streak and win count
    if (willWin) {
      final newCurrentStreak = currentStreak + 1;
      final newMaximumStreak =
          newCurrentStreak > maximumStreak ? newCurrentStreak : maximumStreak;
      updateData[_winCountField] = winCount + 1;
      updateData[_currentStreakField] = newCurrentStreak;
      updateData[_maximumStreakField] = newMaximumStreak;
    }

    await _userDataReference.update(updateData).then((_) {
      didSubmitWord = true;
      wordsSubmittedToday.add(word.toLowerCase());
      _lastCompletedMatchDay ??= initializedDateTime;

      // Update local streak values if won
      if (willWin) {
        winCount++;
        currentStreak++;
        if (currentStreak > maximumStreak) {
          maximumStreak = currentStreak;
        }
      }
    }).onError((_, __) {
      didSubmitWord = false;
    });

    return didSubmitWord;
  }

  @override
  Future<bool> eraseLastWord() async {
    if (wordsSubmittedToday.isEmpty) return false;
    var didEraseWord = false;

    // Check if currently won before erasing
    final isCurrentlyWon = _isWin(wordsSubmittedToday);
    final updatedWords = wordsSubmittedToday.toList()..removeLast();
    final willStillBeWon = _isWin(updatedWords);

    final updateData = <String, dynamic>{
      _wordsSubmittedTodayField: updatedWords.isEmpty ? null : updatedWords,
    };

    if (updatedWords.isEmpty) {
      updateData[_lastPlayedMatchDateField] = null;
    }

    // If erasing this word removes the win, revert the win and streak
    if (isCurrentlyWon && !willStillBeWon) {
      final newCurrentStreak = currentStreak > 0 ? currentStreak - 1 : 0;
      updateData[_winCountField] = winCount > 0 ? winCount - 1 : 0;
      updateData[_currentStreakField] = newCurrentStreak;
    }

    await _userDataReference.update(updateData).then((_) {
      didEraseWord = true;
      wordsSubmittedToday.removeLast();
      if (wordsSubmittedToday.isEmpty) {
        _lastCompletedMatchDay = null;
      }

      // Update local state if win was reverted
      if (isCurrentlyWon && !willStillBeWon) {
        if (winCount > 0) winCount--;
        if (currentStreak > 0) currentStreak--;
      }
    }).onError((_, __) {
      didEraseWord = false;
    });

    return didEraseWord;
  }

  static int _getIntegerStatistic(Map userData, String field) {
    return userData.containsKey(field)
        ? int.parse(userData[field].toString())
        : 0;
  }

  DatabaseReference get _userDataReference => FirebaseDatabase.instance
      .ref()
      .child(_lexBoxRootField)
      .child(_userDataField)
      .child(_userId);

  bool _isWin(Iterable<String> words) {
    var allLetters = lettersOfTheDay.toLowerCase().split('').toSet();
    var usedLetters = words.expand((w) => w.toLowerCase().split('')).toSet();
    return allLetters.every(usedLetters.contains);
  }

  static Future<String> _getLettersOfTheDay(
      DateTime initializedDateTime) async {
    final daysDifference = _firstDay.numberOfDaysInBetween(initializedDateTime);
    final rootRef = FirebaseDatabase.instance.ref().child(_lexBoxRootField);
    final lettersRef = rootRef.child(_lettersOfTheDayField);

    final lengthSnap = await rootRef.child(_lettersOfTheDayLengthField).get();
    final dynamic val = lengthSnap.value;
    final length =
        (val is int) ? val : (val is String ? int.tryParse(val) : null);
    final effectiveIndex = daysDifference % length!;
    final targetSnap = await lettersRef.child(effectiveIndex.toString()).get();
    if (targetSnap.exists && targetSnap.value is String) {
      return targetSnap.value as String;
    }
    // If target missing, attempt index 0 then fallback to full map.
    final zeroSnap = await lettersRef.child('0').get();
    return zeroSnap.value as String;
  }

  LexBoxStatsRepo._(
      {required this.winCount,
      required this.currentStreak,
      required this.maximumStreak,
      required this.lettersOfTheDay,
      required this.wordsSubmittedToday,
      required String userId,
      required DateTime? lastCompletedMatchDay,
      required this.initializedDateTime})
      : _userId = userId,
        _lastCompletedMatchDay = lastCompletedMatchDay;
}
