import 'package:gameboy/data/wordle/implementation/game_engine.dart';

import 'game__engine_data.dart';

abstract class GameEngineDriver implements GameEngineData {
  bool isWordInDictionary(String guess);

  bool canSubmitWord();

  bool trySubmitWord();
  bool didSubmitLetter(String letter);
  bool didRemoveLetter();
  bool didCompleteGame();

  static Future<GameEngineDriver> createEngine(
      List<String> attemptedGuesses, String wordOfTheDay) async {
    return await GameEngine.createEngine(attemptedGuesses, wordOfTheDay);
  }
}
