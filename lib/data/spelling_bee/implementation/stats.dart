import 'package:firebase_database/firebase_database.dart';
import 'package:gameboy/data/spelling_bee/implementation/game_engine.dart';
import 'package:gameboy/data/spelling_bee/models/constants.dart';
import 'package:gameboy/data/spelling_bee/models/stats_modifier.dart';
import 'package:intl/intl.dart';

class StatsRepository extends StatsModifier {
  static const _spellingBeeRootField = 'spelling-bee';
  static const _lettersOfTheDayField = 'lettersOfTheDay';
  static const _userDataField = 'userData';
  static const _numberOfGamesPlayedField = 'numberOfGamesPlayed';
  static const _numberOfPangramsField = 'numberOfPangrams';
  static const _numberOfWordsSubmittedField = 'numberOfWordsSubmitted';
  static const _rankingsCountField = 'rankingsCount';
  static const _lastPlayedMatchDateField = 'matchDate';
  static const _wordsSubmittedTodayField = 'wordsSubmittedToday';
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final _firstDay = DateTime(2024, 11, 6);

  static Future<StatsModifier> createRepository(String userId) async {
    var spellingBeeRootDBRef =
        FirebaseDatabase.instance.ref().child(_spellingBeeRootField);
    var initializedDateTime = DateTime.now();
    var lettersOfTheDay = await _getLettersOfTheDay(initializedDateTime);
    var userDataDbRef =
        spellingBeeRootDBRef.child(_userDataField).child(userId);
    var userDataValuesDoc = await userDataDbRef.get();
    var userData =
        userDataValuesDoc.exists ? userDataValuesDoc.value as Map : {};
    var numberOfGamesPlayed =
            _getIntegerStatistic(userData, _numberOfGamesPlayedField),
        numberOfPangrams =
            _getIntegerStatistic(userData, _numberOfPangramsField),
        numberOfWordsSubmitted =
            _getIntegerStatistic(userData, _numberOfWordsSubmittedField);
    var rankingsCount = <String, int>{};
    if (userData.containsKey(_rankingsCountField)) {
      var rankingsCountValue = userData[_rankingsCountField] as Map;
      rankingsCount = Map<String, int>.from(rankingsCountValue).map(
          (key, value) =>
              MapEntry(key.toString(), int.parse(value.toString())));
    }

    List<String> wordsSubmittedToday = [];
    DateTime? lastCompletedMatchDay;
    if (userData.containsKey(_lastPlayedMatchDateField)) {
      var dateFieldValue = userData[_lastPlayedMatchDateField] as String;
      lastCompletedMatchDay = _dateFormat.parse(dateFieldValue);

      if (userData.containsKey(_wordsSubmittedTodayField)) {
        var wordsSubmittedTodayValue =
            userData[_wordsSubmittedTodayField] as List;
        wordsSubmittedToday = List.from(wordsSubmittedTodayValue)
            .map((e) => e as String)
            .toList();
      }
      final daysDifference =
          _getNumberOfDaysInBetween(initializedDateTime, lastCompletedMatchDay);
      if (daysDifference > 0) {
        var rank = GameEngine.rankCalculator(wordsSubmittedToday);
        if (rankingsCount.containsKey(rank)) {
          rankingsCount[rank] = rankingsCount[rank]! + 1;
        } else {
          rankingsCount[rank] = 1;
        }
        wordsSubmittedToday.clear();
        lastCompletedMatchDay = null;
        numberOfGamesPlayed++;
        numberOfWordsSubmitted += wordsSubmittedToday.length;
        for (var word in wordsSubmittedToday) {
          if (word.length == Constants.numberOfLetters &&
              word.split('').toSet().length == Constants.numberOfLetters) {
            numberOfPangrams++;
          }
        }
        await userDataDbRef.update({
          _rankingsCountField: rankingsCount,
          _lastPlayedMatchDateField: null,
          _wordsSubmittedTodayField: null,
          _numberOfWordsSubmittedField: numberOfWordsSubmitted,
          _numberOfGamesPlayedField: numberOfGamesPlayed,
          _numberOfPangramsField: numberOfPangrams,
        });
      }
    }
    return StatsRepository._(
        rankingsCount: rankingsCount,
        numberOfGamesPlayed: numberOfGamesPlayed,
        numberOfWordsSubmitted: numberOfWordsSubmitted,
        numberOfPangrams: numberOfPangrams,
        lettersOfTheDay: lettersOfTheDay,
        wordsSubmittedToday: wordsSubmittedToday,
        userId: userId,
        lastCompletedMatchDay: lastCompletedMatchDay,
        initializedDateTime: initializedDateTime);
  }

