import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/spelling_bee/models/game_engine_driver.dart';
import 'package:gameboy/data/spelling_bee/models/guessed_word_state.dart';
import 'package:gameboy/data/spelling_bee/models/stats_modifier.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_state.dart';
import 'package:gameboy/presentation/spelling_bee/bloc/events.dart';
import 'package:gameboy/presentation/spelling_bee/bloc/states.dart';

class SpellingBeeBloc extends GameBloc<SpellingBeeEvent, SpellingBeeState,
    StatsModifier, GameEngineDriver> {
  SpellingBeeBloc(String userId) : super(userId: userId) {
    on<SubmitWord>(_onSubmitWord);
  }

  @override
  Future<StatsModifier> statisticsCreator() async {
    return await StatsModifier.createInstance(userId);
  }

  @override
  Future<GameEngineDriver> gameEngineCreator(StatsModifier stats) async {
    return await GameEngineDriver.createEngine(
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
    if (guessedWordState == GuessedWordState.valid) {
      await stats.trySubmitWord(event.word);
      var newScore = gameEngine.currentScore;
      emit(GuessWordAccepted(
          GuessedWordState.valid, newScore.score - currentScore.score));
      return;
    }
    emit(GuessedWordResult(guessedWordState));
  }
}
