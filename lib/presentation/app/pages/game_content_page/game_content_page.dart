import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_state.dart';
import 'package:gameboy/presentation/app/extensions.dart';
import 'package:gameboy/presentation/app/pages/game_content_page/game_app_bar.dart';
import 'package:gameboy/presentation/app/pages/game_content_page/game_layout.dart';
import 'package:gameboy/presentation/spelling_bee/bloc/bloc.dart';
import 'package:gameboy/presentation/spelling_bee/pages/game_layout.dart';
import 'package:gameboy/presentation/wordle/bloc/bloc.dart';
import 'package:gameboy/presentation/wordle/pages/game_layout.dart';

class GameContentPage extends StatelessWidget {
  final Game game;
  const GameContentPage({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    var gameData = _getGameData(context)!;
    return BlocProvider<GameBloc>(
      create: (BuildContext context) => gameData.gameBloc,
      child: BlocBuilder<GameBloc, GameState>(builder: (context, state) {
        if (state is GameLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        var gameLoadedState = state as GameLoaded;
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider(create: (context) => gameLoadedState.statistics),
            RepositoryProvider(create: (context) => gameLoadedState.gameEngine),
          ],
          child: _GameLayout(gameData: gameData),
        );
      }, buildWhen: (previous, current) {
        return current is GameLoading || current is GameLoaded;
      }),
    );
  }

  _GameData? _getGameData(BuildContext context) {
    var userId = context.getAppData().activeUser!.userID;
    switch (game.name.toLowerCase()) {
      case 'wordle':
        return _GameData<WordleGameBloc>(
            gameBloc: WordleGameBloc(userId),
            gameLayout: WordleLayout(),
            game: game);
      case 'spelling-bee':
        return _GameData<SpellingBeeBloc>(
            gameBloc: SpellingBeeBloc(userId),
            gameLayout: SpellingBeeLayout(),
            game: game);
      default:
        return null;
    }
  }
}

class _GameLayout extends StatelessWidget {
  final _GameData gameData;
  const _GameLayout({super.key, required this.gameData});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double layoutWidth;
        double? appBarWidth;
        if (constraints.maxWidth > gameData.gameLayout.constraints.maxWidth) {
          layoutWidth = gameData.gameLayout.constraints.maxWidth;
          appBarWidth = gameData.gameLayout.constraints.maxWidth;
        } else {
          layoutWidth = max(
              constraints.maxWidth, gameData.gameLayout.constraints.minWidth);
        }
        double layoutHeight;
        if (constraints.maxHeight > gameData.gameLayout.constraints.maxHeight) {
          layoutHeight = gameData.gameLayout.constraints.maxHeight;
        } else {
          layoutHeight = max(constraints.maxHeight - kToolbarHeight,
              gameData.gameLayout.constraints.minHeight);
        }
        return Scaffold(
          appBar: GameAppBar(
            game: gameData.game,
            actionButtonBar: gameData.gameLayout.buildActionButtonBar(context),
            contentWidth: appBarWidth,
          ),
          body: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: layoutWidth,
                height: layoutHeight,
                child: gameData.gameLayout
                    .buildGameLayout(context, layoutWidth, layoutHeight),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GameData<TGameBloc extends GameBloc> {
  TGameBloc gameBloc;
  GameLayout gameLayout;
  Game game;
  _GameData(
      {required this.gameBloc, required this.gameLayout, required this.game});
}
