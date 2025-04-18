import 'package:flutter/material.dart';
import 'package:gameboy/data/wordsy/models/guess_letter.dart';
import 'package:gameboy/presentation/wordsy/widgets/extensions.dart';

class ShakingGuessLetter extends StatefulWidget {
  final GuessLetter guessLetter;
  final int indexOfGuessLetter;

  const ShakingGuessLetter(
      {super.key, required this.guessLetter, required this.indexOfGuessLetter});

  @override
  State<ShakingGuessLetter> createState() => _ShakingGuessLetterState();
}

class _ShakingGuessLetterState extends State<ShakingGuessLetter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    _animation = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0, 0), end: const Offset(0.3, 0)),
          weight: 15),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0.3, 0), end: const Offset(-0.3, 0)),
          weight: 10),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(-0.3, 0), end: const Offset(0.1, 0)),
          weight: 12),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0.1, 0), end: const Offset(-0.1, 0)),
          weight: 8),
      TweenSequenceItem(
          tween:
              Tween(begin: const Offset(-0.1, 0), end: const Offset(0.06, 0)),
          weight: 8),
      TweenSequenceItem(
          tween:
              Tween(begin: const Offset(0.06, 0), end: const Offset(-0.06, 0)),
          weight: 8),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(-0.06, 0), end: const Offset(0, 0)),
          weight: 8),
    ]).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: _buildGuessLetter(widget.guessLetter),
    );
  }

  Widget _buildGuessLetter(
    GuessLetter guessLetter,
  ) {
    return Container(
      color: guessLetter.getGuessTileBackgroundColor(),
      margin: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          guessLetter.guessLetter.toUpperCase(),
          style: TextStyle(color: guessLetter.getTextColor()),
        ),
      ),
    );
  }
}
