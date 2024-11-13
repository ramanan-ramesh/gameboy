import 'package:flutter/services.dart';
import 'package:gameboy/data/spelling_bee/models/game_engine_driver.dart';
import 'package:gameboy/data/spelling_bee/models/score.dart';

class GameEngine implements GameEngineDriver {
  static const _allowedGuessesPath = 'assets/spelling_bee/word-list.txt';

  static Future<GameEngineDriver> createEngine(
      List<String> attemptedGuesses, String lettersOfTheDay) async {
    var allowedGuesses = await _getAllowedGuesses();
    return GameEngine._(attemptedGuesses, lettersOfTheDay, allowedGuesses);
  }

  static Future<List<String>> _getAllowedGuesses() async {
    final String fileContent = await rootBundle.loadString(_allowedGuessesPath);
    return fileContent.split('\n');
  }

  @override
  Iterable<String> get guessedWords => _guessedWords;
  final List<String> _guessedWords;

  @override
  String get lettersOfTheDay => _lettersOfTheDay;
  final String _lettersOfTheDay;

  final List<String> _allowedGuesses;

  @override
  Score get currentScore => Score(
      score: _calculateScore(_guessedWords),
      rank: rankCalculator(_guessedWords));

  @override
  bool isValidWord(String word) {
    return _doesListContainWord(_allowedGuesses, word);
  }

  @override
  bool trySubmitWord(String word) {
    if (!isValidWord(word)) {
      return false;
    }

    if (_doesListContainWord(_guessedWords, word)) {
      return false;
    }

    var uniqueLetters = word.split('').toSet();
    if (uniqueLetters.any((element) =>
            !_isCharacterPresentInWord(_lettersOfTheDay, element)) ||
        !_isCharacterPresentInWord(_lettersOfTheDay, word[0])) {
      return false;
    }

    _guessedWords.add(word);
    return true;
  }

  bool _isCharacterPresentInWord(String word, String character) {
    return word.toLowerCase().contains(character.toLowerCase());
  }

  bool _doesListContainWord(Iterable<String> allWords, String word) {
    return allWords
        .any((element) => element.toLowerCase() == word.toLowerCase());
  }

  static String rankCalculator(Iterable<String> guessedWords) {
    int score = _calculateScore(guessedWords);
    if (score >= 105) {
      return 'Genius';
    } else if (score >= 75) {
      return 'Amazing';
    } else if (score >= 60) {
      return 'Great';
    } else if (score >= 38) {
      return 'Nice';
    } else if (score >= 23) {
      return 'Solid';
    } else if (score >= 12) {
      return 'Good';
    } else if (score >= 8) {
      return 'Moving Up';
    } else if (score >= 3) {
      return 'Good Start';
    } else {
      return 'Beginner';
    }
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

  GameEngine._(this._guessedWords, this._lettersOfTheDay, this._allowedGuesses);
}
