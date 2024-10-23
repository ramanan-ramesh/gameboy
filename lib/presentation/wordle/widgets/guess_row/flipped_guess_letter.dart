import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gameboy/data/wordle/models/guess_letter.dart';
import 'package:gameboy/presentation/extensions.dart';

class FlippedGuessLetter extends StatefulWidget {
  final GuessLetter guessLetter;
  final int indexOfGuessLetter;
  const FlippedGuessLetter(
      {super.key, required this.guessLetter, required this.indexOfGuessLetter});

  @override
  State<FlippedGuessLetter> createState() => _FlippedGuessLetterState();
}

class _FlippedGuessLetterState extends State<FlippedGuessLetter>
    with SingleTickerProviderStateMixin {
  bool _shouldAnimate = false;

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: widget.indexOfGuessLetter), () {
      if (mounted && !_shouldAnimate) {
        setState(() {
          _shouldAnimate = true;
        });
      }
    });
    return AnimatedSwitcher(
      duration: Duration(seconds: 1),
      transitionBuilder: _transitionBuilder,
      layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
      switchInCurve: Curves.easeInBack,
      switchOutCurve: Curves.easeInBack.flipped,
      child: _buildGuessLetter(widget.guessLetter),
    );
  }

  Widget _transitionBuilder(Widget childWidget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
      animation: rotateAnim,
      child: childWidget,
      builder: (context, widget) {
        final isUnder = (ValueKey(_shouldAnimate) != widget?.key);
        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
        tilt *= isUnder ? -1.0 : 1.0;
        final value =
            isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
        return Transform(
          transform: (Matrix4.rotationX(value)..setEntry(3, 1, tilt)),
          alignment: Alignment.center,
          child: widget,
        );
      },
    );
  }

  Widget _buildGuessLetter(
    GuessLetter guessLetter,
  ) {
    return Container(
      color: !_shouldAnimate
          ? Colors.white12
          : guessLetter.getGuessTileBackgroundColor(),
      key: ValueKey(!_shouldAnimate),
      margin: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          guessLetter.guessLetter.toUpperCase(),
          style: TextStyle(
              color:
                  !_shouldAnimate ? Colors.white : guessLetter.getTextColor()),
        ),
      ),
    );
  }
}
