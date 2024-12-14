import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/presentation/alphaBound/bloc/states.dart';
import 'package:gameboy/presentation/alphaBound/extensions.dart';
import 'package:gameboy/presentation/alphaBound/widgets/guesses_layout/animated_linear_progress_indicator.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_state.dart';

class GuessLetterRangeLayout extends StatelessWidget {
  final double _rangeLetterIndicatorSize;
  const GuessLetterRangeLayout({super.key, required double letterSize})
      : _rangeLetterIndicatorSize = letterSize * 0.8;

  @override
  Widget build(BuildContext context) {
    var gameEngineData = context.getGameEngineData();
    var firstPossibleStartLetter = gameEngineData.currentState.lowerBound[0];
    var lastPossibleStartLetter = gameEngineData.currentState.upperBound[0];
    return BlocConsumer<GameBloc, GameState>(
      builder: (BuildContext context, GameState state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _createFirstPossibleStartLetter(firstPossibleStartLetter),
            Expanded(
              child: AnimatedLinearProgressIndicator(),
            ),
            _createLastPossibleStartLetter(lastPossibleStartLetter),
          ],
        );
      },
      listener: (BuildContext context, GameState state) {},
      buildWhen: (previousState, currentState) {
        return (currentState is AlphaBoundGameState) &&
            currentState.hasGameMovedAhead();
      },
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
