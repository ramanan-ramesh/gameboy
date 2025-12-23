import 'package:flutter/material.dart';
import 'package:gameboy/presentation/app/theming/app_colors.dart';

class GuessWordsDisplay extends StatelessWidget {
  final List<String> words;

  GuessWordsDisplay({super.key, required Iterable<String> guessWords})
      : words = guessWords.toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (words.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: words.map((word) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: GameColors.beeWisePrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: GameColors.beeWisePrimary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              word.toUpperCase(),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
