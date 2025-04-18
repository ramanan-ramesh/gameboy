import 'package:firebase_database/firebase_database.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:gameboy/data/beeWise/implementation/game_engine.dart';
import 'package:gameboy/data/beeWise/models/constants.dart';
import 'package:gameboy/data/beeWise/models/stats.dart';
import 'package:intl/intl.dart';

class BeeWiseStatsRepo extends BeeWiseStatsModifier {
  static const _beeWiseRootField = 'beeWise';
  static const _lettersOfTheDayField = 'lettersOfTheDay';
  static const _userDataField = 'userData';
  static const _numberOfGamesPlayedField = 'played';
  static const _numberOfPangramsField = 'pangramCount';
  static const _numberOfWordsSubmittedField = 'guessWordsCount';
  static const _rankingsCountField = 'rankingsCount';
  static const _lastPlayedMatchDateField = 'lastPlayedDate';
  static const _wordsSubmittedTodayField = 'lastGuessedWords';
  static const _longestSubmittedWordField = 'longestWord';
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final _firstDay = DateTime(2025, 3, 17);

  static Future<BeeWiseStatsModifier> createRepository(String userId) async {
    var spellingBeeRootDBRef =
        FirebaseDatabase.instance.ref().child(_beeWiseRootField);
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

    String? longestSubmittedGuess;
    if (userData.containsKey(_longestSubmittedWordField)) {
      longestSubmittedGuess = userData[_longestSubmittedWordField] as String;
    }

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
    return BeeWiseStatsRepo._(
        rankingsCount: rankingsCount,
        numberOfGamesPlayed: numberOfGamesPlayed,
        numberOfWordsSubmitted: numberOfWordsSubmitted,
        numberOfPangrams: numberOfPangrams,
        lettersOfTheDay: lettersOfTheDay,
        wordsSubmittedToday: lastSubmittedWords,
        userId: userId,
        lastCompletedMatchDay: lastPlayedMatchDay,
        initializedDateTime: initializedDateTime,
        longestGuessWord: longestSubmittedGuess);
  }

  @override
  Future reCalculate() async {
    if (_lastCompletedMatchDay != null) {
      final daysDifference =
          initializedDateTime.numberOfDaysInBetween(_lastCompletedMatchDay!);
      if (daysDifference > 0) {
        var rank = BeeWiseGameEngineImpl.rankCalculator(wordsSubmittedToday);
        if (_rankingsCount.containsKey(rank)) {
          _rankingsCount[rank] = _rankingsCount[rank]! + 1;
        } else {
          _rankingsCount[rank] = 1;
        }
        wordsSubmittedToday.clear();
        _lastCompletedMatchDay = null;
        numberOfGamesPlayed++;
        numberOfWordsSubmitted += wordsSubmittedToday.length;
        for (var word in wordsSubmittedToday) {
          if (word.split('').toSet().length ==
              BeeWiseConstants.numberOfLetters) {
            numberOfPangrams++;
          }
        }
        await _userDataReference.update({
          _rankingsCountField: _rankingsCount,
          _lastPlayedMatchDateField: null,
          _wordsSubmittedTodayField: null,
          _numberOfWordsSubmittedField: numberOfWordsSubmitted,
          _numberOfGamesPlayedField: numberOfGamesPlayed,
          _numberOfPangramsField: numberOfPangrams,
        });
      }
    }
  }

  @override
  int numberOfGamesPlayed;

  @override
  int numberOfPangrams;

  @override
  int numberOfWordsSubmitted;

  @override
  Iterable<MapEntry<String, int>> get rankingsCount => _rankingsCount.entries;
  final Map<String, int> _rankingsCount;

  @override
  final String lettersOfTheDay;

  @override
  List<String> wordsSubmittedToday;

  final String _userId;

  DateTime? _lastCompletedMatchDay;

  @override
  final DateTime initializedDateTime;

  @override
  String? get longestSubmittedWord => _longestGuessedWord;
  String? _longestGuessedWord;

  @override
  Future<bool> trySubmitWord(String word) async {
    if (_doesWordListContainWord(wordsSubmittedToday, word)) {
      return false;
    }
    var didSubmitWord = false;
    var isLongestGuess = word.length > (_longestGuessedWord?.length ?? 0);
    var uniqueLettersInWord = word.split('').toSet();
    var isPangram = uniqueLettersInWord.every(
            (uniqueLetter) => lettersOfTheDay.doesContain(uniqueLetter)) &&
        uniqueLettersInWord.length == BeeWiseConstants.numberOfLetters;
    await _userDataReference.update({
      _wordsSubmittedTodayField: wordsSubmittedToday.toList()
        ..add(word.toLowerCase()),
      _lastPlayedMatchDateField: _dateFormat.format(initializedDateTime),
      if (isLongestGuess) _longestSubmittedWordField: word,
      _numberOfWordsSubmittedField: numberOfWordsSubmitted + 1,
      if (isPangram) _numberOfPangramsField: numberOfPangrams + 1,
    }).then((_) {
      didSubmitWord = true;
      numberOfWordsSubmitted++;
      wordsSubmittedToday.add(word.toLowerCase());
      _lastCompletedMatchDay ??= initializedDateTime;
      if (isLongestGuess) {
        _longestGuessedWord = word;
      }
      if (isPangram) {
        numberOfPangrams++;
      }
    }).onError((_, __) {
      didSubmitWord = false;
    });

    return didSubmitWord;
  }

  static int _getIntegerStatistic(Map userData, String field) {
    return userData.containsKey(field)
        ? int.parse(userData[field].toString())
        : 0;
  }

  DatabaseReference get _userDataReference => FirebaseDatabase.instance
      .ref()
      .child(_beeWiseRootField)
      .child(_userDataField)
      .child(_userId);

  bool _doesWordListContainWord(Iterable<String> wordList, String word) {
    return wordList.any((element) => element.isEqualTo(word));
  }

  static Future<String> _getLettersOfTheDay(
      DateTime initializedDateTime) async {
    final daysDifference = initializedDateTime.numberOfDaysInBetween(_firstDay);

    var lettersOfTheDayDbRef = FirebaseDatabase.instance
        .ref()
        .child(_beeWiseRootField)
        .child(_lettersOfTheDayField)
        .child(daysDifference.toString());
    var lettersOfTheDayDoc = await lettersOfTheDayDbRef.get();

    return lettersOfTheDayDoc.value as String;
  }

  BeeWiseStatsRepo._(
      {required Map<String, int> rankingsCount,
      required this.numberOfGamesPlayed,
      required this.numberOfWordsSubmitted,
      required this.numberOfPangrams,
      required this.lettersOfTheDay,
      required this.wordsSubmittedToday,
      required String userId,
      required DateTime? lastCompletedMatchDay,
      required this.initializedDateTime,
      String? longestGuessWord})
      : _rankingsCount = rankingsCount,
        _userId = userId,
        _lastCompletedMatchDay = lastCompletedMatchDay,
        _longestGuessedWord = longestGuessWord;
}
