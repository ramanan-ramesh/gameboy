import 'package:firebase_database/firebase_database.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:gameboy/data/spelling_bee/implementation/game_engine.dart';
import 'package:gameboy/data/spelling_bee/models/constants.dart';
import 'package:gameboy/data/spelling_bee/models/stats_modifier.dart';
import 'package:intl/intl.dart';

class StatsRepository extends StatsModifier {
  static const _spellingBeeRootField = 'spelling-bee';
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
    return StatsRepository._(
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
        var rank = GameEngine.rankCalculator(wordsSubmittedToday);
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
              SpellingBeeConstants.numberOfLetters) {
            numberOfPangrams++;
          }
        }
        await _userDataReference.update({
          _rankingsCountField: rankingsCount,
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
  Future<bool> trySubmitWord(String word) async {
    if (_doesWordListContainWord(wordsSubmittedToday, word)) {
      return false;
    }
    var didSubmitWord = false;
    var shouldUpdateLongestGuess =
        word.length > (_longestGuessedWord?.length ?? 0);
    var isPangram =
        word.split('').toSet().length == SpellingBeeConstants.numberOfLetters;
    await _userDataReference.update({
      _wordsSubmittedTodayField: wordsSubmittedToday,
      _lastPlayedMatchDateField: _dateFormat.format(initializedDateTime),
      if (shouldUpdateLongestGuess) _longestSubmittedWordField: word,
      _numberOfWordsSubmittedField: numberOfWordsSubmitted + 1,
      if (isPangram) _numberOfPangramsField: numberOfPangrams + 1,
    }).then((_) {
      didSubmitWord = true;
      numberOfWordsSubmitted++;
      wordsSubmittedToday.add(word);
      _lastCompletedMatchDay ??= initializedDateTime;
      if (shouldUpdateLongestGuess) {
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

  StatsRepository._(
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
