import 'package:flutter/material.dart';
import 'package:gameboy/data/app/models/game.dart';

class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double? contentWidth;
  final Game game;
  final Widget? actionButtonBar;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  const GameAppBar(
      {super.key,
      this.contentWidth,
      required this.game,
      this.actionButtonBar,
      required this.height});

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
                if (actionButtonBar != null) actionButtonBar!,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameLogo() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Image.asset(
            game.imageAsset,
            width: 50,
            height: 50,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            game.name.toUpperCase(),
            style: TextStyle(fontSize: 20),
          ),
        )
      ],
    );
  }
}
