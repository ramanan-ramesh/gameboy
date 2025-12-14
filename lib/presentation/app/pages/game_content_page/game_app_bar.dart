import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/blocs/game/bloc.dart';
import 'package:gameboy/blocs/game/events.dart';
import 'package:gameboy/data/app/models/game.dart';

class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double? contentWidth;
  final Game game;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  const GameAppBar(
      {super.key, this.contentWidth, required this.game, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        flexibleSpace: Center(
          child: SizedBox(
            width: contentWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildGameLogo(),
                ),
                _createActionButtonBar(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createActionButtonBar(BuildContext context) {
    var actionButtons = [
      IconButton(
        onPressed: () {
          BlocProvider.of<GameBloc>(context).add(RequestTutorial());
        },
        icon: const Icon(Icons.help_rounded),
      ),
      IconButton(
        onPressed: () {
          BlocProvider.of<GameBloc>(context).add(RequestStats());
        },
        icon: const Icon(Icons.query_stats_rounded),
      ),
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...actionButtons.map((button) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: button,
          );
        }),
      ],
    );
  }

  Widget _buildGameLogo() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: game.imageAsset.image(width: 50, height: 50),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            game.name.toUpperCase(),
            style: const TextStyle(fontSize: 20),
          ),
        )
      ],
    );
  }
}
