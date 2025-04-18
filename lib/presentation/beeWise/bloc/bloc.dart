import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/beeWise/implementation/game_engine.dart';
import 'package:gameboy/data/beeWise/implementation/stats.dart';
import 'package:gameboy/data/beeWise/models/game_engine.dart';
import 'package:gameboy/data/beeWise/models/guessed_word_state.dart';
import 'package:gameboy/data/beeWise/models/stats.dart';
import 'package:gameboy/presentation/app/blocs/game/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game/states.dart';
import 'package:gameboy/presentation/beeWise/bloc/events.dart';
import 'package:gameboy/presentation/beeWise/bloc/states.dart';

class BeeWiseBloc extends GameBloc<BeeWiseEvent, BeeWiseState,
    BeeWiseStatsModifier, BeeWiseGameEngineDriver> {
  BeeWiseBloc(String userId) : super(userId: userId) {
    on<SubmitWord>(_onSubmitWord);
  }

  @override
  Future<BeeWiseStatsModifier> statisticsCreator() async {
    return await BeeWiseStatsRepo.createRepository(userId);
  }

  @override
  Future<BeeWiseGameEngineDriver> gameEngineCreator(
      BeeWiseStatsModifier stats) async {
    return await BeeWiseGameEngineImpl.createEngine(
        stats.wordsSubmittedToday.toList(), stats.lettersOfTheDay);
  }

  @override
  FutureOr<BeeWiseState?> getGameStateOnStartup() {
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
