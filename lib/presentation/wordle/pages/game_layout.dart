import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_state.dart';
import 'package:gameboy/presentation/app/pages/game_content_page/game_layout.dart';
import 'package:gameboy/presentation/wordle/bloc/events.dart';
import 'package:gameboy/presentation/wordle/bloc/states.dart';
import 'package:gameboy/presentation/wordle/extensions.dart';
import 'package:gameboy/presentation/wordle/widgets/guesses_layout.dart';
import 'package:gameboy/presentation/wordle/widgets/keyboard_layout.dart';
import 'package:gameboy/presentation/wordle/widgets/stats_sheet.dart';

class WordleLayout implements GameLayout {
  @override
  BoxConstraints get constraints => const BoxConstraints(
      minWidth: 400.0, maxWidth: 700.0, minHeight: 500.0, maxHeight: 1000.0);

  @override
  Widget buildActionButtonBar(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.addGameEvent(RequestStats());
      },
      icon: Icon(Icons.query_stats_rounded),
    );
  }

  @override
  Widget buildGameLayout(
      BuildContext widgetContext, double layoutWidth, double layoutHeight) {
    var initialBlocState = widgetContext.getCurrentWordleState();
    if (initialBlocState is GameWon && initialBlocState.isStartup) {
      _onGameWon(initialBlocState, widgetContext);
    } else if (initialBlocState is GameLost && initialBlocState.isStartup) {
      _onGameLost(initialBlocState, widgetContext);
    }
    return BlocListener<GameBloc, GameState>(
      listener: (BuildContext context, GameState state) {
        if (state is GameWon) {
          _onGameWon(state, context);
        } else if (state is GameLost) {
          _onGameLost(state, context);
        } else if (state is ShowStats) {
          showModalBottomSheet(
              context: context,
              builder: (BuildContext statsSheet) {
                return FractionallySizedBox(
                  widthFactor: 0.75,
                  child: StatsSheet(
                    statsRepository: widgetContext.getStatsRepository(),
                  ),
                );
              });
        }
      },
      child: Column(
        children: [
          Expanded(
            flex: 7,
            child: GuessesLayout(),
          ),
          Expanded(
            flex: 3,
            child: KeyboardLayout(),
          ),
        ],
      ),
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
