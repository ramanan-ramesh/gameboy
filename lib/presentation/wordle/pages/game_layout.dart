import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/presentation/extensions.dart';
import 'package:gameboy/presentation/wordle/bloc/bloc.dart';
import 'package:gameboy/presentation/wordle/bloc/events.dart';
import 'package:gameboy/presentation/wordle/bloc/states.dart';
import 'package:gameboy/presentation/wordle/widgets/game_bar.dart';
import 'package:gameboy/presentation/wordle/widgets/guesses_layout.dart';
import 'package:gameboy/presentation/wordle/widgets/keyboard_layout.dart';
import 'package:gameboy/presentation/wordle/widgets/stats_sheet.dart';

class GameLayout extends StatelessWidget {
  static const _maxWidth = 700.0;
  static const _minHeight = 500.0;

  const GameLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > _maxWidth) {
          if (constraints.maxHeight < _minHeight) {
            return Scaffold(
              appBar: GameBar(),
              body: SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: _maxWidth,
                    height: _minHeight,
                    child: _buildGameLayout(context, true),
                  ),
                ),
              ),
            );
          } else {
            return Scaffold(
              appBar: GameBar(
                contentWidth: _maxWidth,
              ),
              body: Center(
                child: SizedBox(
                  width: _maxWidth,
                  height: constraints.maxHeight,
                  child: _buildGameLayout(context, true),
                ),
              ),
            );
          }
        } else {
          if (constraints.maxHeight < _minHeight) {
            return Scaffold(
              appBar: GameBar(),
              body: SingleChildScrollView(
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: _minHeight,
                  child: _buildGameLayout(context, false),
                ),
              ),
            );
          } else {
            return Scaffold(
              appBar: GameBar(),
              body: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: _buildGameLayout(context, false),
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildGameLayout(BuildContext context, bool isConstrainedWidth) {
    var initialBlocState = BlocProvider.of<WordleGameBloc>(context).state;
    if (initialBlocState is GameWon && initialBlocState.isStartup) {
      _onGameWon(initialBlocState, context);
    }
    return BlocListener<WordleGameBloc, WordleState>(
      listener: (BuildContext context, WordleState state) {
        if (state is GameWon) {
          _onGameWon(state, context);
        } else if (state is GameLost) {
          var wordOfTheDay =
              context.getGameEngineData().wordOfTheDay.toUpperCase();
          Future.delayed(Duration(seconds: 6), () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('You lost! The word was $wordOfTheDay'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          });
          Future.delayed(Duration(seconds: 7, milliseconds: 250), () {
            if (context.mounted) {
              context.read<WordleGameBloc>().add(RequestStats());
            }
          });
        } else if (state is ShowStats) {
          showModalBottomSheet(
              context: context,
              builder: (BuildContext statsSheet) {
                return FractionallySizedBox(
                  widthFactor: 0.75,
                  child: StatsSheet(
                    statsRepository: context.getStatsRepository(),
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
        context.read<WordleGameBloc>().add(RequestStats());
      }
    });
  }
}
