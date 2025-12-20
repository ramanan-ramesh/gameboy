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
        lettersOfTheDay: lettersOfTheDay,
        wordsSubmittedToday: lastSubmittedWords,
        userId: userId,
        lastCompletedMatchDay: lastPlayedMatchDay,
        initializedDateTime: initializedDateTime);
  }

  @override
  Future reCalculate() async {
    if (_lastCompletedMatchDay != null) {
      final daysDifference =
          initializedDateTime.numberOfDaysInBetween(_lastCompletedMatchDay!);
      if (daysDifference > 0) {
        if (_isWin(wordsSubmittedToday)) {
          winCount++;
        }
        wordsSubmittedToday.clear();
        _lastCompletedMatchDay = null;
        await _userDataReference.update({
          _winCountField: winCount,
          _lastPlayedMatchDateField: null,
          _wordsSubmittedTodayField: null,
        });
      }
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
  Future<bool> trySubmitWord(String word) async {
    var didSubmitWord = false;
    await _userDataReference.update({
      _wordsSubmittedTodayField: wordsSubmittedToday.toList()
        ..add(word.toLowerCase()),
      _lastPlayedMatchDateField: _dateFormat.format(initializedDateTime),
    }).then((_) {
      didSubmitWord = true;
      wordsSubmittedToday.add(word.toLowerCase());
      _lastCompletedMatchDay ??= initializedDateTime;
    }).onError((_, __) {
      didSubmitWord = false;
    });

    return didSubmitWord;
  }

  @override
  Future<bool> eraseLastWord() async {
    if (wordsSubmittedToday.isEmpty) return false;
    var didEraseWord = false;
    final updatedWords = wordsSubmittedToday.toList()..removeLast();
    await _userDataReference.update({
      _wordsSubmittedTodayField: updatedWords.isEmpty ? null : updatedWords,
      if (updatedWords.isEmpty) _lastPlayedMatchDateField: null,
    }).then((_) {
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

  bool _isWin(Iterable<String> words) {
    var allLetters = lettersOfTheDay.split('').toSet();
    var usedLetters = words.expand((w) => w.split('')).toSet();
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
      required this.lettersOfTheDay,
      required this.wordsSubmittedToday,
      required String userId,
      required DateTime? lastCompletedMatchDay,
      required this.initializedDateTime})
      : _userId = userId,
        _lastCompletedMatchDay = lastCompletedMatchDay;
}
