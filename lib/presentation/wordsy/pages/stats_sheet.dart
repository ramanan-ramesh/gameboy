import 'package:flutter/material.dart';
import 'package:gameboy/data/wordsy/models/stats.dart';
import 'package:gameboy/presentation/wordsy/extensions.dart';

class WordsyStatsSheet extends StatelessWidget {
  const WordsyStatsSheet({super.key});

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
              child: _createGuessDistribution(statsRepository),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createStatsTiles(
      WordsyStatistics statsRepository, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Row(
          children: [
            Expanded(
              child: _createStatsTile(
                  statsRepository.numberOfGamesPlayed, 'Played', context),
            ),
            Expanded(
              child: _createStatsTile(
                  statsRepository.winPercentage, 'Win %', context),
            ),
          ],
        ),
        const Divider(),
        Row(
          children: [
            Expanded(
              child: _createStatsTile(
                  statsRepository.currentStreak, 'Current Streak', context),
            ),
            Expanded(
              child: _createStatsTile(
                  statsRepository.maxStreak, 'Max Streak', context),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }

  Widget _createGuessDistribution(WordsyStatistics statsRepository) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 3.0),
          child: Text('GUESS DISTRIBUTION'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: _createGuessDistributionForPosition(statsRepository, 0),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: _createGuessDistributionForPosition(statsRepository, 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: _createGuessDistributionForPosition(statsRepository, 2),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: _createGuessDistributionForPosition(statsRepository, 3),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: _createGuessDistributionForPosition(statsRepository, 4),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: _createGuessDistributionForPosition(statsRepository, 5),
        ),
      ],
    );
  }

  Widget _createGuessDistributionForPosition(
      WordsyStatistics statsRepository, int index) {
    var numberOfGamesWon =
        statsRepository.winCountsInPositions.reduce((a, b) => a + b);
    var winPercentageForPosition = numberOfGamesWon == 0
        ? 0.0
        : statsRepository.winCountsInPositions.elementAt(index) /
            numberOfGamesWon;
    return _WinDistribution(
        index: index, winPercentage: winPercentageForPosition);
  }

  Widget _createStatsTile(int number, String subtitle, BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Text(number.toString(),
              style: Theme.of(context).textTheme.displayLarge),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Text(
            subtitle,
            style: const TextStyle(color: Colors.green),
          ),
        ),
      ],
    );
  }
}

class _WinDistribution extends StatelessWidget {
  final int index;
  final double winPercentage;

  const _WinDistribution(
      {super.key, required this.index, required this.winPercentage});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text('$index', style: Theme.of(context).textTheme.titleLarge!),
      title: winPercentage == 0
          ? const SizedBox.shrink()
          : LinearProgressIndicator(
              value: winPercentage,
              backgroundColor: Colors.white12,
              minHeight: 8,
            ),
    );
  }
}
