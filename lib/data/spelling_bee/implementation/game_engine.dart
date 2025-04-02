import 'package:flutter/services.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:gameboy/data/spelling_bee/models/constants.dart';
import 'package:gameboy/data/spelling_bee/models/game_engine.dart';
import 'package:gameboy/data/spelling_bee/models/guessed_word_state.dart';
import 'package:gameboy/data/spelling_bee/models/score.dart';

class SpellingBeeGameEngineImpl implements SpellingBeeGameEngineDriver {
  static const _allowedGuessesPath =
      'assets/atleastFourLetterWordDictionary.txt';
  final List<String> _allowedGuesses;

  static Future<SpellingBeeGameEngineDriver> createEngine(
      List<String> attemptedGuesses, String lettersOfTheDay) async {
    var allowedGuesses = await _getAllowedGuesses();
    return SpellingBeeGameEngineImpl._(
        attemptedGuesses, lettersOfTheDay, allowedGuesses);
  }

  @override
  List<String> guessedWords;

  @override
  String lettersOfTheDay;

  @override
  Score get currentScore => Score(
      score: _calculateScore(guessedWords), rank: rankCalculator(guessedWords));

  @override
  GuessedWordState trySubmitWord(String word) {
    if (word.length <= 3) {
      return GuessedWordState.tooShort;
    }
    if (!_doesListContainWord(_allowedGuesses, word)) {
      return GuessedWordState.notInDictionary;
    }

    if (_doesListContainWord(guessedWords, word)) {
      return GuessedWordState.alreadyGuessed;
    }

    var uniqueLetters = word.split('').toSet();
    if (uniqueLetters.any((element) => !lettersOfTheDay.doesContain(element))) {
      return GuessedWordState.doesNotContainLettersOfTheDay;
    }

    if (!word.doesContain(lettersOfTheDay[0])) {
      return GuessedWordState.doesNotContainCenterLetter;
    }

    guessedWords.add(word);
    if (uniqueLetters.length == SpellingBeeConstants.numberOfLetters &&
        uniqueLetters.every((uniqueLetter) => word.doesContain(uniqueLetter))) {
      return GuessedWordState.pangram;
    }
    return GuessedWordState.valid;
  }

  static Future<List<String>> _getAllowedGuesses() async {
    final String fileContent = await rootBundle.loadString(_allowedGuessesPath);
    return fileContent.split('\n');
  }

  static bool _doesListContainWord(Iterable<String> allWords, String word) {
    return allWords.any((element) => element.isEqualTo(word));
  }

  static String rankCalculator(Iterable<String> guessedWords) {
    int score = _calculateScore(guessedWords);
    return SpellingBeeConstants.rankCalculator(score);
  }

  static int _calculateScore(Iterable<String> guessedWords) {
    int score = 0;
    for (var word in guessedWords) {
      if (word.length == 4) {
        score += 1;
      } else if (word.split('').toSet().length == 7) {
        score += (word.length + 7);
      } else if (word.length > 4) {
        score += word.length;
      }
    }
    return score;
  }

  SpellingBeeGameEngineImpl._(
      this.guessedWords, this.lettersOfTheDay, this._allowedGuesses);
}
