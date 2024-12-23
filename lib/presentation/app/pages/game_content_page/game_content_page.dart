import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/models/game_engine.dart';
import 'package:gameboy/data/app/models/stats.dart';
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
      child: BlocConsumer<GameBloc, GameState>(
        builder: (context, state) {
          if (state is GameLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          var gameLoadedState = state as GameLoaded;
          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider(
                  create: (context) => gameLoadedState.statistics),
              RepositoryProvider(
                  create: (context) => gameLoadedState.gameEngine),
            ],
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                var (layoutWidth, layoutHeight, appBarWidth) =
                    _calculateLayoutConstraints(
                        constraints.maxWidth, constraints.maxHeight);
                return _GameLayout(
                  gameData: gameData,
                  layoutSizes: (layoutWidth, layoutHeight, appBarWidth),
                );
              },
            ),
          );
        },
        buildWhen: (previous, current) {
          return current is GameLoading || current is GameLoaded;
        },
        listener: (context, state) {},
      ),
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
      layoutHeight -= _appBarHeight;
    } else {
      layoutHeight = max(incomingHeight - _appBarHeight,
          gameData.gameLayout.constraints.minHeight);
    }

    return (layoutWidth, layoutHeight, appBarWidth);
  }
}

const _appBarHeight = 80.0;

class _GameLayout extends StatelessWidget {
  final GameData gameData;
  (double layoutWidth, double layoutHeight, double? appBarWidth) layoutSizes;

  _GameLayout({super.key, required this.gameData, required this.layoutSizes});

  @override
  Widget build(BuildContext context) {
    var (layoutWidth, layoutHeight, appBarWidth) = layoutSizes;
    return BlocListener<GameBloc, GameState>(
      listener: (BuildContext layoutContext, GameState state) {
        if (state is ShowStats) {
          _displayStatisticsSheet(layoutContext);
        }
      },
      child: Scaffold(
        appBar: GameAppBar(
          game: gameData.game,
          actionButtonBar: gameData.gameLayout.buildActionButtonBar(context),
          contentWidth: appBarWidth,
          height: _appBarHeight,
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
      ),
    );
  }

  void _displayStatisticsSheet(BuildContext layoutContext) {
    showModalBottomSheet(
        context: layoutContext,
        enableDrag: true,
        // showDragHandle: true,
        isScrollControlled: true,
        builder: (BuildContext context) {
          var layoutConstraints = gameData.gameLayout.constraints;
          var (layoutWidth, layoutHeight, appBarWidth) = layoutSizes;
          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider(
                  create: (context) =>
                      RepositoryProvider.of<Statistics>(layoutContext)),
              RepositoryProvider(
                  create: (context) =>
                      RepositoryProvider.of<GameEngine>(layoutContext)),
            ],
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  constraints: BoxConstraints(
                    minWidth: layoutConstraints.minWidth,
                    maxWidth: layoutConstraints.maxWidth * 0.75,
                    minHeight: layoutHeight * 0.5,
                    maxHeight: layoutHeight * 0.75,
                  ),
                  child: SingleChildScrollView(
                    child: _createStatsSheet(context),
                  ),
                ),
                Positioned(
                  top: -_appBarHeight / 2,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: _appBarHeight,
                    height: _appBarHeight,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(
                          gameData.game.imageAsset,
                          // fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _createStatsSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox.fromSize(
            size: Size.fromHeight(_appBarHeight / 2),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Text(
              'STATS',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: gameData.gameLayout.createStatsSheet(context, gameData.game),
          ),
        ],
      ),
    );
  }
}
