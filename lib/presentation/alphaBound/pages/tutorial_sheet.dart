import 'package:flutter/material.dart';
import 'package:gameboy/data/alphaBound/models/constants.dart';

class AlphaBoundTutorialSheet extends StatelessWidget {
  const AlphaBoundTutorialSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'Guess the secret word hidden between two words in ${AlphaBoundConstants.maximumGuessesAllowed} tries.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'The 5-letter word dictionary is sorted in alphabetical order.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: _createInstructions(context),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Text(
                'A new puzzle is released daily at midnight',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createInstructions(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double letterSize =
            constraints.maxWidth / (AlphaBoundConstants.guessWordLength + 2);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: _createGameLayoutDescription(context, letterSize),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                'One of the following can happen, depending on the word of the day:',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const Divider(),
            _createGuessWordStateExplanation(
              1,
              context,
              'AAAAA',
              'LAUGH',
              'RATIO',
              letterSize,
              [
                'LAUGH appears between the lower bound - AAAAA and RATIO',
                'The upper bound is now replaced with RATIO.',
              ],
            ),
            const Divider(),
            _createGuessWordStateExplanation(
              2,
              context,
              'RATIO',
              'VOUCH',
              'ZZZZZ',
              letterSize,
              [
                'VOUCH appears between RATIO and the upper bound- ZZZZZ',
                'The lower bound is now replaced with RATIO.',
              ],
            ),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _createGameLayoutDescription(BuildContext context, double letterSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Text(
            'Start by entering a valid 5-letter word.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        _WordRangeLayout(
          lowerBound: 'AAAAA',
          guessedWord: 'RATIO',
          upperBound: 'ZZZZZ',
          letterSize: letterSize,
          isGuessedWordEqualToWordOfTheDay: false,
        ),
        Text(
          'Lower bound - AAAAA\nGuessed word - RATIO\nUpper Bound - ZZZZZ',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _createGuessWordStateExplanation(
      int index,
      BuildContext context,
      String lowerBound,
      String wordOfTheDay,
      String upperBound,
      double letterSize,
      Iterable<String> explanationTexts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Text(
            '$index. Word of the day - $wordOfTheDay',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ...explanationTexts.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Text(
                e,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )),
        _WordRangeLayout(
          lowerBound: lowerBound,
          guessedWord: wordOfTheDay,
          upperBound: upperBound,
          letterSize: letterSize,
          isGuessedWordEqualToWordOfTheDay: true,
        ),
      ],
    );
  }
}

class _WordRangeLayout extends StatelessWidget {
  final String lowerBound;
  final String guessedWord;
  final String upperBound;
  final double letterSize;
  final bool isGuessedWordEqualToWordOfTheDay;
  const _WordRangeLayout({
    super.key,
    required this.lowerBound,
    required this.guessedWord,
    required this.upperBound,
    required this.letterSize,
    required this.isGuessedWordEqualToWordOfTheDay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: _createBoundaryWord(lowerBound, letterSize),
        ),
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: _createGuessWord(
              guessedWord, letterSize, isGuessedWordEqualToWordOfTheDay),
        ),
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: _createBoundaryWord(upperBound, letterSize),
        ),
      ],
    );
  }

  Widget _createBoundaryWord(String word, double letterSize) {
    var guessLetterSlots =
        List<Widget>.generate(AlphaBoundConstants.guessWordLength, (index) {
      return Padding(
        padding: const EdgeInsets.all(3.0),
        child: _createBoundsLetterSlot(index, word[index], letterSize),
      );
    });
    return Row(
      children: [
        ...guessLetterSlots,
      ],
    );
  }

  Widget _createGuessWord(
      String word, double letterSize, bool isEqualToWordOfTheDay) {
    var guessLetterSlots =
        List<Widget>.generate(AlphaBoundConstants.guessWordLength, (index) {
      return Padding(
        padding: const EdgeInsets.all(3.0),
        child: _createGuessLetterSlot(index, word[index], letterSize,
            isEqualToWordOfTheDay ? Colors.green : Colors.orange),
      );
    });
    return Row(
      children: [
        ...guessLetterSlots,
      ],
    );
  }

  Widget _createBoundsLetterSlot(
      int index, String letter, double letterSlotSize) {
    return Container(
      width: letterSlotSize,
      height: letterSlotSize,
      decoration: const BoxDecoration(
        color: Colors.blue,
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: TextStyle(fontSize: letterSlotSize / 2, color: Colors.white),
        ),
      ),
    );
  }

  Widget _createGuessLetterSlot(
      int index, String letter, double letterSlotSize, Color slotColor) {
    return Container(
      width: letterSlotSize,
      height: letterSlotSize,
      decoration: BoxDecoration(
        color: slotColor,
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: TextStyle(fontSize: letterSlotSize / 2, color: Colors.black),
        ),
      ),
    );
  }
}
