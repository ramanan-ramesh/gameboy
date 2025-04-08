import 'package:flutter/material.dart';

class BeeWiseTutorialSheet extends StatelessWidget {
  static const _gameObjective = 'Create words using letters from the hive.';
  static const _gameInstructions = [
    'Words must contain at least 4 letters.',
    'Words must include the center letter.',
    'Our word list does not include words that are obscure, hyphenated, or proper nouns.',
    'No cussing either, sorry.',
    'Letters can be used more than once.'
  ];
  static const _scoreSystemDescriptions = [
    '4-letter words are worth 1 point each.',
    'Longer words earn 1 point per letter.',
    'Each puzzle includes at least one “pangram” which uses every letter. These are worth 7 extra points!'
  ];
  static const _newPuzzleReleaseText =
      'A new puzzle is released daily at midnight';
  const BeeWiseTutorialSheet({super.key});

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
              _gameObjective,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: _createInstructions(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: _createScoreSystemDescription(context),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Text(
                _newPuzzleReleaseText,
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

  Widget _createInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _gameInstructions.map((e) => _createInstruction(e)).toList(),
    );
  }

  Widget _createScoreSystemDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Text(
            'Score points to increase your rating.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ..._scoreSystemDescriptions.map((e) => _createInstruction(e)),
      ],
    );
  }

  Widget _createInstruction(String instruction) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.yellow,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            instruction,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
