import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_data.dart';
import 'package:gameboy/presentation/app/blocs/game_state.dart';
import 'package:gameboy/presentation/app/pages/game_content_page/game_app_bar.dart';

class GameContentPage extends StatelessWidget {
  final GameData gameData;
  const GameContentPage({super.key, required this.gameData});

  @override
  Widget build(BuildContext context) {
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
}

class _GameLayout extends StatelessWidget {
  final GameData gameData;
  const _GameLayout({super.key, required this.gameData});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var (layoutWidth, layoutHeight, appBarWidth) =
            _calculateLayoutConstraints(
                constraints.maxWidth, constraints.maxHeight);
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

  (double layoutWidth, double layoutHeight, double? appBarWidth)
      _calculateLayoutConstraints(double incomingWidth, double incomingHeight) {
    double layoutWidth;
    double? appBarWidth;
    if (incomingWidth > gameData.gameLayout.constraints.maxWidth) {
      layoutWidth = gameData.gameLayout.constraints.maxWidth;
      appBarWidth = gameData.gameLayout.constraints.maxWidth;
    } else {
      layoutWidth =
          max(incomingWidth, gameData.gameLayout.constraints.minWidth);
    }
    double layoutHeight;
    if (incomingHeight > gameData.gameLayout.constraints.maxHeight) {
      layoutHeight = gameData.gameLayout.constraints.maxHeight;
      layoutHeight -= kToolbarHeight;
    } else {
      layoutHeight = max(incomingHeight - kToolbarHeight,
          gameData.gameLayout.constraints.minHeight);
    }

    return (layoutWidth, layoutHeight, appBarWidth);
  }
}
