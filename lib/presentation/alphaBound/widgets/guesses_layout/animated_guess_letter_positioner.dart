import 'package:flutter/material.dart';

class AnimatedGuessLetterPositioner extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final double letterSize;
  final int index;
  final String letter;

  const AnimatedGuessLetterPositioner(
      {required this.startPosition,
      required this.endPosition,
      required this.letter,
      required this.letterSize,
      required this.index});

  @override
  _AnimatedGuessLetterPositionerState createState() =>
      _AnimatedGuessLetterPositionerState();
}

class _AnimatedGuessLetterPositionerState
    extends State<AnimatedGuessLetterPositioner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    Future.delayed(Duration(milliseconds: (widget.index * 250) + 250), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Material(
            child: Container(
              width: widget.letterSize,
              height: widget.letterSize,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Center(
                child: Text(
                  widget.letter.toUpperCase(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: widget.letterSize / 2,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
