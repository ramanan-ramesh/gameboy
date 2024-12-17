import 'package:flutter/material.dart';
import 'package:gameboy/data/app/models/game.dart';

abstract class GameLayout {
  Widget buildActionButtonBar(BuildContext context);
  Widget buildGameLayout(
      BuildContext context, double layoutWidth, double layoutHeight);
  BoxConstraints get constraints;

  Widget createStatsSheet(BuildContext context, Game game);
}
