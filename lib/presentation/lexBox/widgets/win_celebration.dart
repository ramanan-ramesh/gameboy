import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gameboy/presentation/app/theming/app_colors.dart';

class LexBoxWinCelebration extends StatefulWidget {
  final VoidCallback? onAnimationComplete;
  final String? lettersOfTheDay;

  const LexBoxWinCelebration({
    super.key,
    this.onAnimationComplete,
    this.lettersOfTheDay,
  });

  @override
  State<LexBoxWinCelebration> createState() => _LexBoxWinCelebrationState();
}

class _LexBoxWinCelebrationState extends State<LexBoxWinCelebration>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _letterController;
  late AnimationController _glowController;
  late AnimationController _squareController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation for the trophy/checkmark
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    // Letter orbit animation
    _letterController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    // Square drawing animation
    _squareController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Glow pulse animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _scaleController.forward();
    _squareController.forward();

    // Notify when animation is complete
    _scaleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _letterController.dispose();
    _glowController.dispose();
    _squareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final letters = widget.lettersOfTheDay ?? 'LEXBOXSOLVED';

    return Stack(
      children: [
        // Animated square with connecting lines
        Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_squareController, _letterController]),
            builder: (context, child) {
              return CustomPaint(
                painter: _CelebrationSquarePainter(
                  squareProgress: _squareController.value,
                  orbitProgress: _letterController.value,
                  letters: letters,
                  isDark: isDark,
                ),
                size: const Size(300, 300),
              );
            },
          ),
        ),

        // Orbiting letters
        Center(
          child: SizedBox(
            width: 300,
            height: 300,
            child: AnimatedBuilder(
              animation: _letterController,
              builder: (context, child) {
                return Stack(
                  children: List.generate(12, (index) {
                    final angle = (index / 12) * 2 * math.pi +
                        _letterController.value * 2 * math.pi;
                    final radius = 120.0;
                    final x = 150 + radius * math.cos(angle);
                    final y = 150 + radius * math.sin(angle);
                    final letter = index < letters.length
                        ? letters[index].toUpperCase()
                        : '';

                    return Positioned(
                      left: x - 15,
                      top: y - 15,
                      child: _AnimatedLetter(
                        letter: letter,
                        delay: index * 0.08,
                        scaleAnimation: _scaleAnimation,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ),

        // Center celebration content
        Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_scaleController, _glowController]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        GameColors.lexBoxPrimary
                            .withValues(alpha: _glowAnimation.value * 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Trophy/Success icon with glow
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isDark ? const Color(0xFF1A1A2E) : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: GameColors.lexBoxPrimary
                                  .withValues(alpha: _glowAnimation.value),
                              blurRadius: 25,
                              spreadRadius: 8,
                            ),
                          ],
                          border: Border.all(
                            color: GameColors.lexBoxPrimary,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 48,
                          color: GameColors.lexBoxPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Congratulations text
                      Text(
                        '🎉 SOLVED! 🎉',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: GameColors.lexBoxPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'All letters connected!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AnimatedLetter extends StatelessWidget {
  final String letter;
  final double delay;
  final Animation<double> scaleAnimation;

  const _AnimatedLetter({
    required this.letter,
    required this.delay,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final adjustedValue =
        ((scaleAnimation.value - delay) / (1 - delay)).clamp(0.0, 1.0);

    return Transform.scale(
      scale: adjustedValue,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: GameColors.lexBoxPrimary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: GameColors.lexBoxPrimary.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _CelebrationSquarePainter extends CustomPainter {
  final double squareProgress;
  final double orbitProgress;
  final String letters;
  final bool isDark;

  _CelebrationSquarePainter({
    required this.squareProgress,
    required this.orbitProgress,
    required this.letters,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final squareSize = 80.0;
    final halfSize = squareSize / 2;

    // Draw animated square
    final squarePaint = Paint()
      ..color = GameColors.lexBoxPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final totalLength = squareSize * 4;
    final currentLength = totalLength * squareProgress;

    // Draw square progressively
    if (currentLength > 0) {
      // Top edge
      final topLength = math.min(currentLength, squareSize);
      path.moveTo(center.dx - halfSize, center.dy - halfSize);
      path.lineTo(center.dx - halfSize + topLength, center.dy - halfSize);
    }

    if (currentLength > squareSize) {
      // Right edge
      final rightLength = math.min(currentLength - squareSize, squareSize);
      path.lineTo(center.dx + halfSize, center.dy - halfSize + rightLength);
    }

    if (currentLength > squareSize * 2) {
      // Bottom edge
      final bottomLength = math.min(currentLength - squareSize * 2, squareSize);
      path.lineTo(center.dx + halfSize - bottomLength, center.dy + halfSize);
    }

    if (currentLength > squareSize * 3) {
      // Left edge
      final leftLength = math.min(currentLength - squareSize * 3, squareSize);
      path.lineTo(center.dx - halfSize, center.dy + halfSize - leftLength);
    }

    canvas.drawPath(path, squarePaint);

    // Draw connecting lines from center outward (pulsing)
    if (squareProgress > 0.5) {
      final linePaint = Paint()
        ..color = GameColors.lexBoxSecondary.withValues(
            alpha: 0.3 + 0.3 * math.sin(orbitProgress * math.pi * 2))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      for (int i = 0; i < 12; i++) {
        final angle = (i / 12) * 2 * math.pi + orbitProgress * math.pi * 0.5;
        final innerRadius = 50.0;
        final outerRadius = 100.0;

        final startX = center.dx + innerRadius * math.cos(angle);
        final startY = center.dy + innerRadius * math.sin(angle);
        final endX = center.dx + outerRadius * math.cos(angle);
        final endY = center.dy + outerRadius * math.sin(angle);

        canvas.drawLine(
          Offset(startX, startY),
          Offset(endX, endY),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationSquarePainter oldDelegate) {
    return oldDelegate.squareProgress != squareProgress ||
        oldDelegate.orbitProgress != orbitProgress;
  }
}

/// Compact win badge shown after celebration
class LexBoxWinBadge extends StatelessWidget {
  const LexBoxWinBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.lexBoxPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GameColors.lexBoxPrimary.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events_rounded,
            size: 20,
            color: GameColors.lexBoxPrimary,
          ),
          const SizedBox(width: 8),
          Text(
            'SOLVED!',
            style: theme.textTheme.labelLarge?.copyWith(
              color: GameColors.lexBoxPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
