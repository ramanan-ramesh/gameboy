import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/presentation/app/blocs/game/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game/events.dart';
import 'package:gameboy/presentation/app/blocs/game/states.dart'
    as appGameState;
import 'package:gameboy/presentation/app/pages/game_content_page/game_layout.dart';
import 'package:gameboy/presentation/wordsy/bloc/states.dart';
import 'package:gameboy/presentation/wordsy/extensions.dart';
import 'package:gameboy/presentation/wordsy/pages/stats_sheet.dart';
import 'package:gameboy/presentation/wordsy/widgets/guesses_layout.dart';
import 'package:gameboy/presentation/wordsy/widgets/keyboard_layout.dart';

class WordsyLayout implements GameLayout {
  @override
  BoxConstraints get constraints => const BoxConstraints(
      minWidth: 400.0, maxWidth: 700.0, minHeight: 500.0, maxHeight: 1000.0);

  @override
  Widget buildGameLayout(
      BuildContext layoutContext, double layoutWidth, double layoutHeight) {
    var initialBlocState = layoutContext.getCurrentWordsyState();
    if (initialBlocState is WordsyState) {
      if (initialBlocState is GameWon && initialBlocState.isStartup) {
        _onGameWon(initialBlocState, layoutContext);
      } else if (initialBlocState is GameLost && initialBlocState.isStartup) {
        _onGameLost(initialBlocState, layoutContext);
      }
    }
    var widthFactor = 0.7;
    if (layoutWidth < 450) {
      widthFactor = 0.9;
    }
    return BlocListener<GameBloc, appGameState.GameState>(
      listener: (BuildContext context, appGameState.GameState state) {
        if (state is GameWon) {
          _onGameWon(state, context);
        } else if (state is GameLost) {
          _onGameLost(state, context);
        }
      },
      child: Column(
        children: [
          Expanded(
            flex: 7,
            child: GuessesLayout(
              widthFactor: widthFactor,
            ),
          ),
          Expanded(
            flex: 3,
            child: KeyboardLayout(),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildStatsSheet(BuildContext context, Game game) {
    return StatsSheet(
      game: game,
    );
  }

  void _onGameWon(GameWon gameWon, BuildContext context) {
    Future.delayed(Duration(seconds: gameWon.isStartup ? 2 : 6), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getWinMessage(gameWon.guessedIndex)),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
    Future.delayed(Duration(seconds: gameWon.isStartup ? 4 : 9), () {
      if (context.mounted) {
        context.addGameEvent(RequestStats());
      }
    });
  }

  void _onGameLost(GameLost gameLost, BuildContext context) {
    var wordOfTheDay = context.getGameEngineData().wordOfTheDay.toUpperCase();
    Future.delayed(Duration(seconds: gameLost.isStartup ? 2 : 6), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You lost! The word was $wordOfTheDay'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });

    Future.delayed(Duration(milliseconds: gameLost.isStartup ? 4000 : 7520),
        () {
      if (context.mounted) {
        context.addGameEvent(RequestStats());
      }
    });
  }

  String _getWinMessage(int indexOfGameWon) {
    if (indexOfGameWon == 0) {
      return 'Genius';
    } else if (indexOfGameWon == 1) {
      return 'Magnificent';
    } else if (indexOfGameWon == 2) {
      return 'Impressive';
    } else if (indexOfGameWon == 3) {
      return 'Splendid';
    } else if (indexOfGameWon == 4) {
      return 'Great';
    }
    return 'Phew!';
  }
}
