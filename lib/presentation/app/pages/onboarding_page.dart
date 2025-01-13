import 'package:flutter/material.dart';

class OnBoardingPage extends StatelessWidget {
  VoidCallback? onNavigateToNextPage;
  bool isBigLayout;

  OnBoardingPage(
      {super.key, this.onNavigateToNextPage, required this.isBigLayout});

  static const _onBoardingImageAsset = 'assets/images/playing_games.webp';

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        const Positioned.fill(
          child: Image(
            image: AssetImage(_onBoardingImageAsset),
            fit: BoxFit.cover,
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: FittedBox(
                fit: BoxFit.fill,
                child: Text(
                  'Gameboy: Where words play hard to get!',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 45,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                )),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: EdgeInsets.only(right: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isBigLayout)
                  FloatingActionButton.large(
                    onPressed: onNavigateToNextPage,
                    shape: CircleBorder(),
                    child: Icon(
                      Icons.navigate_next_rounded,
                      size: 75,
                    ),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
