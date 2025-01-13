import 'package:flutter/material.dart';
import 'package:gameboy/data/app/models/game.dart';

abstract class GameLayout {
  Widget buildGameLayout(
      BuildContext context, double layoutWidth, double layoutHeight);

  BoxConstraints get constraints;

  Widget buildStatsSheet(BuildContext context, Game game);
}
