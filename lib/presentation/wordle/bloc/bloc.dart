import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/wordle/constants.dart';
import 'package:gameboy/data/wordle/models/extensions.dart';
import 'package:gameboy/data/wordle/models/game_engine_driver.dart';
import 'package:gameboy/data/wordle/models/stat_modifier.dart';
import 'package:gameboy/data/wordle/models/stats.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';

import 'events.dart';
import 'states.dart';

class _LoadGame extends WordleEvent {
  final String userId;
  _LoadGame(this.userId);
}

class WordleGameBloc extends GameBloc<WordleEvent, WordleState> {
  late GameEngineDriver? gameEngineDriver;
  static late WordleStatModifier statsInstance;

  WordleGameBloc(String userId) : super(WordleLoading()) {
    on<_LoadGame>(_onLoadGame);
    on<SubmitLetter>(_onSubmitLetter);
    on<RequestStats>(_onRequestStats);
    on<RemoveLetter>(_onRemoveLetter);
    on<SubmitWord>(_onSubmitWord);
    add(_LoadGame(userId));
  }

  FutureOr<void> _onLoadGame(_LoadGame event, Emitter<WordleState> emit) async {
    var statsRepository = await WordleStats.createInstance(event.userId);
    statsInstance = statsRepository;
    gameEngineDriver = await GameEngineDriver.createEngine(
        statsInstance.lastGuessedWords.toList(), statsRepository.wordOfTheDay);
    emit(
        WordleLoaded(statistics: statsInstance, gameEngine: gameEngineDriver!));
    _tryEmitGameResultOnStartup(emit);
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
        var didRegisterGuess = await statsInstance.registerGuess(
            currentGuessIndex, currentGuessWord);
        if (didRegisterGuess) {
          var didSubmitWord = gameEngineDriver!.trySubmitWord();
          if (didSubmitWord) {
            if (gameEngineDriver!.guessWordUnderEdit != null) {
              emit(GuessWordSubmitted(guessIndex: currentGuessIndex));
            } else {
              if (currentGuessWord.isEqualTo(gameEngineDriver!.wordOfTheDay)) {
                var didRegisterWin = await statsInstance.registerWin();
                if (didRegisterWin) {
                  emit(GameWon(guessedIndex: currentGuessIndex));
                }
              } else {
                var didRegisterLoss = await statsInstance.registerLoss();
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

  bool _tryEmitGameResultOnStartup(Emitter<WordleState> emit) {
    if (statsInstance.lastGuessedWords.isEmpty) {
      return false;
    }
    if (statsInstance.lastGuessedWords.last
        .isEqualTo(gameEngineDriver!.wordOfTheDay)) {
      emit(GameWon(
          guessedIndex: statsInstance.lastGuessedWords.length - 1,
          isStartup: true));
      return true;
    } else if (statsInstance.lastGuessedWords.length ==
        WordleConstants.numberOfGuesses) {
      emit(GameLost(isStartup: true));
      return true;
    }

    return false;
  }
}
