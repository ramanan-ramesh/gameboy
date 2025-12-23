import 'package:flutter/material.dart';
import 'package:gameboy/presentation/app/theming/app_colors.dart';

import 'polygon_border.dart';

class LetterInputLayout extends StatefulWidget {
  final Function(String letter) onLetterPressed;
  final double sizeOfCell;
  final String lettersOfTheDay;

  const LetterInputLayout(
      {super.key,
      required this.onLetterPressed,
      required this.sizeOfCell,
      required this.lettersOfTheDay});

  @override
  State<LetterInputLayout> createState() => _LetterInputLayoutState();
}

class _LetterInputLayoutState extends State<LetterInputLayout> {
  double get _halfHeightOfCell => widget.sizeOfCell * 0.5;

  @override
  Widget build(BuildContext context) {
    final letters = widget.lettersOfTheDay;
    return SizedBox(
      height: widget.sizeOfCell * 3,
      child: Stack(
          alignment: Alignment.center,
          fit: StackFit.loose,
          children: <Widget>[
            Positioned(
              top: 0 * _halfHeightOfCell,
              child: _buildLetterKey(letters[1]),
            ),
            Positioned(
              top: 1 * _halfHeightOfCell,
              child: _buildLetterKeyRow(letters[2] + letters[3]),
            ),
            Positioned(
              top: 2 * _halfHeightOfCell,
              child: _buildLetterKey(letters[0], isCentered: true),
            ),
            Positioned(
              top: 3 * _halfHeightOfCell,
              child: _buildLetterKeyRow(letters[4] + letters[5]),
            ),
            Positioned(
              top: 4 * _halfHeightOfCell,
              child: _buildLetterKey(letters[6]),
            )
          ]),
    );
  }

  Widget _buildLetterKeyRow(String letters) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: letters.split("").map(_buildLetterKey).toList());
  }

  Widget _buildLetterKey(String letter, {bool isCentered = false}) {
    return _LetterKey(
      letter: letter,
      isCentered: isCentered,
      size: widget.sizeOfCell,
      onLetterPressed: widget.onLetterPressed,
    );
  }
}

class _LetterKey extends StatefulWidget {
  final String letter;
  final bool isCentered;
  final double size;
  final void Function(String) onLetterPressed;

  const _LetterKey(
      {required this.letter,
      this.isCentered = false,
      required this.size,
      required this.onLetterPressed});

  @override
  State<_LetterKey> createState() => _LetterKeyState();
}

class _LetterKeyState extends State<_LetterKey>
    with SingleTickerProviderStateMixin {
  static const clickAnimationDurationMillis = 100;

  double _scaleTransformValue = 1;

  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: clickAnimationDurationMillis),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() => _scaleTransformValue = 1 - animationController.value);
      });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _shrinkButtonSize() {
    animationController.forward();
  }

  void _restoreButtonSize() {
    animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final centerColor = GameColors.beeWisePrimary;
    final outerColor =
        isDark ? const Color(0xFF3D3D54) : const Color(0xFFE8E8F0);
    final textColor =
        widget.isCentered ? Colors.black : theme.colorScheme.onSurface;

    return Padding(
      padding:
          EdgeInsets.only(left: widget.size * 0.4, right: widget.size * 0.4),
      child: GestureDetector(
        onTapDown: (_) => _shrinkButtonSize(),
        onTapCancel: _restoreButtonSize,
        child: ButtonTheme(
          height: widget.size,
          minWidth: widget.size,
          child: Transform.scale(
            scale: _scaleTransformValue,
            child: Container(
              height: widget.size,
              constraints: BoxConstraints(minWidth: widget.size),
              child: Material(
                color: Colors.transparent,
                clipBehavior: Clip.hardEdge,
                shape: PolygonBorder(
                  sides: 6,
                  borderRadius: 0.0,
                  rotate: 90.0,
                  side: BorderSide(
                    color: widget.isCentered
                        ? GameColors.beeWiseAccent
                        : (isDark ? Colors.white24 : Colors.black12),
                    width: 2,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () => widget.onLetterPressed(widget.letter),
                  style: ButtonStyle(
                    overlayColor: WidgetStatePropertyAll(
                      widget.isCentered
                          ? GameColors.beeWiseAccent.withValues(alpha: 0.3)
                          : (isDark ? Colors.white12 : Colors.black12),
                    ),
                    backgroundColor: WidgetStatePropertyAll(
                      widget.isCentered ? centerColor : outerColor,
                    ),
                  ),
                  child: Text(
                    widget.letter.toUpperCase(),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
