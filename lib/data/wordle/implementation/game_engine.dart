import 'package:flutter/services.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:gameboy/data/wordle/constants.dart';
import 'package:gameboy/data/wordle/models/game_engine_driver.dart';
import 'package:gameboy/data/wordle/models/guess_letter.dart';
import 'package:gameboy/data/wordle/models/guess_word.dart';
import 'package:gameboy/data/wordle/models/letter_match_description.dart';

class WordleGameEngineImpl extends WordleGameEngineDriver {
  static const _pathToDictionary = 'assets/fiveLetterWordDictionary.txt';
  final List<String> _allowedGuesses;
  final List<String> _attemptedGuesses;

  static Future<WordleGameEngineDriver> createEngine(
      List<String> attemptedGuessesToday, String wordOfTheDay) async {
    var allowedGuesses = await _getAllowedGuesses();

    var allGuessedLetters = <String, LetterMatchDescription>{};
    for (var attemptedGuess in attemptedGuessesToday) {
      var guessWord = _createGuessWord(attemptedGuess, wordOfTheDay, 0);
      _updateGuessedLetters(guessWord, allGuessedLetters);
    }

    GuessWord? guessWordUnderEdit;
    if (attemptedGuessesToday.isEmpty) {
      guessWordUnderEdit = GuessWord.empty(index: 0);
    } else {
      var lastGuess = attemptedGuessesToday.last;
      if (!lastGuess.isEqualTo(wordOfTheDay) &&
          attemptedGuessesToday.length < WordleConstants.numberOfGuesses) {
        guessWordUnderEdit =
            GuessWord.empty(index: attemptedGuessesToday.length);
      }
    }

    return WordleGameEngineImpl._(attemptedGuessesToday, wordOfTheDay,
        allowedGuesses, allGuessedLetters, guessWordUnderEdit);
  }

  @override
  bool isWordInDictionary(String guess) {
    return _allowedGuesses.any((element) => element.isEqualTo(guess));
  }

  @override
  String wordOfTheDay;

  @override
  Iterable<GuessLetter> get allGuessedLetters =>
      _allGuessedLetters.entries.map((entry) => GuessLetter(
          guessLetter: entry.key, letterMatchDescription: entry.value));
  final Map<String, LetterMatchDescription> _allGuessedLetters;

  @override
  GuessWord? get guessWordUnderEdit => _guessWordUnderEdit?.clone();
  GuessWord? _guessWordUnderEdit;

  @override
  GuessWord getAttemptedGuessWord(int guessIndex) {
    if (guessIndex < 0 || guessIndex >= WordleConstants.numberOfGuesses) {
      throw Exception('Invalid guess index');
    } else {
      if (guessIndex < _attemptedGuesses.length) {
        var attemptedGuess = _attemptedGuesses[guessIndex];
        return _createGuessWord(attemptedGuess, wordOfTheDay, guessIndex);
      } else {
        return GuessWord.empty(index: guessIndex);
      }
    }
  }

  @override
  bool didRemoveLetter() {
    if (_didCompleteGame() || _guessWordUnderEdit == null) {
      return false;
    }
    var indexOfGuessLetterToRemove = _guessWordUnderEdit!.word.length - 1;
    if (indexOfGuessLetterToRemove >= 0) {
      _guessWordUnderEdit!.guessLetters[indexOfGuessLetterToRemove] =
          GuessLetter.notYetGuessed();
      return true;
    }
    return false;
  }

  @override
  bool didSubmitLetter(String letter) {
    if (_didCompleteGame() || _guessWordUnderEdit == null || canSubmitWord()) {
      return false;
    }
    var lengthOfGuessWordUnderEdit = _guessWordUnderEdit!.word.length;
    _guessWordUnderEdit!.guessLetters[lengthOfGuessWordUnderEdit] = GuessLetter(
        guessLetter: letter,
        letterMatchDescription: LetterMatchDescription.notYetMatched);
    return true;
  }

  @override
  bool canSubmitWord() {
    if (_guessWordUnderEdit == null || _didCompleteGame()) {
      return false;
    }
    var lengthOfGuessWordUnderEdit = _guessWordUnderEdit!.word.length;
    return lengthOfGuessWordUnderEdit == WordleConstants.numberOfLettersInGuess;
  }

  @override
  bool trySubmitWord() {
    if (_didCompleteGame() || !canSubmitWord() || _guessWordUnderEdit == null) {
      return false;
    }
    var guessedWord = _guessWordUnderEdit!.word;
    _attemptedGuesses.add(guessedWord);
    _updateGuessedLetters(
        getAttemptedGuessWord(_guessWordUnderEdit!.index), _allGuessedLetters);
    if (guessedWord.isEqualTo(wordOfTheDay)) {
      _guessWordUnderEdit = null;
    } else if (_attemptedGuesses.length == WordleConstants.numberOfGuesses) {
      _guessWordUnderEdit = null;
    } else {
      _guessWordUnderEdit =
          getAttemptedGuessWord(_guessWordUnderEdit!.index + 1);
    }
    return true;
  }

  bool _didCompleteGame() {
    if (_attemptedGuesses.isEmpty) {
      return false;
    }
    var lastAttemptedGuess = _attemptedGuesses.last;
    var didWinGame = lastAttemptedGuess.isEqualTo(wordOfTheDay);
    if (didWinGame) {
      return true;
    }

    return _attemptedGuesses.length == WordleConstants.numberOfGuesses;
  }

  static Future<List<String>> _getAllowedGuesses() async {
    final String fileContent = await rootBundle.loadString(_pathToDictionary);
    return fileContent.split('\r\n');
  }

  static GuessWord _createGuessWord(
      String submittedWord, String wordOfTheDay, int guessIndex) {
    var guessLetters = <GuessLetter>[];
    for (var i = 0; i < submittedWord.length; i++) {
      final letter = submittedWord[i];
      LetterMatchDescription letterMatchDescription;
      if (wordOfTheDay.doesContain(letter)) {
        if (wordOfTheDay[i].isEqualTo(letter)) {
          letterMatchDescription = LetterMatchDescription.rightPositionInWord;
        } else {
          letterMatchDescription = LetterMatchDescription.wrongPositionInWord;
        }
      } else {
        letterMatchDescription = LetterMatchDescription.notInWord;
      }
      guessLetters.add(GuessLetter(
          guessLetter: letter, letterMatchDescription: letterMatchDescription));
    }
    for (var i = submittedWord.length;
        i < WordleConstants.numberOfLettersInGuess;
        i++) {
      guessLetters.add(GuessLetter.notYetGuessed());
    }
    return GuessWord(index: guessIndex, guessLetters: guessLetters);
  }

  static void _updateGuessedLetters(GuessWord guessWord,
      Map<String, LetterMatchDescription> allGuessedLetters) {
    for (var guessedWordLetter in guessWord.guessLetters) {
      var matchingKey = allGuessedLetters.keys
          .where((e) => e.isEqualTo(guessedWordLetter.guessLetter))
          .firstOrNull;
      if (matchingKey != null &&
          allGuessedLetters[matchingKey] ==
              LetterMatchDescription.rightPositionInWord) {
        continue;
      }
      allGuessedLetters[guessedWordLetter.guessLetter] =
          guessedWordLetter.letterMatchDescription;
    }
  }

  WordleGameEngineImpl._(
      this._attemptedGuesses,
      this.wordOfTheDay,
      this._allowedGuesses,
      this._allGuessedLetters,
      GuessWord? guessWordUnderEdit)
      : _guessWordUnderEdit = guessWordUnderEdit;
}
