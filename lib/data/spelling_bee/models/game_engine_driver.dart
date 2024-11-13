import 'package:gameboy/data/spelling_bee/implementation/game_engine.dart';
import 'package:gameboy/data/spelling_bee/models/game_engine.dart';

abstract class GameEngineDriver extends GameEngineData {
  bool trySubmitWord(String word);
  bool isValidWord(String word);

  static Future<GameEngineDriver> createEngine(
      List<String> attemptedGuesses, String lettersOfTheDay) async {
    return await GameEngine.createEngine(attemptedGuesses, lettersOfTheDay);
  }
}
