import 'package:flutter/material.dart';
import 'package:gameboy/data/alphaBound/models/stats.dart';
import 'package:gameboy/data/app/models/game.dart';

class AlphaBoundStatsSheet extends StatelessWidget {
  final AlphaBoundStats stats;
  final Game game;
  const AlphaBoundStatsSheet(
      {super.key, required this.stats, required this.game});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(),
    );
  }
}
