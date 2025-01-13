import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/presentation/app/blocs/bloc_extensions.dart';
import 'package:gameboy/presentation/app/blocs/master_page/master_page_bloc.dart';
import 'package:gameboy/presentation/app/blocs/master_page/master_page_events.dart';
import 'package:gameboy/presentation/app/blocs/master_page/master_page_states.dart';
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
    var games = context.getAppData().games;
    return BlocListener<MasterPageBloc, MasterPageState>(
      listener: (context, state) {
        if (state is LoadedGame) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => GameContentPage(gameData: state.gameData)));
        }
      },
      listenWhen: (previousState, currentState) {
        return currentState is LoadedGame;
      },
      child: Scaffold(
        appBar: HomeAppBar(),
        body: Center(
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            itemCount: games.length,
            itemBuilder: (context, index) {
              double scale = (_currentPage - index).abs();
              double scaleFactor = 1 - (scale * 0.3);

              return Transform.scale(
                scale: scaleFactor,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: _GameCard(game: games.elementAt(index)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final Game game;

  const _GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: InkResponse(
        splashColor: Colors.white60,
        containedInkWell: true,
        customBorder: const CircleBorder(),
        onTap: () {
          context.addMasterPageEvent(LoadGame(game));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Image.asset(
                game.imageAsset,
                height: 175,
                width: 175,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  game.name,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
