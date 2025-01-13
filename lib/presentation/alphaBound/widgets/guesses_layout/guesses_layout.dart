import 'package:flutter/material.dart';
import 'package:gameboy/presentation/alphaBound/widgets/guesses_layout/guess_letter_range_layout.dart';
import 'package:gameboy/presentation/alphaBound/widgets/guesses_layout/guess_word_range_layout.dart';

class GuessesLayout extends StatelessWidget {
  final double _letterSize;
  final ValueNotifier<String> guessLetterValueNotifier;
  final double layoutWidth;

  const GuessesLayout(
      {super.key,
      required this.guessLetterValueNotifier,
      required this.layoutWidth})
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
          child: GuessWordRangeLayout(
              letterSize: _letterSize,
              guessLetterValueNotifier: guessLetterValueNotifier),
        ),
      ],
    );
  }
}
