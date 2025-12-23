import 'package:flutter/material.dart';
import 'package:gameboy/presentation/app/theming/app_colors.dart';

class LexBoxTutorialSheet extends StatelessWidget {
  const LexBoxTutorialSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameColor = GameColors.lexBoxPrimary;

    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                'How to Play',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildRule(
              context,
              icon: Icons.gesture,
              title: 'Connect Letters',
              description:
                  'Drag your finger to connect letters around the square to spell words.',
              gameColor: gameColor,
            ),
            _buildRule(
              context,
              icon: Icons.text_fields,
              title: 'Word Length',
              description: 'Words must be at least 3 letters long.',
              gameColor: gameColor,
            ),
            _buildRule(
              context,
              icon: Icons.block,
              title: 'No Same Side',
              description:
                  'Consecutive letters cannot be from the same side of the square.',
              gameColor: gameColor,
            ),
            _buildRule(
              context,
              icon: Icons.repeat,
              title: 'No Repeats',
              description:
                  'The same letter cannot be used consecutively (but can be reused later).',
              gameColor: gameColor,
            ),
            _buildRule(
              context,
              icon: Icons.link,
              title: 'Chain Words',
              description:
                  'The last letter of each word becomes the first letter of the next word.',
              gameColor: gameColor,
            ),
            _buildRule(
              context,
              icon: Icons.check_circle,
              title: 'Goal',
              description:
                  'Use all 12 letters in as few words as possible to complete the puzzle.',
              gameColor: gameColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRule(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color gameColor,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: gameColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
