import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:gameboy/data/wordle/constants.dart';
import 'package:gameboy/data/wordle/models/extensions.dart';
import 'package:gameboy/data/wordle/models/game_engine_driver.dart';
import 'package:gameboy/data/wordle/models/guess_letter.dart';
import 'package:gameboy/data/wordle/models/guess_word.dart';
import 'package:gameboy/data/wordle/models/letter_match_description.dart';

class GameEngine extends GameEngineDriver {
  static const _pathToWordleAnswers = 'assets/game_data/wordle_answers.txt';
  static const _pathToDictionary = 'assets/game_data/5-letter-words.json';

  static final _firstDay = DateTime(2021, 10, 12);
  List<String> _allowedGuesses;
  List<String> _attemptedGuesses;

  static Future<GameEngineDriver> createEngine(
      List<String> attemptedGuessesToday) async {
    var referenceDateTime = DateTime.now();
    var wordOfTheDay = await _getWordOfTheDay(referenceDateTime);
    var allowedGuesses = await _getAllowedGuesses();

    var allGuessedLetters = <String, LetterMatchDescription>{};
    for (var attemptedGuess in attemptedGuessesToday) {
      var guessWord = _createGuessWord(attemptedGuess, wordOfTheDay, 0);
      _tryUpdateGuessedLetters(guessWord, allGuessedLetters);
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

    return GameEngine._(attemptedGuessesToday, wordOfTheDay, allowedGuesses,
        allGuessedLetters, guessWordUnderEdit);
  }

  @override
  bool isWordInDictionary(String guess) {
    return true;
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
  GuessWord? guessWordUnderEdit;

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
    if (!didCompleteGame() && guessWordUnderEdit != null) {
      var lengthOfGuessWordUnderEdit = guessWordUnderEdit!.word.length;
      if (lengthOfGuessWordUnderEdit == 0) {
        return false;
      }
      var indexOfGuessLetterToRemove = lengthOfGuessWordUnderEdit - 1;
      guessWordUnderEdit!.guessLetters[indexOfGuessLetterToRemove] =
          GuessLetter.notYetGuessed();
      return true;
    }
    return false;
  }

  @override
  bool didSubmitLetter(String letter) {
    if (didCompleteGame() || guessWordUnderEdit == null || canSubmitWord()) {
      return false;
    }
    var lengthOfGuessWordUnderEdit = guessWordUnderEdit!.word.length;
    if (lengthOfGuessWordUnderEdit == WordleConstants.numberOfLettersInGuess) {
      return false;
    }
    guessWordUnderEdit!.guessLetters[lengthOfGuessWordUnderEdit] = GuessLetter(
        guessLetter: letter,
        letterMatchDescription: LetterMatchDescription.notYetMatched);
    return true;
  }

  @override
  bool canSubmitWord() {
    if (guessWordUnderEdit == null || didCompleteGame()) {
      return false;
    }
    var lengthOfGuessWordUnderEdit = guessWordUnderEdit!.word.length;
    return lengthOfGuessWordUnderEdit == WordleConstants.numberOfLettersInGuess;
  }

  @override
  bool trySubmitWord() {
    if (!didCompleteGame() && canSubmitWord() && guessWordUnderEdit != null) {
      var guessedWord = guessWordUnderEdit!.word;
      _attemptedGuesses.add(guessedWord);
      _tryUpdateGuessedLetters(
          getAttemptedGuessWord(guessWordUnderEdit!.index), _allGuessedLetters);
      if (guessedWord.isEqualTo(wordOfTheDay)) {
        guessWordUnderEdit = null;
        return false;
      }
      if (_attemptedGuesses.length == WordleConstants.numberOfGuesses) {
        guessWordUnderEdit = null;
        return false;
      }
      guessWordUnderEdit = getAttemptedGuessWord(guessWordUnderEdit!.index + 1);
      return true;
    }
    return false;
  }

  @override
  bool didCompleteGame() {
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

  static Future<String> _getWordOfTheDay(DateTime today) async {
    final wordFile = await rootBundle.loadString(_pathToWordleAnswers);
    var wordList = wordFile.split('\n').map((word) => word.trim()).toList();

    final daysDifference = today.difference(_firstDay).inDays;

    return wordList[daysDifference % wordList.length];
  }

  static Future<List<String>> _getAllowedGuesses() async {
    final String jsonString = await rootBundle.loadString(_pathToDictionary);
    final List<dynamic> jsonResponse = jsonDecode(jsonString);
    return jsonResponse.cast<String>();
  }

  static GuessWord _createGuessWord(
      String submittedWord, String wordOfTheDay, int guessIndex) {
    var guessLetters = <GuessLetter>[];
    for (var i = 0; i < submittedWord.length; i++) {
      final letter = submittedWord[i].toLowerCase();
      LetterMatchDescription letterMatchDescription;
      if (wordOfTheDay.contains(letter)) {
        if (wordOfTheDay[i] == letter) {
          letterMatchDescription = LetterMatchDescription.inWordRightPosition;
        } else {
          letterMatchDescription = LetterMatchDescription.inWordWrongPosition;
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

  static void _tryUpdateGuessedLetters(GuessWord guessWord,
      Map<String, LetterMatchDescription> allGuessedLetters) {
    for (var guessedWordLetter in guessWord.guessLetters) {
      var matchingKey = allGuessedLetters.keys
          .where((e) => e.isEqualTo(guessedWordLetter.guessLetter))
          .firstOrNull;
      if (matchingKey != null &&
          allGuessedLetters[matchingKey] ==
              LetterMatchDescription.inWordRightPosition) {
        continue;
      }
      allGuessedLetters[guessedWordLetter.guessLetter] =
          guessedWordLetter.letterMatchDescription;
    }
  }

  GameEngine._(this._attemptedGuesses, this.wordOfTheDay, this._allowedGuesses,
      this._allGuessedLetters, this.guessWordUnderEdit);
}
