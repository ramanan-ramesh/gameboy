import 'package:flutter/material.dart';

class GuessWordsDisplay extends StatelessWidget {
  final List<String> words;

  GuessWordsDisplay({required Iterable<String> guessWords})
      : words = guessWords.toList();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the height of each word item (e.g., Text with padding)
        const double itemHeight = 32.0; // Adjust based on your design
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
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        word.toUpperCase(),
                        style: TextStyle(
                            fontSize: 16, decoration: TextDecoration.underline),
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
