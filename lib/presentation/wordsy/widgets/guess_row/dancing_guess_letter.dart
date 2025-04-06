import 'package:flutter/material.dart';
import 'package:gameboy/data/wordsy/models/guess_letter.dart';
import 'package:gameboy/presentation/wordsy/widgets/extensions.dart';

class DancingGuessLetter extends StatefulWidget {
  final GuessLetter guessLetter;
  final int indexOfGuessLetter;

  const DancingGuessLetter(
      {super.key, required this.guessLetter, required this.indexOfGuessLetter});

  @override
  State<DancingGuessLetter> createState() => _DancingGuessLetterState();
}

class _DancingGuessLetterState extends State<DancingGuessLetter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    _animation = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0, 0), end: const Offset(0, -0.80)),
          weight: 15),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0, -0.80), end: const Offset(0, 0)),
          weight: 10),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0, 0), end: const Offset(0, -0.30)),
          weight: 12),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0, -0.30), end: const Offset(0, 0)),
          weight: 8),
    ]).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 250 * widget.indexOfGuessLetter), () {
      if (mounted) {
        _controller.forward();
      }
    });
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
