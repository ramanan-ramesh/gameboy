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
  static const _hasWonTodayField = 'hasWonToday';
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
    var hasWonToday = userData.containsKey(_hasWonTodayField)
        ? userData[_hasWonTodayField] as bool
        : false;
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
        initializedDateTime: initializedDateTime,
        hadWonLastSession: hasWonToday);
  }

  @override
  Future reCalculate() async {
    if (_lastCompletedMatchDay != null &&
        _lastCompletedMatchDay!.numberOfDaysInBetween(initializedDateTime) >
            0) {
      // Should reset streak if more than 1 day passed, or if 1 day passed without winning
      // Note: _hadWonLastSession is set during initialization based on stored win state
      var shouldResetStreak =
          _lastCompletedMatchDay!.numberOfDaysInBetween(initializedDateTime) >
                  1 ||
              !_hadWonLastSession;

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

  /// Tracks if user had won in the last session (for streak calculation in reCalculate)
  final bool _hadWonLastSession;

  /// Tracks current session win state (synced with Firebase)
  bool _hasWonToday;

  /// Whether the user has won today's challenge
  bool get hasWonToday => _hasWonToday;

  @override
  Future<bool> recordWord(String word) async {
    var didRecordWord = false;
    final updatedWords = wordsSubmittedToday.toList()..add(word.toLowerCase());

    final updateData = <String, dynamic>{
      _wordsSubmittedTodayField: updatedWords,
      _lastPlayedMatchDateField: _dateFormat.format(initializedDateTime),
    };

    await _userDataReference.update(updateData).then((_) {
      didRecordWord = true;
      wordsSubmittedToday.add(word.toLowerCase());
      _lastCompletedMatchDay ??= initializedDateTime;
    }).onError((_, __) {
      didRecordWord = false;
    });

    return didRecordWord;
  }

  @override
  Future<bool> registerWin() async {
    var didRegisterWin = false;
    final newCurrentStreak = currentStreak + 1;
    final newMaximumStreak =
        newCurrentStreak > maximumStreak ? newCurrentStreak : maximumStreak;

    final updateData = <String, dynamic>{
      _winCountField: winCount + 1,
      _currentStreakField: newCurrentStreak,
      _maximumStreakField: newMaximumStreak,
      _hasWonTodayField: true,
    };

    await _userDataReference.update(updateData).then((_) {
      didRegisterWin = true;
      winCount++;
      currentStreak = newCurrentStreak;
      maximumStreak = newMaximumStreak;
      _hasWonToday = true;
    }).onError((_, __) {
      didRegisterWin = false;
    });

    return didRegisterWin;
  }

  @override
  Future<bool> eraseLastWord() async {
    if (wordsSubmittedToday.isEmpty) return false;
    var didEraseWord = false;

    final updatedWords = wordsSubmittedToday.toList()..removeLast();

    final updateData = <String, dynamic>{
      _wordsSubmittedTodayField: updatedWords.isEmpty ? null : updatedWords,
    };

    if (updatedWords.isEmpty) {
      updateData[_lastPlayedMatchDateField] = null;
    }

    await _userDataReference.update(updateData).then((_) {
      didEraseWord = true;
      wordsSubmittedToday.removeLast();
      if (wordsSubmittedToday.isEmpty) {
        _lastCompletedMatchDay = null;
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
      required this.initializedDateTime,
      required bool hadWonLastSession})
      : _userId = userId,
        _lastCompletedMatchDay = lastCompletedMatchDay,
        _hadWonLastSession = hadWonLastSession,
        _hasWonToday = hadWonLastSession;
}
