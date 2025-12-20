import 'package:flutter/material.dart';

class WordsListWidget extends StatelessWidget {
  final List<String> words;
  final String? currentWord;
  final VoidCallback? onEraseLastWord;

  const WordsListWidget({
    super.key,
    required this.words,
    this.currentWord,
    this.onEraseLastWord,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Words (${words.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ),
              if (words.isNotEmpty && onEraseLastWord != null)
                IconButton(
                  onPressed: onEraseLastWord,
                  icon: const Icon(Icons.undo),
                  color: Colors.white70,
                  tooltip: 'Erase last word',
                  iconSize: 20,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...words
                      .map((word) => _WordChip(word: word, isSubmitted: true)),
                  if (currentWord != null && currentWord!.isNotEmpty)
                    _WordChip(word: currentWord!, isSubmitted: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final bool isSubmitted;

  const _WordChip({
    required this.word,
    required this.isSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSubmitted ? const Color(0xFF6C63FF) : Colors.grey.shade700,
        borderRadius: BorderRadius.circular(16),
        border:
            isSubmitted ? null : Border.all(color: Colors.white38, width: 1),
      ),
      child: Text(
        word.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: isSubmitted ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class LettersProgressIndicator extends StatelessWidget {
  final int usedCount;
  final int totalCount;

  const LettersProgressIndicator({
    super.key,
    required this.usedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = usedCount / totalCount;
    final isComplete = usedCount == totalCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$usedCount / $totalCount letters used',
                style: TextStyle(
                  color: isComplete ? const Color(0xFF4CAF50) : Colors.white70,
                  fontWeight: isComplete ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isComplete) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle,
                    color: Color(0xFF4CAF50), size: 18),
              ],
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(
              isComplete ? const Color(0xFF4CAF50) : const Color(0xFF6C63FF),
            ),
          ),
        ],
      ),
    );
  }
}
