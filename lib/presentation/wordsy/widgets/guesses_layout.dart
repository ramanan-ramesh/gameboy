import 'package:flutter/material.dart';
import 'package:gameboy/data/wordsy/constants.dart';

import 'guess_row/guess_row.dart';

class GuessesLayout extends StatelessWidget {
  final double widthFactor;
  const GuessesLayout({super.key, required this.widthFactor});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Column(
        children: List<Widget>.generate(
          WordsyConstants.numberOfGuesses,
          (index) => Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GuessRow(guessIndex: index),
            ),
          ),
        ),
      ),
    );
  }
}
