import 'package:flutter/material.dart';
import 'package:gameboy/presentation/alphaBound/widgets/guesses_layout/guess_letter_range_layout.dart';
import 'package:gameboy/presentation/alphaBound/widgets/guesses_layout/guess_word_range_layout.dart';

class GuessesLayout extends StatelessWidget {
  final double _letterSize;
  final ValueNotifier<String> guessLetterValueNotifier;

  const GuessesLayout(
      {super.key,
      required this.guessLetterValueNotifier,
      required double layoutWidth})
      : _letterSize = layoutWidth / 7;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GuessLetterRangeLayout(
            letterSize: _letterSize,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GuessWordLayout(
              letterSize: _letterSize,
              guessWordNotifier: guessLetterValueNotifier),
        ),
      ],
    );
  }
}
