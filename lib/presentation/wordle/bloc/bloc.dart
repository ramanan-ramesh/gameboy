import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/wordle/models/extensions.dart';
import 'package:gameboy/data/wordle/models/game_engine_driver.dart';
import 'package:gameboy/data/wordle/models/stat_modifier.dart';
import 'package:gameboy/data/wordle/models/stats.dart';

import 'events.dart';
import 'states.dart';

class _LoadGame extends WordleEvent {
  String userId;
  _LoadGame(this.userId);
}

class WordleGameBloc extends Bloc<WordleEvent, WordleState> {
  GameEngineDriver? gameEngineDriver;
  static StatModifier? statsInstance;

  WordleGameBloc(String userId) : super(GameLoading()) {
    on<_LoadGame>(_onLoadGame);
    on<SubmitKey>(_onSubmitKey);
    on<SubmitLetter>(_onSubmitLetter);
    add(_LoadGame(userId));
  }

  FutureOr<void> _onLoadGame(_LoadGame event, Emitter<WordleState> emit) async {
    var statsRepository = await Stats.createInstance(event.userId);
    statsInstance = statsRepository;
    gameEngineDriver = await GameEngineDriver.createEngine(
        statsInstance!.lastGuessedWords.toList());

    emit(WordleLoaded(
        wordleStats: statsInstance!, gameEngineData: gameEngineDriver!));
  }

  FutureOr<void> _onSubmitLetter(
      SubmitLetter event, Emitter<WordleState> emit) async {
    var didSubmitLetter = gameEngineDriver!.didSubmitLetter(event.letter);
    if (didSubmitLetter) {
      emit(GuessEdited());
    }
  }

  FutureOr<void> _onSubmitKey(SubmitKey event, Emitter<WordleState> emit) {
    if (event.key == KeyType.enter) {
      var canSubmitGuess = gameEngineDriver!.canSubmitWord();
      if (canSubmitGuess) {
        if (!gameEngineDriver!
            .isWordInDictionary(gameEngineDriver!.guessWordUnderEdit!.word)) {
          emit(SubmissionNotInDictionary());
        } else {
          var currentGuessIndex = gameEngineDriver!.guessWordUnderEdit!.index;
          var currentGuessWord = gameEngineDriver!.guessWordUnderEdit!.word;
          var shouldMoveToNextGuess = gameEngineDriver!.trySubmitWord();
          if (shouldMoveToNextGuess) {
            var lastGuessedIndex =
                gameEngineDriver!.guessWordUnderEdit!.index - 1;
            emit(GuessWordSubmitted(guessIndex: lastGuessedIndex));
          } else {
            if (currentGuessWord.isEqualTo(gameEngineDriver!.wordOfTheDay)) {
              emit(GameWon(guessedIndex: currentGuessIndex));
            } else {
              emit(GameLost(guessedIndex: currentGuessIndex));
            }
          }
        }
      }
    } else if (event.key == KeyType.backspace) {
      var didRemoveLetter = gameEngineDriver!.didRemoveLetter();
      if (didRemoveLetter) {
        emit(GuessEdited());
      }
    }
  }
}
