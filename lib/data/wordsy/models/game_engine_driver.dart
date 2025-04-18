import 'game__engine_data.dart';

abstract class WordsyGameEngineDriver implements WordsyGameEngine {
  bool isWordInDictionary(String guess);

  bool canSubmitWord();

  bool trySubmitWord();

  bool didSubmitLetter(String letter);

  bool didRemoveLetter();
}
