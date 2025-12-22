import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/blocs/game/bloc.dart';
import 'package:gameboy/blocs/game/states.dart';
import 'package:gameboy/blocs/lexBox/events.dart';
import 'package:gameboy/blocs/lexBox/states.dart';
import 'package:gameboy/data/lexBox/implementation/game_engine.dart';
import 'package:gameboy/data/lexBox/implementation/stats.dart';
import 'package:gameboy/data/lexBox/models/game_engine.dart';
import 'package:gameboy/data/lexBox/models/guessed_word_state.dart';
import 'package:gameboy/data/lexBox/models/stats.dart';

class LexBoxBloc extends GameBloc<LexBoxEvent, LexBoxState, LexBoxStatsModifier,
    LexBoxGameEngineDriver> {
  LexBoxBloc(String userId) : super(userId: userId) {
    on<SubmitWord>(_onSubmitWord);
    on<EraseLastWord>(_onEraseLastWord);
  }

  @override
  Future<LexBoxStatsModifier> statisticsCreator() async {
    return await LexBoxStatsRepo.createRepository(userId);
  }

  @override
  Future<LexBoxGameEngineDriver> gameEngineCreator(
      LexBoxStatsModifier stats) async {
    return await LexBoxGameEngineImpl.createEngine(
        stats.wordsSubmittedToday.toList(), stats.lettersOfTheDay);
  }

  @override
  FutureOr<LexBoxState?> getGameStateOnStartup() {
    if (gameEngine.isWon) {
      return LexBoxWinOnStartup();
    }
    return null;
  }

  FutureOr<void> _onSubmitWord(
      SubmitWord event, Emitter<GameState> emit) async {
    var currentWordCount = gameEngine.currentWordCount;
    var guessedWordState = await gameEngine.trySubmitWord(event.word);
    if (guessedWordState == LexBoxGuessedWordState.valid ||
        guessedWordState == LexBoxGuessedWordState.win) {
      await stats.trySubmitWord(event.word);
      var newWordCount = gameEngine.currentWordCount;
      emit(
          GuessWordAccepted(guessedWordState, newWordCount - currentWordCount));
      return;
    }
    emit(GuessedWordResult(guessedWordState));
  }

  FutureOr<void> _onEraseLastWord(
      EraseLastWord event, Emitter<GameState> emit) async {
    var didWinAlready = gameEngine.isWon;
    if (!didWinAlready) {
      final erasedWord = gameEngine.eraseLastWord();
      if (erasedWord != null) {
        await stats.eraseLastWord();
        emit(WordErased(erasedWord));
      }
    }
  }
}
