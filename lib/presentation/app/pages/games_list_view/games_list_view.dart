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
        return Scaffold(
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
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                customBorder: const CircleBorder(),
                splashColor: Colors.white60,
                onTap: () {
                  context.addMasterPageEvent(LoadGame(game));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: game.imageAsset
                          .image(height: 150, width: 150, fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          game.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Description outside the circle
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              game.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
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
