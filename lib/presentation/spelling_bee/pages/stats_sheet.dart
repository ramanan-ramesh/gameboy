import 'package:flutter/material.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/data/spelling_bee/models/constants.dart';
import 'package:gameboy/data/spelling_bee/models/stats.dart';
import 'package:gameboy/presentation/spelling_bee/extensions.dart';

class SpellingBeeStatsSheet extends StatelessWidget {
  final Game game;

  const SpellingBeeStatsSheet({super.key, required this.game});

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
            if (statsRepository.rankingsCount.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: _createGuessDistribution(statsRepository, context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _createStatsTiles(Stats statsRepository, BuildContext context) {
    var isLongestWordAvailable = statsRepository.longestSubmittedWord != null;
    var isHighestRankAvailable = statsRepository.rankingsCount.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Row(
          children: [
            Expanded(
              child: _createStatsTile(
                  statsRepository.numberOfGamesPlayed.toString(),
                  'Puzzles',
                  context),
            ),
            Expanded(
              child: _createStatsTile(
                  statsRepository.numberOfWordsSubmitted.toString(),
                  'Words',
                  context),
            ),
            Expanded(
              child: _createStatsTile(
                  statsRepository.numberOfPangrams.toString(),
                  'Pangrams',
                  context),
            ),
          ],
        ),
        Divider(),
        if (isLongestWordAvailable || isHighestRankAvailable)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (isHighestRankAvailable)
                _createStatsTile(statsRepository.rankingsCount.first.key,
                    'Highest Rank', context),
              if (isLongestWordAvailable)
                _createStatsTile(
                    statsRepository.longestSubmittedWord.toString(),
                    'Longest Word',
                    context),
            ],
          ),
        if (isLongestWordAvailable || isHighestRankAvailable) Divider(),
      ],
    );
  }

  Widget _createStatsTile(
      String statistic, String subtitle, BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Text(statistic,
              style: int.tryParse(statistic) != null
                  ? Theme.of(context).textTheme.displayLarge
                  : Theme.of(context).textTheme.titleLarge),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Text(
            subtitle,
            style: TextStyle(color: Colors.yellow),
          ),
        ),
      ],
    );
  }

  Widget _createGuessDistribution(Stats statsRepository, BuildContext context) {
    var guessDistributionsForRank = SpellingBeeConstants.ranks.map(
      (e) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: _createGuessDistributionForRank(statsRepository, e, context),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Text('GUESS DISTRIBUTION'),
        ),
        ...guessDistributionsForRank
      ],
    );
  }

  Widget _createGuessDistributionForRank(
      Stats statsRepository, String rankName, BuildContext context) {
    var numberOfGamesWonForRank = statsRepository.rankingsCount
            .where((e) => e.key == rankName)
            .firstOrNull
            ?.value ??
        0;
    var winPercentageForPosition =
        statsRepository.numberOfGamesPlayed == 0 || numberOfGamesWonForRank == 0
            ? 0.0
            : numberOfGamesWonForRank / statsRepository.numberOfGamesPlayed;
    return ListTile(
      leading: SizedBox(
        width: 100,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            rankName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
      title: LinearProgressIndicator(
        value: winPercentageForPosition,
        minHeight: 8,
        color: Colors.yellow,
      ),
    );
  }
}
