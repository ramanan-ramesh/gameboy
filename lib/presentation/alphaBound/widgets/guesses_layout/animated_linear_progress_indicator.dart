import 'package:flutter/material.dart';
import 'package:gameboy/presentation/alphaBound/extensions.dart';

class AnimatedWordOfTheDayProximityIndicator extends StatefulWidget {
  const AnimatedWordOfTheDayProximityIndicator({
    super.key,
  });

  @override
  _AnimatedWordOfTheDayProximityIndicatorState createState() =>
      _AnimatedWordOfTheDayProximityIndicatorState();
}

class _AnimatedWordOfTheDayProximityIndicatorState
    extends State<AnimatedWordOfTheDayProximityIndicator>
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
    var proximityRatio = context.getGameEngineData().wordOfTheDayProximityRatio;
    _animation = Tween<double>(begin: 0, end: proximityRatio)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    _controller.forward();
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            RotatedBox(
              quarterTurns: 1,
              child: Center(
                child: LinearProgressIndicator(
                  value: _animation.value,
                  backgroundColor: Colors.white,
                  color: Colors.green,
                ),
              ),
            ),
            if (_controller.isCompleted)
              _createProximityRatioText(proximityRatio),
          ],
        );
      },
    );
  }

  Widget _createProximityRatioText(double proximityRatio) {
    double? top, bottom;
    if (proximityRatio <= 0.3) {
      top = 0;
    } else if (proximityRatio <= 0.7) {
      top = 0;
      bottom = 0;
    } else {
      bottom = 0;
    }
    return Positioned(
      top: top,
      right: -30,
      bottom: bottom,
      child: Text(
        proximityRatio.toStringAsFixed(2),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
