import 'package:flutter/material.dart';

class GameBar extends StatelessWidget implements PreferredSizeWidget {
  static const String _appLogoAsset = 'assets/images/wordle_logo.webp';
  final double? contentWidth;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  const GameBar({Key? key, this.contentWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: null,
      automaticallyImplyLeading: false,
      title: Center(
        child: SizedBox(
          width: contentWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, left: 8.0, bottom: 8.0, right: 15.0),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close_rounded),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      _appLogoAsset,
                      width: 40,
                      height: 40,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      'Wordle',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: null,
                icon: Icon(Icons.info_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
