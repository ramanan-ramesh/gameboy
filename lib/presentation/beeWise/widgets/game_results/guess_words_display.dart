import 'package:flutter/material.dart';
import 'package:gameboy/presentation/app/theming/app_colors.dart';

class GuessWordsDisplay extends StatelessWidget {
  final List<String> words;

  GuessWordsDisplay({super.key, required Iterable<String> guessWords})
      : words = guessWords.toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the height of each word item (e.g., Text with padding)
        const double itemHeight = 36.0; // Adjust based on your design
        final itemsPerColumn = (constraints.maxHeight / itemHeight).floor();

        // Divide words into sublists based on dynamic itemsPerColumn
        List<List<String>> columns = [];
        for (var i = 0; i < words.length; i += itemsPerColumn) {
          columns.add(words.sublist(
            i,
            i + itemsPerColumn > words.length
                ? words.length
                : i + itemsPerColumn,
          ));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columns.map((columnWords) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  children: columnWords.map((word) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: GameColors.beeWisePrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              GameColors.beeWisePrimary.withValues(alpha: 0.3),
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
            }).toList(),
          ),
        );
      },
    );
  }
}
