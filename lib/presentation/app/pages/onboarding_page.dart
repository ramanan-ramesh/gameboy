import 'package:flutter/material.dart';

class OnBoardingPage extends StatelessWidget {
  final VoidCallback? onNavigateToNextPage;
  final bool isBigLayout;

  OnBoardingPage(
      {super.key, this.onNavigateToNextPage, required this.isBigLayout});

  static const _appLogoAsset = 'assets/logos/app_logo_round.webp';

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Image(
                  image: AssetImage(_appLogoAsset),
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                'Where words play hard to get!',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(color: Colors.green),
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
              ),
            ],
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
