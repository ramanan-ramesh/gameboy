import 'package:flutter/material.dart';

abstract class GameLayout {
  Widget buildActionButtonBar(BuildContext context);
  Widget buildGameLayout(
      BuildContext context, double layoutWidth, double layoutHeight);
  BoxConstraints get constraints;
}
