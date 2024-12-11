import 'package:flutter/material.dart';
import 'package:gameboy/data/alphaBound/models/game_engine.dart';
import 'package:gameboy/presentation/alphaBound/extensions.dart';

class GuessLetterRangeLayout extends StatelessWidget {
  final double _rangeLetterIndicatorSize;
  const GuessLetterRangeLayout({super.key, required double letterSize})
      : _rangeLetterIndicatorSize = letterSize * 0.8;

  @override
  Widget build(BuildContext context) {
    var gameEngineData = context.getGameEngineData();
    var firstPossibleStartLetter = gameEngineData.currentState.lowerBound[0];
    var lastPossibleStartLetter = gameEngineData.currentState.upperBound[0];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _createFirstPossibleStartLetter(firstPossibleStartLetter),
        Expanded(
          child: _createDistanceIndicator(gameEngineData),
        ),
        _createLastPossibleStartLetter(lastPossibleStartLetter),
      ],
    );
  }

  Widget _createFirstPossibleStartLetter(String firstPossibleStartLetter) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: _rangeLetterIndicatorSize,
          height: _rangeLetterIndicatorSize,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.zero,
              bottomRight: Radius.zero,
            ),
          ),
          child: Center(
            child: Text(
              firstPossibleStartLetter.toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        CustomPaint(
          painter: _RoundedRectangleWithDownArrowPainter(),
          child: SizedBox(
            width: _rangeLetterIndicatorSize,
            height: 20,
          ),
        ),
      ],
    );
  }

  Stack _createDistanceIndicator(GameEngineData gameEngineData) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        RotatedBox(
          quarterTurns: 1,
          child: LinearProgressIndicator(
            value: gameEngineData.distanceOfWordOfTheDayFromBounds,
            backgroundColor: Colors.grey, // second half
            color: Colors.green, // first half
          ),
        ),
        if (gameEngineData.distanceOfWordOfTheDayFromBounds < 0.4)
          Positioned(
            top: 0,
            right: -30,
            child: Text(
              gameEngineData.distanceOfWordOfTheDayFromBounds >= 0.1
                  ? gameEngineData.distanceOfWordOfTheDayFromBounds
                      .toStringAsFixed(1)
                  : '0.1',
              style: TextStyle(color: Colors.white),
            ),
          ),
        if (gameEngineData.distanceOfWordOfTheDayFromBounds > 0.7)
          Positioned(
            bottom: 0,
            right: -30,
            child: Text(
              gameEngineData.distanceOfWordOfTheDayFromBounds > 0.9
                  ? '0.9'
                  : gameEngineData.distanceOfWordOfTheDayFromBounds
                      .toStringAsFixed(1),
              style: TextStyle(color: Colors.white),
            ),
          ),
        if (gameEngineData.distanceOfWordOfTheDayFromBounds >= 0.4 &&
            gameEngineData.distanceOfWordOfTheDayFromBounds <= 0.7)
          Positioned(
            top: 0,
            bottom: 0,
            right: -30,
            child: Center(
              child: Text(
                gameEngineData.distanceOfWordOfTheDayFromBounds
                    .toStringAsFixed(1),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _createLastPossibleStartLetter(String lastPossibleStartLetter) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomPaint(
          painter: _RoundedRectangleWithUpArrowPainter(),
          child: SizedBox(
            width: _rangeLetterIndicatorSize,
            height: 20,
          ),
        ),
        Container(
          width: _rangeLetterIndicatorSize,
          height: _rangeLetterIndicatorSize,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(
              topLeft: Radius.zero,
              topRight: Radius.zero,
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Center(
            child: Text(
              lastPossibleStartLetter.toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundedRectangleWithDownArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final Path downArrowPath = Path()
      ..lineTo(size.width, 0) // Right of the flat line
      ..lineTo(size.width / 2, size.height) // Bottom of the triangle
      ..lineTo(0, 0) // Left of the flat line
      ..close();

    canvas.drawPath(downArrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _RoundedRectangleWithUpArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final Path trianglePath = Path()
      ..moveTo(size.width / 2, 0) // Tip of the triangle
      ..lineTo(0, size.height) // Bottom-left of the triangle
      ..lineTo(size.width, size.height) // Bottom-right of the triangle
      ..close();

    canvas.drawPath(trianglePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
