import 'package:flutter/material.dart';
import 'package:gameboy/data/app/models/game.dart';

class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double? contentWidth;
  final Game game;
  final Widget? actionButtonBar;

  @override
  Size get preferredSize => const Size.fromHeight(80);

  const GameAppBar(
      {super.key, this.contentWidth, required this.game, this.actionButtonBar});

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      game.imageAsset,
                      width: 40,
                      height: 40,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      game.name.toUpperCase(),
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                ],
              ),
              if (actionButtonBar != null) actionButtonBar!,
            ],
          ),
        ),
      ),
      // title: Center(
      //   child: SizedBox(
      //     height: 80,
      //     width: contentWidth,
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         Padding(
      //           padding: const EdgeInsets.all(8.0),
      //           child: IconButton(
      //             onPressed: () {
      //               Navigator.pop(context);
      //             },
      //             icon: const Icon(Icons.close_rounded),
      //           ),
      //         ),
      //         Row(
      //           children: [
      //             Padding(
      //               padding: const EdgeInsets.all(8.0),
      //               child: Image.asset(
      //                 game.imageAsset,
      //                 width: 40,
      //                 height: 40,
      //               ),
      //             ),
      //             Padding(
      //               padding: const EdgeInsets.all(8.0),
      //               child: Text(
      //                 game.name.toUpperCase(),
      //                 style: TextStyle(fontSize: 20),
      //               ),
      //             )
      //           ],
      //         ),
      //         if (actionButtonBar != null) actionButtonBar!,
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
