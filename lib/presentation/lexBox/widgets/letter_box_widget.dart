import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gameboy/presentation/app/theming/app_colors.dart';

/// Position data for each letter on the square
class LetterPosition {
  final String letter;
  final int index;
  final int side; // 0=left, 1=top, 2=right, 3=bottom
  final int positionOnSide; // 0, 1, or 2
  Offset center = Offset.zero;
  Offset indicatorCenter = Offset.zero; // Small circle on the square edge

  LetterPosition({
    required this.letter,
    required this.index,
    required this.side,
    required this.positionOnSide,
  });
}

class LetterBoxWidget extends StatefulWidget {
  final String lettersOfTheDay;
  final List<int> currentWordIndices;
  final Set<int> usedLetterIndices;
  final ValueChanged<List<int>> onWordComplete;
  final VoidCallback onWordCancelled;
  final ValueChanged<List<int>> onCurrentWordChanged;

  const LetterBoxWidget({
    super.key,
    required this.lettersOfTheDay,
    required this.currentWordIndices,
    required this.usedLetterIndices,
    required this.onWordComplete,
    required this.onWordCancelled,
    required this.onCurrentWordChanged,
  });

  @override
  State<LetterBoxWidget> createState() => _LetterBoxWidgetState();
}

class _LetterBoxWidgetState extends State<LetterBoxWidget> {
  late List<LetterPosition> _letterPositions;
  List<int> _tempWordIndices = [];
  Offset? _currentPointer;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _initLetterPositions();
    _tempWordIndices = List.from(widget.currentWordIndices);
  }

  @override
  void didUpdateWidget(LetterBoxWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lettersOfTheDay != widget.lettersOfTheDay) {
      _initLetterPositions();
    }
    if (oldWidget.currentWordIndices != widget.currentWordIndices) {
      _tempWordIndices = List.from(widget.currentWordIndices);
    }
  }

  void _initLetterPositions() {
    _letterPositions = [];
    for (int i = 0; i < widget.lettersOfTheDay.length && i < 12; i++) {
      _letterPositions.add(LetterPosition(
        letter: widget.lettersOfTheDay[i].toUpperCase(),
        index: i,
        side: i ~/ 3,
        positionOnSide: i % 3,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        final squareSize =
            size * 0.6; // Smaller square to leave room for letters outside
        final letterOffset =
            size * 0.12; // Distance of letters from square edge
        final padding = (size - squareSize) / 2;
        final indicatorRadius = size * 0.015; // Small indicator circles

        _calculateLetterCenters(squareSize, padding, letterOffset);

        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _LetterBoxPainter(
                letterPositions: _letterPositions,
                currentWordIndices: _tempWordIndices,
                usedLetterIndices: widget.usedLetterIndices,
                currentPointer: _currentPointer,
                indicatorRadius: indicatorRadius,
                squareSize: squareSize,
                padding: padding,
                isDark: isDark,
              ),
              child: Stack(
                children: _letterPositions.map((lp) {
                  final letterSize = size * 0.08;
                  return Positioned(
                    left: lp.center.dx - letterSize / 2,
                    top: lp.center.dy - letterSize / 2,
                    child: _LetterText(
                      letter: lp.letter,
                      size: letterSize,
                      isUsed: widget.usedLetterIndices.contains(lp.index),
                      isInCurrentWord: _tempWordIndices.contains(lp.index),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  void _calculateLetterCenters(
      double squareSize, double padding, double letterOffset) {
    for (var lp in _letterPositions) {
      final (letterCenter, indicatorCenter) = _getLetterOffset(
        lp.side,
        lp.positionOnSide,
        squareSize,
        padding,
        letterOffset,
      );
      lp.center = letterCenter;
      lp.indicatorCenter = indicatorCenter;
    }
  }

  (Offset letterCenter, Offset indicatorCenter) _getLetterOffset(
      int side,
      int positionOnSide,
      double squareSize,
      double padding,
      double letterOffset) {
    final spacing = squareSize / 4;
    final startOffset = spacing;

    switch (side) {
      case 0: // Left - letters to the left of square
        final y = padding + startOffset + positionOnSide * spacing;
        return (
          Offset(padding - letterOffset, y),
          Offset(padding, y),
        );
      case 1: // Top - letters above square
        final x = padding + startOffset + positionOnSide * spacing;
        return (
          Offset(x, padding - letterOffset),
          Offset(x, padding),
        );
      case 2: // Right - letters to the right of square
        final y = padding + startOffset + positionOnSide * spacing;
        return (
          Offset(padding + squareSize + letterOffset, y),
          Offset(padding + squareSize, y),
        );
      case 3: // Bottom - letters below square
        final x = padding + startOffset + positionOnSide * spacing;
        return (
          Offset(x, padding + squareSize + letterOffset),
          Offset(x, padding + squareSize),
        );
      default:
        return (Offset.zero, Offset.zero);
    }
  }

  void _onPanStart(DragStartDetails details) {
    final hitIndex = _findLetterAtPosition(details.localPosition);
    if (hitIndex != null) {
      if (_canSelectLetter(hitIndex)) {
        setState(() {
          _isDragging = true;
          _tempWordIndices = List.from(widget.currentWordIndices);
          _tempWordIndices.add(hitIndex);
          _currentPointer = details.localPosition;
        });
        // Notify parent about current word being formed
        widget.onCurrentWordChanged(_tempWordIndices);
        HapticFeedback.lightImpact();
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    setState(() {
      _currentPointer = details.localPosition;
    });

    final hitIndex = _findLetterAtPosition(details.localPosition);
    if (hitIndex != null && !_tempWordIndices.contains(hitIndex)) {
      if (_canSelectLetter(hitIndex)) {
        setState(() {
          _tempWordIndices.add(hitIndex);
        });
        // Notify parent about current word being formed
        widget.onCurrentWordChanged(_tempWordIndices);
        HapticFeedback.selectionClick();
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;

    setState(() {
      _isDragging = false;
      _currentPointer = null;
    });

    // Auto-submit if word has 3+ letters
    if (_tempWordIndices.length >= 3) {
      widget.onWordComplete(_tempWordIndices);
    } else {
      // Clear the current word display if less than 3 letters
      widget.onCurrentWordChanged([]);
    }
    _tempWordIndices = List.from(widget.currentWordIndices);
  }

  int? _findLetterAtPosition(Offset position) {
    const hitRadius = 40.0;
    for (var lp in _letterPositions) {
      // Check both letter center and indicator center
      if ((lp.center - position).distance < hitRadius ||
          (lp.indicatorCenter - position).distance < hitRadius) {
        return lp.index;
      }
    }
    return null;
  }

  bool _canSelectLetter(int index) {
    if (_tempWordIndices.isEmpty) return true;

    final lastIndex = _tempWordIndices.last;
    final lastSide = lastIndex ~/ 3;
    final newSide = index ~/ 3;

    // Cannot select same letter consecutively
    if (lastIndex == index) return false;

    // Cannot select letter from same side
    if (lastSide == newSide) return false;

    return true;
  }
}

class _LetterText extends StatelessWidget {
  final String letter;
  final double size;
  final bool isUsed;
  final bool isInCurrentWord;

  const _LetterText({
    required this.letter,
    required this.size,
    required this.isUsed,
    required this.isInCurrentWord,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameColor = GameColors.lexBoxPrimary;

    Color textColor;
    if (isInCurrentWord) {
      textColor = gameColor;
    } else if (isUsed) {
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);
    } else {
      textColor = theme.colorScheme.onSurface;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: textColor,
            fontSize: size * 0.7,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _LetterBoxPainter extends CustomPainter {
  final List<LetterPosition> letterPositions;
  final List<int> currentWordIndices;
  final Set<int> usedLetterIndices;
  final Offset? currentPointer;
  final double indicatorRadius;
  final double squareSize;
  final double padding;
  final bool isDark;

  _LetterBoxPainter({
    required this.letterPositions,
    required this.currentWordIndices,
    required this.usedLetterIndices,
    required this.currentPointer,
    required this.indicatorRadius,
    required this.squareSize,
    required this.padding,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final squareColor = isDark ? Colors.white : Colors.black87;
    final usedColor = isDark ? Colors.white54 : Colors.black38;
    final unusedColor = isDark ? Colors.white : Colors.black87;

    // Draw square border
    final squarePaint = Paint()
      ..color = squareColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final squareRect = Rect.fromLTWH(padding, padding, squareSize, squareSize);
    canvas.drawRect(squareRect, squarePaint);

    // Draw small indicator circles on the square edges
    for (var lp in letterPositions) {
      final isUsed = usedLetterIndices.contains(lp.index);
      final isInCurrentWord = currentWordIndices.contains(lp.index);

      final indicatorPaint = Paint()
        ..style = isUsed || isInCurrentWord
            ? PaintingStyle.fill
            : PaintingStyle.stroke
        ..strokeWidth = 1.5;

      if (isInCurrentWord) {
        indicatorPaint.color = GameColors.lexBoxPrimary;
      } else if (isUsed) {
        indicatorPaint.color = usedColor;
      } else {
        indicatorPaint.color = unusedColor;
      }

      canvas.drawCircle(lp.indicatorCenter, indicatorRadius, indicatorPaint);
    }

    // Draw connecting lines for current word
    if (currentWordIndices.isNotEmpty) {
      final linePaint = Paint()
        ..color = GameColors.lexBoxPrimary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < currentWordIndices.length - 1; i++) {
        final fromPos = letterPositions
            .firstWhere((lp) => lp.index == currentWordIndices[i]);
        final toPos = letterPositions
            .firstWhere((lp) => lp.index == currentWordIndices[i + 1]);
        canvas.drawLine(
            fromPos.indicatorCenter, toPos.indicatorCenter, linePaint);
      }

      // Draw line to current pointer if dragging
      if (currentPointer != null && currentWordIndices.isNotEmpty) {
        final lastPos = letterPositions
            .firstWhere((lp) => lp.index == currentWordIndices.last);
        final pointerPaint = Paint()
          ..color = GameColors.lexBoxPrimary.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(lastPos.indicatorCenter, currentPointer!, pointerPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LetterBoxPainter oldDelegate) {
    return oldDelegate.currentWordIndices != currentWordIndices ||
        oldDelegate.currentPointer != currentPointer ||
        oldDelegate.usedLetterIndices != usedLetterIndices ||
        oldDelegate.isDark != isDark;
  }
}
