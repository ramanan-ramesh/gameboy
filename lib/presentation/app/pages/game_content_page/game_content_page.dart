import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/models/game_engine.dart';
import 'package:gameboy/data/app/models/stats.dart';
import 'package:gameboy/presentation/app/blocs/game/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game/events.dart';
import 'package:gameboy/presentation/app/blocs/game/states.dart';
import 'package:gameboy/presentation/app/blocs/game_data.dart';
import 'package:gameboy/presentation/app/pages/game_content_page/game_app_bar.dart';
import 'package:rive/rive.dart';

class GameContentPage extends StatelessWidget {
  final GameData gameData;

  const GameContentPage({super.key, required this.gameData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameBloc>(
      create: (BuildContext context) => gameData.gameBloc,
      child: _GameContentPageLoader(gameData: gameData),
    );
  }
}

class _GameContentPageLoader extends StatefulWidget {
  const _GameContentPageLoader({
    super.key,
    required this.gameData,
  });

  final GameData<GameBloc<GameEvent, GameState, Statistics, GameEngine>>
      gameData;

  @override
  State<_GameContentPageLoader> createState() => _GameContentPageLoaderState();
}

class _GameContentPageLoaderState extends State<_GameContentPageLoader> {
  var _hasMinimumAnimationTimePassed = false;
  static final _animationController = SimpleAnimation('Hover');
  static const _minimumAnimationTime = Duration(seconds: 2);

  @override
  Widget build(BuildContext context) {
    if (BlocProvider.of<GameBloc>(context).state is GameLoading) {
      if (!_hasMinimumAnimationTimePassed) {
        _tryStartLoadingAnimation();
      }
    }
    return BlocConsumer<GameBloc, GameState>(
      builder: (context, state) {
        if (state is GameLoaded && _hasMinimumAnimationTimePassed) {
          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider(create: (context) => state.statistics),
              RepositoryProvider(create: (context) => state.gameEngine),
            ],
            child: _GameLayout(gameData: widget.gameData),
          );
        }
        return _createAnimatedLoadingScreen(context);
      },
      buildWhen: (previous, current) {
        return current is GameLoading || current is GameLoaded;
      },
      listener: (context, state) {},
    );
  }

  Widget _createAnimatedLoadingScreen(BuildContext context) {
    return Material(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            RiveAnimation.asset(
              'assets/game_loading.riv',
              fit: BoxFit.fitHeight,
              controllers: [
                _animationController,
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Loading ${widget.gameData.game.name} game data',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tryStartLoadingAnimation() {
    _hasMinimumAnimationTimePassed = false;
    Future.delayed(_minimumAnimationTime, () {
      setState(() {
        _hasMinimumAnimationTimePassed = true;
      });
    });
  }
}

const _appBarHeight = 80.0;

class _GameLayout extends StatelessWidget {
  final GameData gameData;
  late double _layoutHeight;
  BuildContext? _statsSheetPopupContext;
  BuildContext? _tutorialSheetPopupContext;
  _GameLayout({super.key, required this.gameData});

  @override
  Widget build(BuildContext context) {
    _statsSheetPopupContext = null;
    _tutorialSheetPopupContext = null;
    return SafeArea(
      child: BlocListener<GameBloc, GameState>(
        listener: (BuildContext layoutContext, GameState state) {
          if (state is ShowStats) {
            _displayStatisticsSheet(layoutContext);
          } else if (state is ShowTutorial) {
            _displaySheet(
                layoutContext,
                _tutorialSheetPopupContext,
                'How To Play',
                gameData.gameLayout.buildTutorialSheet(context, gameData.game),
                false);
          }
        },
        listenWhen: (previousState, currentState) {
          return currentState is ShowStats || currentState is ShowTutorial;
        },
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            var (layoutWidth, layoutHeight, appBarWidth) =
                _calculateLayoutConstraints(
                    constraints.maxWidth, constraints.maxHeight);
            _layoutHeight = layoutHeight;
            return Scaffold(
              appBar: GameAppBar(
                game: gameData.game,
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
            );
          },
        ),
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

  void _displaySheet(
      BuildContext layoutContext,
      BuildContext? sheetContext,
      String sheetHeaderTitle,
      Widget sheetContent,
      bool isSheetContentCentered) {
    if (sheetContext != null && sheetContext.mounted) {
      return;
    }
    showModalBottomSheet(
        context: layoutContext,
        enableDrag: true,
        isScrollControlled: true,
        builder: (BuildContext context) {
          sheetContext = context;
          var layoutConstraints = gameData.gameLayout.constraints;
          return _createSheet(context, sheetHeaderTitle, sheetContent,
              layoutConstraints, isSheetContentCentered);
        }).whenComplete(() {
      sheetContext = null;
    });
  }

  void _displayStatisticsSheet(BuildContext layoutContext) {
    _displaySheet(
        layoutContext,
        _statsSheetPopupContext,
        'STATS',
        MultiRepositoryProvider(
            providers: [
              RepositoryProvider(
                  create: (context) =>
                      RepositoryProvider.of<Statistics>(layoutContext)),
              RepositoryProvider(
                  create: (context) =>
                      RepositoryProvider.of<GameEngine>(layoutContext)),
            ],
            child: gameData.gameLayout
                .buildStatsSheet(layoutContext, gameData.game)),
        true);
  }

  Widget _createSheet(
      BuildContext layoutContext,
      String sheetHeaderTitle,
      Widget sheetContent,
      BoxConstraints layoutConstraints,
      bool isSheetContentCentered) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          constraints: BoxConstraints(
            minWidth: layoutConstraints.minWidth,
            maxWidth: layoutConstraints.maxWidth * 0.75,
            minHeight: _layoutHeight * 0.5,
            maxHeight: _layoutHeight * 0.75,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox.fromSize(
                    size: const Size.fromHeight(_appBarHeight / 2),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child: Text(
                        sheetHeaderTitle,
                        style: Theme.of(layoutContext)
                            .textTheme
                            .displaySmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (isSheetContentCentered)
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: sheetContent,
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child: sheetContent,
                    ),
                ],
              ),
            ),
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
    );
  }
}
