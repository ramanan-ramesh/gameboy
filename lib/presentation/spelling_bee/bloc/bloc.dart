import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/spelling_bee/models/game_engine_driver.dart';
import 'package:gameboy/data/spelling_bee/models/stats_modifier.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/spelling_bee/bloc/events.dart';
import 'package:gameboy/presentation/spelling_bee/bloc/states.dart';

class _LoadGame extends SpellingBeeEvent {
  final String userId;
  _LoadGame(this.userId);
}

class SpellingBeeBloc extends GameBloc<SpellingBeeEvent, SpellingBeeState> {
  GameEngineDriver? gameEngineDriver;
  static StatsModifier? statsInstance;

  SpellingBeeBloc(String userId) : super(SpellingBeeLoading()) {
    on<SubmitWord>(_onSubmitWord);
    on<_LoadGame>(_onLoadGame);
    add(_LoadGame(userId));
  }

  FutureOr<void> _onSubmitWord(
      SubmitWord event, Emitter<SpellingBeeState> emit) async {
    var isValidWord = gameEngineDriver!.isValidWord(event.word);
    if (!isValidWord) {
      emit(WordNotInDictionary());
      return;
    }

    if (gameEngineDriver!.guessedWords
        .any((e) => e.toLowerCase() == event.word.toLowerCase())) {
      emit(WordAlreadyGuessed());
      return;
    }

    var didSubmitWord = await statsInstance!.trySubmitWord(event.word);
    if (didSubmitWord) {
      var didGuessWord = gameEngineDriver!.trySubmitWord(event.word);
      if (didGuessWord) {
        emit(WordGuessed());
      }
    }
  }

  FutureOr<void> _onLoadGame(
      _LoadGame event, Emitter<SpellingBeeState> emit) async {
    var statsRepository = await StatsModifier.createInstance(event.userId);
    statsInstance = statsRepository;
    gameEngineDriver = await GameEngineDriver.createEngine(
        statsInstance!.wordsSubmittedToday.toList(),
        statsRepository.lettersOfTheDay);

    emit(SpellingBeeLoaded(
        statistics: statsInstance!, gameEngine: gameEngineDriver!));
  }
}
