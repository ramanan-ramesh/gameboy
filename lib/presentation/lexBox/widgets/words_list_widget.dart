import 'package:flutter/material.dart';
import 'package:gameboy/presentation/app/theming/app_colors.dart';

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
    final theme = Theme.of(context);

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
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
              if (words.isNotEmpty && onEraseLastWord != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onEraseLastWord,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                      child: Icon(
                        Icons.undo_rounded,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
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
    final theme = Theme.of(context);
    final gameColor = GameColors.lexBoxPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color:
            isSubmitted ? gameColor : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: isSubmitted
            ? null
            : Border.all(color: theme.colorScheme.outline, width: 1),
        boxShadow: isSubmitted
            ? [
                BoxShadow(
                  color: gameColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        word.toUpperCase(),
        style: TextStyle(
          color: isSubmitted ? Colors.white : theme.colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
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
    final theme = Theme.of(context);
    final progress = usedCount / totalCount;
    final isComplete = usedCount == totalCount;
    final gameColor = GameColors.lexBoxPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DesignConstants.borderRadiusMedium),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$usedCount / $totalCount letters used',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isComplete
                      ? AppColors.success
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: isComplete ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isComplete) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle,
                    color: AppColors.success, size: 18),
              ],
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? AppColors.success : gameColor,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
