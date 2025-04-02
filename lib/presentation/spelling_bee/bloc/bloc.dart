import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/spelling_bee/implementation/game_engine.dart';
import 'package:gameboy/data/spelling_bee/implementation/stats.dart';
import 'package:gameboy/data/spelling_bee/models/game_engine.dart';
import 'package:gameboy/data/spelling_bee/models/guessed_word_state.dart';
import 'package:gameboy/data/spelling_bee/models/stats.dart';
import 'package:gameboy/presentation/app/blocs/game/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game/states.dart';
import 'package:gameboy/presentation/spelling_bee/bloc/events.dart';
import 'package:gameboy/presentation/spelling_bee/bloc/states.dart';

class SpellingBeeBloc extends GameBloc<SpellingBeeEvent, SpellingBeeState,
    SpellingBeeStatsModifier, SpellingBeeGameEngineDriver> {
  SpellingBeeBloc(String userId) : super(userId: userId) {
    on<SubmitWord>(_onSubmitWord);
  }

  @override
  Future<SpellingBeeStatsModifier> statisticsCreator() async {
    return await SpellingBeeStatsRepo.createRepository(userId);
  }

  @override
  Future<SpellingBeeGameEngineDriver> gameEngineCreator(
      SpellingBeeStatsModifier stats) async {
    return await SpellingBeeGameEngineImpl.createEngine(
        stats.wordsSubmittedToday.toList(), stats.lettersOfTheDay);
  }

  @override
  FutureOr<SpellingBeeState?> getGameStateOnStartup() {
    return null;
  }

  FutureOr<void> _onSubmitWord(
      SubmitWord event, Emitter<GameState> emit) async {
    var currentScore = gameEngine.currentScore;
    var guessedWordState = gameEngine.trySubmitWord(event.word);
    if (guessedWordState == GuessedWordState.valid ||
        guessedWordState == GuessedWordState.pangram) {
      await stats.trySubmitWord(event.word);
      var newScore = gameEngine.currentScore;
      emit(GuessWordAccepted(
          guessedWordState, newScore.score - currentScore.score));
      return;
    }
    emit(GuessedWordResult(guessedWordState));
  }
}
