import 'package:flutter/material.dart';

class AnimatedGuessLetterPositioner extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final double letterSize;
  final int index;
  final String letter;

  const AnimatedGuessLetterPositioner(
      {super.key,
      required this.startPosition,
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

class AnimatedGuessLetterDancer extends StatefulWidget {
  final double letterSize;
  final String letter;
  final bool didWinGame;

  const AnimatedGuessLetterDancer(
      {super.key,
      required this.letterSize,
      required this.letter,
      required this.didWinGame});

  @override
  State<AnimatedGuessLetterDancer> createState() =>
      _AnimatedGuessLetterDancerState();
}

class _AnimatedGuessLetterDancerState extends State<AnimatedGuessLetterDancer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -0.2, end: 0.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.2, end: -0.2), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationZ(_animation.value),
          child: child,
        );
      },
      child: _buildGuessLetter(widget.letter),
    );
  }

  Widget _buildGuessLetter(
    String guessLetter,
  ) {
    return Container(
      width: widget.letterSize,
      height: widget.letterSize,
      decoration: BoxDecoration(
        color: widget.didWinGame ? Colors.green : Colors.red,
      ),
      child: Center(
        child: Text(
          widget.letter.toUpperCase(),
          style: TextStyle(
            color: widget.didWinGame ? Colors.black : Colors.white,
            fontSize: widget.letterSize / 2,
          ),
        ),
      ),
    );
  }
}

class AnimatedGuessLetterShaker extends StatefulWidget {
  final double letterSize;
  final int index;
  final String letter;

  const AnimatedGuessLetterShaker(
      {super.key,
      required this.letterSize,
      required this.index,
      required this.letter});

  @override
  State<AnimatedGuessLetterShaker> createState() =>
      _AnimatedGuessLetterShakerState();
}

class _AnimatedGuessLetterShakerState extends State<AnimatedGuessLetterShaker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    _animation = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0, 0), end: const Offset(-50, 0)),
          weight: 15),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(-50, 0), end: const Offset(50, 0)),
          weight: 10),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(50, 0), end: const Offset(-30, 0)),
          weight: 12),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(-30, 0), end: const Offset(30, 0)),
          weight: 8),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(30, 0), end: const Offset(00, 0)),
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
    Future.delayed(Duration(milliseconds: 250 * widget.index), () {
      if (mounted) {
        _controller.forward();
      }
    });
    return SlideTransition(
      position: _animation,
      child: _buildGuessLetter(widget.letter),
    );
  }

  Widget _buildGuessLetter(
    String guessLetter,
  ) {
    return Container(
      width: widget.letterSize,
      height: widget.letterSize,
      decoration: BoxDecoration(
        color: Colors.red,
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
    );
  }
}

class ShakingGuessLetter extends StatefulWidget {
  final String letter;
  final double letterSize;

  ShakingGuessLetter(
      {super.key, required this.letter, required this.letterSize});

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
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Container(
        key: widget.key,
        width: widget.letterSize,
        height: widget.letterSize,
        decoration: BoxDecoration(
          color: Colors.red,
          border: Border.all(color: Colors.black),
        ),
        child: Center(
          child: Text(
            widget.letter.toUpperCase(),
            style:
                TextStyle(fontSize: widget.letterSize / 2, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
