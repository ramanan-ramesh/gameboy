import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gameboy/asset_manager/assets.gen.dart';
import 'package:gameboy/data/lexBox/models/game_engine.dart';
import 'package:gameboy/data/lexBox/models/guessed_word_state.dart';

class LexBoxGameEngineImpl implements LexBoxGameEngineDriver {
  final List<String> _threeLetterWords;
  final List<String> _fourPlusWords;

  static Future<LexBoxGameEngineDriver> createEngine(
      List<String> attemptedGuesses, String lettersOfTheDay) async {
    var threeLetterWordsDictionary = await _getThreeLetterWords();
    var fourPlusLetterWordsDictionary = await _getFourPlusWords();
    return LexBoxGameEngineImpl._(attemptedGuesses, lettersOfTheDay,
        threeLetterWordsDictionary, fourPlusLetterWordsDictionary);
  }

  @override
  List<String> guessedWords;

  @override
  String lettersOfTheDay;

  @override
  int get currentWordCount => guessedWords.length;

  @override
  bool get isWon => _isWin(guessedWords);

  @override
  Future<LexBoxGuessedWordState> trySubmitWord(String word) async {
    word = word.toLowerCase();
    if (word.length < 3) {
      return LexBoxGuessedWordState.tooShort;
    }
    if (!await _isInDictionary(word)) {
      return LexBoxGuessedWordState.notInDictionary;
    }
    if (_hasConsecutiveSameSide(word)) {
      return LexBoxGuessedWordState.invalidConsecutiveSameSide;
    }
    if (guessedWords.isNotEmpty &&
        word[0] != guessedWords.last[guessedWords.last.length - 1]) {
      return LexBoxGuessedWordState.mustStartWithPreviousWordLastLetter;
    }
    guessedWords.add(word);
    if (_isWin(guessedWords)) {
      return LexBoxGuessedWordState.win;
    }
    return LexBoxGuessedWordState.valid;
  }

  @override
  String? eraseLastWord() {
    if (guessedWords.isEmpty) return null;
    return guessedWords.removeLast();
  }

  Future<bool> _isInDictionary(String word) async {
    return await compute(_isInDictionaryIsolate,
        _DictionaryCheckArgs(word, _threeLetterWords, _fourPlusWords));
  }

  bool _hasConsecutiveSameSide(String word) {
    for (int i = 0; i < word.length - 1; i++) {
      int pos1 = lettersOfTheDay.toLowerCase().indexOf(word[i].toLowerCase());
      int pos2 =
          lettersOfTheDay.toLowerCase().indexOf(word[i + 1].toLowerCase());

      // Skip if letters not found in lettersOfTheDay
      if (pos1 == -1 || pos2 == -1) continue;

      // Check if both letters are on the same side (0=left, 1=top, 2=right, 3=bottom)
      int side1 = pos1 ~/ 3;
      int side2 = pos2 ~/ 3;

      if (side1 == side2) return true;
    }
    return false;
  }

  bool _isWin(Iterable<String> words) {
    var allLetters = lettersOfTheDay.toLowerCase().split('').toSet();
    var usedLetters = words.expand((w) => w.toLowerCase().split('')).toSet();
    return allLetters.every(usedLetters.contains);
  }

  static Future<List<String>> _getThreeLetterWords() async {
    final String fileContent =
        await rootBundle.loadString(Assets.threeLetterWordDictionary);
    return fileContent.split('\n').map((e) => e.trim().toLowerCase()).toList();
  }

  static Future<List<String>> _getFourPlusWords() async {
    final String fileContent =
        await rootBundle.loadString(Assets.atleastFourLetterWordDictionary);
    return fileContent.split('\n').map((e) => e.trim().toLowerCase()).toList();
  }

  LexBoxGameEngineImpl._(this.guessedWords, this.lettersOfTheDay,
      this._threeLetterWords, this._fourPlusWords);
}

class _DictionaryCheckArgs {
  final String word;
  final List<String> threeLetterWords;
  final List<String> fourPlusWords;

  _DictionaryCheckArgs(this.word, this.threeLetterWords, this.fourPlusWords);
}

bool _isInDictionaryIsolate(_DictionaryCheckArgs message) {
  return message.threeLetterWords.contains(message.word) ||
      message.fourPlusWords.contains(message.word);
}
