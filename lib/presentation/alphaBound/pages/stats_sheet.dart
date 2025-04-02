import 'package:flutter/material.dart';
import 'package:gameboy/data/alphaBound/models/constants.dart';
import 'package:gameboy/data/alphaBound/models/stats.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/presentation/alphaBound/extensions.dart';

class AlphaBoundStatsSheet extends StatelessWidget {
  final Game game;

  const AlphaBoundStatsSheet({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    var statsRepository = context.getStatsRepository();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: _createStatsTiles(statsRepository, context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: _createGuessDistribution(statsRepository, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createStatsTiles(
      AlphaBoundStatistics statsRepository, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Row(
          children: [
            Expanded(
              child: _createStatsTile(
                  statsRepository.numberOfGamesPlayed, 'Played', context),
            ),
            Expanded(
              child: _createStatsTile(statsRepository.winCount, 'Won', context),
            ),
          ],
        ),
        Divider(),
        Row(
          children: [
            Expanded(
              child: _createStatsTile(
                  statsRepository.currentStreak, 'Current Streak', context),
            ),
            Expanded(
              child: _createStatsTile(
                  statsRepository.maximumStreak, 'Max Streak', context),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }

  Widget _createGuessDistribution(
      AlphaBoundStatistics statsRepository, BuildContext context) {
    var guessDistributionWidgets = <Widget>[];
    for (var startIndex = 0;
        startIndex < AlphaBoundConstants.maximumGuessesAllowed;) {
      var endIndex = startIndex + 2;
      guessDistributionWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: _createGuessDistributionForPosition(
              statsRepository, startIndex, endIndex, context),
        ),
      );
      startIndex = endIndex + 1;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Text('WIN DISTRIBUTION'),
        ),
        ...guessDistributionWidgets,
      ],
    );
  }

  Widget _createGuessDistributionForPosition(
      AlphaBoundStatistics statsRepository,
      int startIndex,
      int endIndex,
      BuildContext context) {
    var numberOfGamesWonInPositionRange = statsRepository.winCountsPerPosition
        .skip(startIndex)
        .take(endIndex - startIndex + 1)
        .reduce((a, b) => a + b);
    double winPercentage;
    if (statsRepository.numberOfGamesPlayed == 0) {
      winPercentage = 0;
    } else {
      winPercentage =
          numberOfGamesWonInPositionRange / statsRepository.numberOfGamesPlayed;
    }
    return ListTile(
      leading: SizedBox(
        width: 70,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${startIndex + 1} - ${endIndex + 1}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
      title: LinearProgressIndicator(
        value: winPercentage,
        minHeight: 8,
        color: Colors.blue,
      ),
    );
  }

  Widget _createStatsTile(int number, String subtitle, BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Text(
            number.toString(),
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Text(
            subtitle,
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