  @override
  final int numberOfGamesPlayed;

  @override
  final int numberOfPangrams;

  @override
  final int numberOfWordsSubmitted;

  @override
  Future<bool> trySubmitWord(String word) async {
    if (_doesWordListContainWord(_wordsSubmittedToday, word)) {
      return false;
    }
    var didSubmitWord = false;
    _wordsSubmittedToday.add(word);
    _lastCompletedMatchDay ??= _initializedDateTime;
    await _userDataReference
        .update({
          _wordsSubmittedTodayField: _wordsSubmittedToday,
          _lastPlayedMatchDateField:
              _dateFormat.format(_lastCompletedMatchDay!),
        })
        .then((_) => didSubmitWord = true)
        .onError((_, __) => didSubmitWord = false);

    if (!didSubmitWord) {
      _wordsSubmittedToday.remove(word);
    }
    return didSubmitWord;
  }

  @override
  Iterable<MapEntry<String, int>> get rankingsCount => _rankingsCount.entries;
  final Map<String, int> _rankingsCount;

  @override
  final String lettersOfTheDay;

  @override
  Iterable<String> get wordsSubmittedToday => _wordsSubmittedToday;
  final List<String> _wordsSubmittedToday;

  final String _userId;

  DateTime? _lastCompletedMatchDay;

  final DateTime _initializedDateTime;

  static int _getIntegerStatistic(Map userData, String field) {
    return userData.containsKey(field)
        ? int.parse(userData[field].toString())
        : 0;
  }

  DatabaseReference get _userDataReference => FirebaseDatabase.instance
      .ref()
      .child(_spellingBeeRootField)
      .child(_userDataField)
      .child(_userId);

  bool _doesWordListContainWord(Iterable<String> wordList, String word) {
    return wordList
        .any((element) => element.toLowerCase() == word.toLowerCase());
  }

  static Future<String> _getLettersOfTheDay(
      DateTime initializedDateTime) async {
    final daysDifference = initializedDateTime.difference(_firstDay).inDays;

    var lettersOfTheDayDbRef = FirebaseDatabase.instance
        .ref()
        .child(_spellingBeeRootField)
        .child(_lettersOfTheDayField)
        .child(daysDifference.toString());
    var lettersOfTheDayDoc = await lettersOfTheDayDbRef.get();

    return lettersOfTheDayDoc.value as String;
  }

  static int _getNumberOfDaysInBetween(DateTime dateTime1, DateTime dateTime2) {
    var day1 = DateTime(dateTime1.year, dateTime1.month, dateTime1.day);
    var day2 = DateTime(dateTime2.year, dateTime2.month, dateTime2.day);
    return day1.difference(day2).inDays;
  }

  StatsRepository._(
      {required Map<String, int> rankingsCount,
      required this.numberOfGamesPlayed,
      required this.numberOfWordsSubmitted,
      required this.numberOfPangrams,
      required this.lettersOfTheDay,
      required List<String> wordsSubmittedToday,
      required String userId,
      required DateTime? lastCompletedMatchDay,
      required DateTime initializedDateTime})
      : _rankingsCount = rankingsCount,
        _wordsSubmittedToday = wordsSubmittedToday,
        _userId = userId,
        _lastCompletedMatchDay = lastCompletedMatchDay,
        _initializedDateTime = initializedDateTime;
}
