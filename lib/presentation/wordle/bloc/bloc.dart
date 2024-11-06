import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/wordle/models/extensions.dart';
import 'package:gameboy/data/wordle/models/game_engine_driver.dart';
import 'package:gameboy/data/wordle/models/stat_modifier.dart';
import 'package:gameboy/data/wordle/models/stats.dart';

import 'events.dart';
import 'states.dart';

class _LoadGame extends WordleEvent {
  final String userId;
  _LoadGame(this.userId);
}

class WordleGameBloc extends Bloc<WordleEvent, WordleState> {
  GameEngineDriver? gameEngineDriver;
  static StatModifier? statsInstance;

  WordleGameBloc(String userId) : super(GameLoading()) {
    on<_LoadGame>(_onLoadGame);
    on<SubmitLetter>(_onSubmitLetter);
    add(_LoadGame(userId));
    on<RequestStats>(_onRequestStats);
    on<RemoveLetter>(_onRemoveLetter);
    on<SubmitWord>(_onSubmitWord);
  }

  FutureOr<void> _onLoadGame(_LoadGame event, Emitter<WordleState> emit) async {
    var statsRepository = await Stats.createInstance(event.userId);
    statsInstance = statsRepository;
    gameEngineDriver = await GameEngineDriver.createEngine(
        statsInstance!.lastGuessedWords.toList());

    emit(WordleLoaded(
        wordleStats: statsInstance!, gameEngineData: gameEngineDriver!));
    if (statsInstance!.lastCompletedMatchDay != null &&
        _areOnSameDay(statsInstance!.lastCompletedMatchDay!, DateTime.now())) {
      if (statsInstance!.lastGuessedWords.last
          .isEqualTo(gameEngineDriver!.wordOfTheDay)) {
        emit(GameWon(
            guessedIndex: statsInstance!.lastGuessedWords.length - 1,
            isStartup: true));
        return;
      }
      emit(GameLost(isStartup: true));
    }
  }

  static bool _areOnSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  FutureOr<void> _onSubmitLetter(
      SubmitLetter event, Emitter<WordleState> emit) async {
    var didSubmitLetter = gameEngineDriver!.didSubmitLetter(event.letter);
    if (didSubmitLetter) {
      emit(GuessEdited());
    }
  }

  FutureOr<void> _onRequestStats(
      RequestStats event, Emitter<WordleState> emit) {
    emit(ShowStats());
  }

  FutureOr<void> _onRemoveLetter(
      RemoveLetter event, Emitter<WordleState> emit) {
    var didRemoveLetter = gameEngineDriver!.didRemoveLetter();
    if (didRemoveLetter) {
      emit(GuessEdited());
    }
  }

  FutureOr<void> _onSubmitWord(
      SubmitWord event, Emitter<WordleState> emit) async {
    var canSubmitGuess = gameEngineDriver!.canSubmitWord();
    if (canSubmitGuess) {
      if (!gameEngineDriver!
          .isWordInDictionary(gameEngineDriver!.guessWordUnderEdit!.word)) {
        emit(SubmissionNotInDictionary());
      } else {
        var currentGuessIndex = gameEngineDriver!.guessWordUnderEdit!.index;
        var currentGuessWord = gameEngineDriver!.guessWordUnderEdit!.word;
        var didRegisterGuess = await statsInstance!
            .registerGuess(currentGuessIndex, currentGuessWord);
        if (didRegisterGuess) {
          var shouldMoveToNextGuess = gameEngineDriver!.trySubmitWord();
          if (shouldMoveToNextGuess) {
            emit(GuessWordSubmitted(guessIndex: currentGuessIndex));
          } else {
            if (currentGuessWord.isEqualTo(gameEngineDriver!.wordOfTheDay)) {
              var didRegisterWin = await statsInstance!.registerWin();
              if (didRegisterWin) {
                emit(GameWon(guessedIndex: currentGuessIndex));
              }
            } else {
              var didRegisterLoss = await statsInstance!.registerLoss();
              if (didRegisterLoss) {
                emit(GameLost());
              }
            }
          }
        }
      }
    }
  }
}
