import 'package:gameboy/data/app/models/game_engine.dart' as appGameEngine;
import 'package:gameboy/data/wordle/implementation/game_engine.dart';

import 'game__engine_data.dart';

abstract class GameEngineDriver extends appGameEngine.GameEngine
    implements GameEngineData {
  bool isWordInDictionary(String guess);

  bool canSubmitWord();

  bool trySubmitWord();
  bool didSubmitLetter(String letter);
  bool didRemoveLetter();

  static Future<GameEngineDriver> createEngine(
      List<String> attemptedGuesses, String wordOfTheDay) async {
    return await GameEngine.createEngine(attemptedGuesses, wordOfTheDay);
  }
}
