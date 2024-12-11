import 'package:gameboy/data/alphaBound/implementation/game_engine.dart';
import 'package:gameboy/data/alphaBound/models/game_engine.dart';
import 'package:gameboy/data/alphaBound/models/game_state.dart';

abstract class GameEngineDriver extends GameEngineData {
  GameState trySubmitGuess(String guess);

  static Future<GameEngineDriver> createInstance(
      String? lowerBoundGuess,
      String? upperBoundGuess,
      int numberOfWordsGuessed,
      String? middleGuessWord) async {
    return await AlphaBoundGameEngine.create(lowerBoundGuess, upperBoundGuess,
        numberOfWordsGuessed, middleGuessWord);
  }
}
