import 'package:flutter/material.dart';
import 'package:gameboy/presentation/alphaBound/extensions.dart';

class AnimatedLinearProgressIndicator extends StatelessWidget {
  const AnimatedLinearProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    var gameEngineData = context.getGameEngineData();
    return _LinearProgressIndicator(
        distanceOfWordOfTheDayFromBounds:
            gameEngineData.distanceOfWordOfTheDayFromBounds);
  }
}

class _LinearProgressIndicator extends StatefulWidget {
  final double distanceOfWordOfTheDayFromBounds;
  const _LinearProgressIndicator(
      {Key? key, required this.distanceOfWordOfTheDayFromBounds})
      : super(key: key);

  @override
  _AnimatedLinearProgressIndicatorState createState() =>
      _AnimatedLinearProgressIndicatorState();
}

class _AnimatedLinearProgressIndicatorState
    extends State<_LinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _animation = Tween<double>(
            begin: 0, end: widget.distanceOfWordOfTheDayFromBounds)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            RotatedBox(
              quarterTurns: 1,
              child: Container(
                height: 10,
                child: Stack(
                  children: [
                    Center(
                      child: LinearProgressIndicator(
                        value: _animation.value,
                        backgroundColor: Colors.white,
                        color: Colors.green,
                      ),
                    ),
                    Positioned(
                      //TODO: This is not positioning on the _animation.value
                      top: 0,
                      bottom: 0,
                      left:
                          _animation.value * MediaQuery.of(context).size.width -
                              7.5,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_controller.isCompleted)
              if (widget.distanceOfWordOfTheDayFromBounds <= 0.3)
                Positioned(
                  top: 0,
                  right: -30,
                  child: Text(
                    widget.distanceOfWordOfTheDayFromBounds.toStringAsFixed(2),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            if (_controller.isCompleted)
              if (widget.distanceOfWordOfTheDayFromBounds >= 0.8)
                Positioned(
                  bottom: 0,
                  right: -30,
                  child: Text(
                    widget.distanceOfWordOfTheDayFromBounds.toStringAsFixed(2),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            if (_controller.isCompleted)
              if (widget.distanceOfWordOfTheDayFromBounds > 0.3 &&
                  widget.distanceOfWordOfTheDayFromBounds < 0.8)
                Positioned(
                  //TODO: This is not positioning as vertically centered
                  top: 0,
                  bottom: 0,
                  right: -30,
                  child: Text(
                    widget.distanceOfWordOfTheDayFromBounds.toStringAsFixed(2),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
          ],
        );
      },
    );
  }
}
