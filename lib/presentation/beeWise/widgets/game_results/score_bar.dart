import 'package:flutter/material.dart';
import 'package:gameboy/data/beeWise/models/constants.dart';
import 'package:gameboy/data/beeWise/models/score.dart';
import 'package:gameboy/presentation/app/theming/app_colors.dart';
import 'package:gameboy/presentation/beeWise/extensions.dart';

class ScoreBar extends StatelessWidget {
  static const _rankIndicatorRadius = 10.0;
  static const _rankIndicatorDiameter = _rankIndicatorRadius * 2;

  const ScoreBar({super.key});

  @override
  Widget build(BuildContext context) {
    var gameEngineData = context.getGameEngineData();
    var currentScore = gameEngineData.currentScore;
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            currentScore.rank,
            style: TextStyle(
              color: GameColors.beeWisePrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 100,
              child: _buildRankIndicators(currentScore, context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankIndicators(Score score, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    var numberOfRanks = BeeWiseConstants.ranks.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth = constraints.maxWidth;
        var totalWidthOccupiedByRankIndicators =
            _rankIndicatorDiameter * numberOfRanks;
        var totalEmptySpace =
            availableWidth - totalWidthOccupiedByRankIndicators;
        var averageEmptySpacing = totalEmptySpace / (numberOfRanks - 1);
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 2,
              color: isDark ? Colors.white24 : Colors.black26,
              width: availableWidth,
            ),
            for (int i = 0; i <= numberOfRanks; i++)
              Positioned(
                left: (_rankIndicatorDiameter + averageEmptySpacing) * i,
                child: CircleAvatar(
                  radius: _rankIndicatorRadius,
                  backgroundColor: i <= score.rankIndex
                      ? GameColors.beeWisePrimary
                      : (isDark
                          ? const Color(0xFF3D3D54)
                          : const Color(0xFFE0E0E8)),
                  child: i == score.rankIndex
                      ? Text(
                          score.score.toString(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
              ),
          ],
        );
      },
    );
  }
}
