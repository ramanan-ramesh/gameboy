import 'package:flutter/material.dart';
import 'package:gameboy/presentation/spelling_bee/extensions.dart';

import 'polygon_border.dart';

class LetterInputLayout extends StatefulWidget {
  Function(String letter) onLetterPressed;
  final double sizeOfCell;
  LetterInputLayout(
      {super.key, required this.onLetterPressed, required this.sizeOfCell});

  @override
  State<LetterInputLayout> createState() => _LetterInputLayoutState();
}

class _LetterInputLayoutState extends State<LetterInputLayout> {
  double get _halfHeightOfCell => widget.sizeOfCell * 0.5;

  @override
  Widget build(BuildContext context) {
    String letters = context.getGameEngineData().lettersOfTheDay;

    return SizedBox(
      height: widget.sizeOfCell * 3,
      child: Stack(
          alignment: const Alignment(0, 0),
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
        children: letters
            .split("")
            .map((c) => _buildLetterKey(
                  c,
                ))
            .toList());
  }

  Widget _buildLetterKey(String letter, {bool isCentered = false}) {
    return _LetterKey(
      letter: letter,
      isCentered: isCentered,
      size: widget.sizeOfCell,
      onLetterPressed: () => widget.onLetterPressed(letter),
    );
  }
}

class _LetterKey extends StatefulWidget {
  String letter;
  bool isCentered;
  double size;
  VoidCallback onLetterPressed;
  _LetterKey(
      {super.key,
      required this.letter,
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

  // needed for the "click" tap effect
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
    Future.delayed(
      const Duration(milliseconds: clickAnimationDurationMillis),
      () => animationController.reverse(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  side: BorderSide.none,
                ),
                child: ElevatedButton(
                  onPressed: widget.onLetterPressed,
                  style: ButtonStyle(
                    overlayColor: WidgetStatePropertyAll(Colors.black12),
                    backgroundColor: WidgetStatePropertyAll(
                      widget.isCentered ? Colors.yellow : Colors.white70,
                    ),
                  ),
                  child: Text(widget.letter.toUpperCase(),
                      style: TextStyle(color: Colors.black, fontSize: 24)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
