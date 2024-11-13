import 'package:flutter/material.dart';
import 'package:gameboy/data/spelling_bee/models/score.dart';
import 'package:gameboy/presentation/spelling_bee/extensions.dart';

class ScoreBar extends StatelessWidget {
  static const _rankIndicatorRadius = 10.0;
  const ScoreBar({super.key});

  @override
  Widget build(BuildContext context) {
    var gameEngineData = context.getGameEngineData();
    var currentScore = gameEngineData.currentScore;
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(currentScore.rank),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 100,
              child: _buildRankIndicator(currentScore, context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankIndicator(Score score, BuildContext context) {
    var numberOfRanks = Score.allRanks.length;
    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth = constraints.maxWidth;
        double spacing = availableWidth / (numberOfRanks - 1);
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 2,
              color: Colors.white,
              width: availableWidth,
            ),
            for (int i = 0; i < numberOfRanks - 1; i++)
              Positioned(
                left: spacing * i,
                child: CircleAvatar(
                  radius: _rankIndicatorRadius,
                  backgroundColor: Colors.yellow,
                  child: i == score.rankIndex
                      ? Text(
                          (score.score).toString(),
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        )
                      : null,
                ),
              ),
            Positioned(
              left: availableWidth - _rankIndicatorRadius * 2,
              child: CircleAvatar(
                radius: _rankIndicatorRadius,
                backgroundColor: Colors.yellow,
                child: (numberOfRanks - 1) == score.rankIndex
                    ? Text(
                        (score.score).toString(),
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      )
                    : null,
              ),
            )
          ],
        );
      },
    );
  }
}
