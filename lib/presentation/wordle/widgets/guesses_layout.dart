import 'package:flutter/material.dart';

import 'guess_row.dart';

class GuessesLayout extends StatelessWidget {
  const GuessesLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.7,
      child: Column(
        children: List<Widget>.generate(
          6,
          (index) => Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GuessRow(guessIndex: index + 1),
            ),
          ),
        ),
      ),
    );
  }
}
