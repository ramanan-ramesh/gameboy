import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:gameboy/data/wordle/constants.dart';
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
      List<String> attemptedGuesses) async {
    var referenceDateTime = DateTime.now();
    var wordOfTheDay = await _getWordOfTheDay(referenceDateTime);
    var allowedGuesses = await _getAllowedGuesses();

    var allGuessedLetters = <GuessLetter>[];
    for (var attemptedGuess in attemptedGuesses) {
      var guessWord = _createGuessWord(attemptedGuess, wordOfTheDay, 0);
      allGuessedLetters.addAll(guessWord.guessLetters.cast<GuessLetter>());
    }

    GuessWord? guessWordUnderEdit;
    if (attemptedGuesses.isEmpty) {
      guessWordUnderEdit = GuessWord(
          index: 1,
          guessLetters: List<GuessLetter?>.generate(5, (index) => null));
    } else {
      var lastGuess = attemptedGuesses.last;
      if (lastGuess != wordOfTheDay && attemptedGuesses.length <= 5) {
        guessWordUnderEdit =
            _createGuessWord(lastGuess, wordOfTheDay, attemptedGuesses.length);
      }
    }

    return GameEngine._(attemptedGuesses, wordOfTheDay, allowedGuesses,
        allGuessedLetters, guessWordUnderEdit);
  }

  GameEngine._(this._attemptedGuesses, this.wordOfTheDay, this._allowedGuesses,
      this._allGuessedLetters, this.guessWordUnderEdit);

  @override
  bool isWordInDictionary(String guess) {
    return _allowedGuesses.contains(guess.toLowerCase());
  }

  @override
  String wordOfTheDay;

  @override
  Iterable<GuessLetter> get allGuessedLetters => _allGuessedLetters;
  final List<GuessLetter> _allGuessedLetters;

  @override
  GuessWord? guessWordUnderEdit;

  @override
  GuessWord getAttemptedGuessWord(int guessIndex) {
    if (guessIndex < 1 || guessIndex > WordleConstants.numberOfGuesses) {
      throw Exception('Invalid guess index');
    } else {
      if (guessIndex <= _attemptedGuesses.length) {
        var attemptedGuess = _attemptedGuesses[guessIndex - 1];
        return _createGuessWord(attemptedGuess, wordOfTheDay, guessIndex);
      } else {
        return GuessWord(
            index: guessIndex,
            guessLetters: List<GuessLetter?>.generate(
                WordleConstants.numberOfLettersInGuess, (index) => null));
      }
    }
  }

  @override
  bool didRemoveLetter() {
    if (guessWordUnderEdit != null) {
      var indexOfEmptyGuessLetter =
          guessWordUnderEdit!.guessLetters.indexOf(null);
      if (indexOfEmptyGuessLetter == 0 &&
          guessWordUnderEdit!.guessLetters[0] == null) {
        return false;
      }
      var indexOfGuessLetterToRemove = indexOfEmptyGuessLetter == -1
          ? guessWordUnderEdit!.guessLetters.length - 1
          : indexOfEmptyGuessLetter - 1;
      guessWordUnderEdit!.guessLetters[indexOfGuessLetterToRemove] = null;
      return true;
    } else {
      return false;
    }
  }

  @override
  bool didSubmitLetter(String letter) {
    if (didCompleteGame() || guessWordUnderEdit == null || canSubmitWord()) {
      return false;
    }
    var indexOfEmptyGuessLetter =
        guessWordUnderEdit!.guessLetters.indexOf(null) + 1;
    guessWordUnderEdit!.guessLetters[indexOfEmptyGuessLetter - 1] =
        GuessLetter(guessLetter: letter, letterMatchDescription: null);
    return true;
  }

  @override
  bool canSubmitWord() {
    if (guessWordUnderEdit == null || didCompleteGame()) {
      return false;
    }
    if (guessWordUnderEdit!.guessLetters.any((e) => e == null)) {
      return false;
    }
    return true;
  }

  @override
  bool trySubmitWord() {
    if (!didCompleteGame() && canSubmitWord()) {
      var guessedWord = guessWordUnderEdit!.word;
      _attemptedGuesses.add(guessedWord);
      if (guessedWord == wordOfTheDay) {
        guessWordUnderEdit = null;
      }
      if (_attemptedGuesses.length == WordleConstants.numberOfGuesses) {
        guessWordUnderEdit = null;
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
    var didWinGame = lastAttemptedGuess == wordOfTheDay;
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
    var guessLetters = <GuessLetter?>[];
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
    return GuessWord(index: guessIndex, guessLetters: guessLetters);
  }
}
