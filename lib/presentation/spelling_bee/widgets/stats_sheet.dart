import 'package:flutter/material.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/data/spelling_bee/models/constants.dart';
import 'package:gameboy/data/spelling_bee/models/stats.dart';

class SpellingBeeStatsSheet extends StatelessWidget {
  final Stats spellingBeeStats;
  final Game game;
  const SpellingBeeStatsSheet(
      {super.key, required this.spellingBeeStats, required this.game});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: _createSpellingBeeLogo(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: _createStatsTiles(spellingBeeStats),
              ),
              if (spellingBeeStats.rankingsCount.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: _createGuessDistribution(spellingBeeStats),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createSpellingBeeLogo() {
    return Column(
      children: [
        Image.asset(
          game.imageAsset,
          width: 50,
          height: 50,
        ),
        Text(game.name.capitalizeFirstLettersOfWord())
      ],
    );
  }

  Widget _createStatsTiles(Stats statsRepository) {
    var isLongestWordAvailable = statsRepository.longestGuessedWord != null;
    var isHighestRankAvailable = statsRepository.rankingsCount.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Text('Statistics'),
          ),
        ),
        Divider(),
        Row(
          children: [
            Expanded(
              child: _createStatsTile(
                  statsRepository.numberOfGamesPlayed.toString(), 'Puzzles'),
            ),
            Expanded(
              child: _createStatsTile(
                  statsRepository.numberOfWordsSubmitted.toString(), 'Words'),
            ),
            Expanded(
              child: _createStatsTile(
                  statsRepository.numberOfPangrams.toString(), 'Pangrams'),
            ),
          ],
        ),
        Divider(),
        if (isLongestWordAvailable || isHighestRankAvailable)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (isHighestRankAvailable)
                _createStatsTile(
                    statsRepository.rankingsCount.first.key, 'Highest Rank'),
              if (isLongestWordAvailable)
                _createStatsTile(statsRepository.longestGuessedWord.toString(),
                    'Longest Word'),
            ],
          ),
        if (isLongestWordAvailable || isHighestRankAvailable) Divider(),
      ],
    );
  }

  Widget _createStatsTile(String statistic, String subtitle) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Text(statistic),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Text(subtitle),
        ),
      ],
    );
  }

  Widget _createGuessDistribution(Stats statsRepository) {
    var guessDistributionsForRank =
        SpellingBeeConstants.ranks.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: _createGuessDistributionForRank(statsRepository, e),
            ));
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
      Stats statsRepository, String rankName) {
    var numberOfGamesWonForRank = statsRepository.rankingsCount
            .where((e) => e.key == rankName)
            .firstOrNull
            ?.value ??
        0;
    var winPercentageForPosition =
        statsRepository.numberOfGamesPlayed == 0 || numberOfGamesWonForRank == 0
            ? 0.0
            : numberOfGamesWonForRank / statsRepository.numberOfGamesPlayed;
    var guessDistributionChildWidget = Container(
      color: Colors.white12,
      child: winPercentageForPosition == 0
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('0'),
            )
          : FractionallySizedBox(
              widthFactor: winPercentageForPosition,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  numberOfGamesWonForRank.toString(),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
    );
    var guessDistributionWidget = winPercentageForPosition == 0
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: guessDistributionChildWidget,
          )
        : Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: guessDistributionChildWidget,
            ),
          );
    return Row(
      children: [
        Container(
          width: 80,
          margin: const EdgeInsets.symmetric(horizontal: 3.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(rankName),
          ),
        ),
        guessDistributionWidget,
      ],
    );
  }
}
