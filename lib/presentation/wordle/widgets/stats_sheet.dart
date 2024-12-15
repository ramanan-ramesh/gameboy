import 'package:flutter/material.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/data/wordle/models/stats.dart';

class StatsSheet extends StatelessWidget {
  final WordleStats statsRepository;
  final Game game;
  const StatsSheet(
      {super.key, required this.statsRepository, required this.game});

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
                child: _createWordleLogo(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: _createStatsTiles(statsRepository),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: _createGuessDistribution(statsRepository),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createWordleLogo() {
    return Column(
      children: [
        Image.asset(
          game.imageAsset,
          width: 50,
          height: 50,
        ),
        Text(game.name.toUpperCase())
      ],
    );
  }

  Widget _createStatsTiles(WordleStats statsRepository) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Text('Statistics'),
        ),
        Row(
          children: [
            Expanded(
              child: _createStatsTile(
                  statsRepository.numberOfGamesPlayed, 'Played'),
            ),
            Expanded(
              child: _createStatsTile(statsRepository.winPercentage, 'Win %'),
            ),
            Expanded(
              child: _createStatsTile(
                  statsRepository.currentStreak, 'Current Streak'),
            ),
            Expanded(
              child: _createStatsTile(statsRepository.maxStreak, 'Max Streak'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _createGuessDistribution(WordleStats statsRepository) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
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
      WordleStats statsRepository, int index) {
    var numberOfGamesWon = statsRepository.wonPositions.reduce((a, b) => a + b);
    var winPercentageForPosition = numberOfGamesWon == 0
        ? 0.0
        : statsRepository.wonPositions.elementAt(index) / numberOfGamesWon;
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
                  statsRepository.wonPositions.elementAt(index).toString(),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.0),
          child: Text((index + 1).toString()),
        ),
        guessDistributionWidget,
      ],
    );
  }

  Widget _createStatsTile(int number, String subtitle) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Text(number.toString()),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Text(subtitle),
        ),
      ],
    );
  }
}
