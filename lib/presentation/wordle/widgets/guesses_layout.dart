import 'package:flutter/material.dart';
import 'package:gameboy/data/wordle/constants.dart';

import 'guess_row/guess_row.dart';

class GuessesLayout extends StatelessWidget {
  const GuessesLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.7,
      child: Column(
        children: List<Widget>.generate(
          WordleConstants.numberOfGuesses,
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
