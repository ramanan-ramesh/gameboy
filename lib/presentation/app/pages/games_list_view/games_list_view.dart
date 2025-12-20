import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/blocs/app/bloc.dart';
import 'package:gameboy/blocs/app/events.dart';
import 'package:gameboy/blocs/app/states.dart';
import 'package:gameboy/blocs/bloc_extensions.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/presentation/app/extensions.dart';
import 'package:gameboy/presentation/app/pages/game_content_page/game_content_page.dart';
import 'package:gameboy/presentation/app/pages/games_list_view/app_bar.dart';
import 'package:gameboy/presentation/app/theming/app_colors.dart';

class GamesListView extends StatefulWidget {
  const GamesListView({super.key});

  @override
  State<GamesListView> createState() => _GamesListViewState();
}

class _GamesListViewState extends State<GamesListView> {
  final PageController _pageController = PageController(viewportFraction: 0.4);
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var gamesData = context.getAppData().games;
    return BlocListener<MasterPageBloc, MasterPageState>(
      listener: (context, state) {
        if (state is LoadedGame) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GameContentPage(gameData: state.gameData),
            ),
          );
        }
      },
      listenWhen: (previousState, currentState) {
        return currentState is LoadedGame;
      },
      child: LayoutBuilder(builder: (context, constraints) {
        var isBigLayout = constraints.minWidth > 1000;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        // Scaffold background distinct from app bar
        final scaffoldBackground = isDark
            ? AppColors.darkBackground // Pure dark background
            : const Color(0xFFF8F8FC); // Very light gray-purple

        return Scaffold(
          backgroundColor: scaffoldBackground,
          appBar: const HomeAppBar(),
          body: Center(
            child: PageView.builder(
              scrollDirection: isBigLayout ? Axis.horizontal : Axis.vertical,
              controller: _pageController,
              itemCount: gamesData.length,
              itemBuilder: (context, index) {
                double scale = (_currentPage - index).abs();
                double scaleFactor = 1 - (scale * 0.5);

                return Transform.scale(
                  scale: scaleFactor,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: _GameCard(game: gamesData.elementAt(index)),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}

class _GameCard extends StatelessWidget {
  final Game game;

  const _GameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameColor = GameColors.getPrimaryColor(game.name);
    final gameColorLight = GameColors.getSecondaryColor(game.name);

    return SizedBox(
      width: 320,
      height: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Clickable circle with image and name only
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  gameColor.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                stops: const [0.5, 1.0],
              ),
              border: Border.all(color: gameColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: gameColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                customBorder: const CircleBorder(),
                splashColor: gameColorLight.withValues(alpha: 0.3),
                highlightColor: gameColor.withValues(alpha: 0.1),
                onTap: () {
                  context.addMasterPageEvent(LoadGame(game));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: game.imageAsset
                          .image(height: 140, width: 140, fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          game.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: gameColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Description outside the circle
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              game.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
