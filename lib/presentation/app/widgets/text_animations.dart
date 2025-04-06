import 'package:flutter/material.dart';

class Shake extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const Shake({required this.text, this.style, Key? key}) : super(key: key);

  @override
  _ShakeState createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _animation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: -2.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -2.0, end: 2.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 2.0, end: 0.0), weight: 1),
    ]).animate(_controller);

    _controller.forward().then((_) => _controller.stop());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: Text(widget.text,
              style: widget.style?.copyWith(
                shadows: [
                  Shadow(
                    offset: Offset(2.0, 2.0),
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              )),
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

class Blink extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const Blink({required this.text, this.style, Key? key}) : super(key: key);

  @override
  _BlinkState createState() => _BlinkState();
}

class _BlinkState extends State<Blink> {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() => _opacity = 0.0);
    });
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() => _opacity = 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 400),
      opacity: _opacity,
      child: Text(widget.text, style: widget.style),
    );
  }
}

class Bounce extends StatelessWidget {
  final String text;
  final TextStyle style;

  const Bounce({required this.text, required this.style, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(seconds: 1),
      curve: Curves.bounceOut,
      tween: Tween(begin: 20.0, end: -20.0)
        ..chain(Tween(begin: -20.0, end: 15.0))
        ..chain(Tween(begin: 15.0, end: -15.0))
        ..chain(Tween(begin: -15.0, end: 10.0))
        ..chain(Tween(begin: 10.0, end: -10.0))
        ..chain(Tween(begin: 5.0, end: -5.0))
        ..chain(Tween(begin: -5.0, end: 0)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: Text(text, style: style),
        );
      },
    );
  }
}

class Scale extends StatelessWidget {
  final String text;
  final TextStyle style;

  const Scale({required this.text, required this.style, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500),
      tween: Tween(begin: 0.5, end: 1.2),
      curve: Curves.bounceOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Text(text, style: style),
        );
      },
      onEnd: () => Future.delayed(Duration(milliseconds: 100), () {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 500),
          tween: Tween(begin: 1.2, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Text(text, style: style),
            );
          },
        );
      }),
    );
  }
}

class ExpandAndShrink extends StatefulWidget {
  final String text;
  final Color? containerColor;
  final TextStyle style;

  const ExpandAndShrink(
      {required this.text, required this.style, Key? key, this.containerColor})
      : super(key: key);

  @override
  _ExpandAndShrinkState createState() => _ExpandAndShrinkState();
}

class _ExpandAndShrinkState extends State<ExpandAndShrink>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 0.7), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 0.6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 0.4), weight: 1),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: MediaQuery.of(context).size.width * _animation.value,
            color: widget.containerColor,
            child: Text(widget.text,
                style: widget.style, textAlign: TextAlign.left),
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

class Rainbow extends StatefulWidget {
  final String text;
  final TextStyle? style;
  const Rainbow({required this.text, Key? key, this.style}) : super(key: key);

  @override
  _RainbowState createState() => _RainbowState();
}

class _RainbowState extends State<Rainbow> {
  Color _color = Colors.red;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted) setState(() => _color = Colors.blue);
    });
    Future.delayed(Duration(milliseconds: 400), () {
      if (mounted) setState(() => _color = Colors.green);
    });
    Future.delayed(Duration(milliseconds: 600), () {
      if (mounted) setState(() => _color = Colors.pink);
    });
    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted) setState(() => _color = Colors.orange);
    });
    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _color = Colors.purple);
    });
    Future.delayed(Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _color = Colors.yellow);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: Duration(milliseconds: 200),
      style: (widget.style ?? TextStyle()).copyWith(
        color: _color,
      ),
      child: Text(
        widget.text,
      ),
    );
  }
}

class PopIn extends StatefulWidget {
  final String text;
  final TextStyle? style;
  PopIn({required this.text, this.style, Key? key}) : super(key: key);

  @override
  _PopInState createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    // _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Text(widget.text, style: widget.style),
    );
  }
}
