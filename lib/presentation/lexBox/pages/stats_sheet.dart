import 'package:flutter/material.dart';
import 'package:gameboy/presentation/app/theming/app_colors.dart';
import 'package:gameboy/presentation/lexBox/extensions.dart';

class LexBoxStatsSheet extends StatelessWidget {
  const LexBoxStatsSheet();

  @override
  Widget build(BuildContext context) {
    final stats = context.getStatsRepository();
    final gameColor = GameColors.lexBoxPrimary;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // First row: Wins and Current Streak
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  value: stats.winCount.toString(),
                  label: 'Wins',
                  color: gameColor,
                ),
              ),
              Expanded(
                child: _StatItem(
                  value: stats.currentStreak.toString(),
                  label: 'Current Streak',
                  color: gameColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Second row: Max Streak and Words Today
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  value: stats.maximumStreak.toString(),
                  label: 'Max Streak',
                  color: gameColor,
                ),
              ),
              Expanded(
                child: _StatItem(
                  value: stats.wordsSubmittedToday.length.toString(),
                  label: 'Words Today',
                  color: gameColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
