import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/wordle/constants.dart';
import 'package:gameboy/data/wordle/models/extensions.dart';
import 'package:gameboy/data/wordle/models/game_engine_driver.dart';
import 'package:gameboy/data/wordle/models/stat_modifier.dart';
import 'package:gameboy/data/wordle/models/stats.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_state.dart';

import 'events.dart';
import 'states.dart';

class WordleGameBloc extends GameBloc<WordleEvent, WordleState,
    WordleStatModifier, GameEngineDriver> {
  WordleGameBloc(String userId) : super(userId: userId) {
    on<SubmitLetter>(_onSubmitLetter);
    on<RemoveLetter>(_onRemoveLetter);
    on<SubmitWord>(_onSubmitWord);
  }

  @override
  Future<WordleStatModifier> statisticsCreator() async {
    return await WordleStats.createInstance(userId);
  }

  @override
  Future<GameEngineDriver> gameEngineCreator(WordleStatModifier stats) async {
    return await GameEngineDriver.createEngine(
        stats.lastGuessedWords.toList(), stats.wordOfTheDay);
  }

  @override
  FutureOr<WordleState?> createGameResultOnStartup() {
    if (stats.lastGuessedWords.isEmpty) {
      return null;
    }
    if (stats.lastGuessedWords.last.isEqualTo(gameEngine.wordOfTheDay)) {
      return GameWon(
          guessedIndex: stats.lastGuessedWords.length - 1, isStartup: true);
    } else if (stats.lastGuessedWords.length ==
        WordleConstants.numberOfGuesses) {
      return GameLost(isStartup: true);
    }

    return null;
  }

  FutureOr<void> _onSubmitLetter(
      SubmitLetter event, Emitter<GameState> emit) async {
    var didSubmitLetter = gameEngine.didSubmitLetter(event.letter);
    if (didSubmitLetter) {
      emit(GuessEdited());
    }
  }

  FutureOr<void> _onRemoveLetter(RemoveLetter event, Emitter<GameState> emit) {
    var didRemoveLetter = gameEngine.didRemoveLetter();
    if (didRemoveLetter) {
      emit(GuessEdited());
    }
  }

  FutureOr<void> _onSubmitWord(
      SubmitWord event, Emitter<GameState> emit) async {
    var canSubmitGuess = gameEngine.canSubmitWord();
    if (canSubmitGuess) {
      if (!gameEngine.isWordInDictionary(gameEngine.guessWordUnderEdit!.word)) {
        emit(SubmissionNotInDictionary());
      } else {
        var currentGuessIndex = gameEngine.guessWordUnderEdit!.index;
        var currentGuessWord = gameEngine.guessWordUnderEdit!.word;
        var didRegisterGuess =
            await stats.registerGuess(currentGuessIndex, currentGuessWord);
        if (didRegisterGuess) {
          var didSubmitWord = gameEngine.trySubmitWord();
          if (didSubmitWord) {
            if (gameEngine.guessWordUnderEdit != null) {
              emit(GuessWordSubmitted(guessIndex: currentGuessIndex));
            } else {
              if (currentGuessWord.isEqualTo(gameEngine.wordOfTheDay)) {
                var didRegisterWin = await stats.registerWin();
                if (didRegisterWin) {
                  emit(GameWon(guessedIndex: currentGuessIndex));
                }
              } else {
                var didRegisterLoss = await stats.registerLoss();
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
}
