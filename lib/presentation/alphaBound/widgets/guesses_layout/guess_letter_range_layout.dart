import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/presentation/alphaBound/bloc/states.dart';
import 'package:gameboy/presentation/alphaBound/extensions.dart';
import 'package:gameboy/presentation/alphaBound/widgets/guesses_layout/animated_linear_progress_indicator.dart';
import 'package:gameboy/presentation/app/blocs/game/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game/states.dart';

class GuessLetterRangeLayout extends StatelessWidget {
  final double _letterIndicatorSize;
  static const _lettersIndicatorRadius = 12.0;

  const GuessLetterRangeLayout({super.key, required double letterSize})
      : _letterIndicatorSize = letterSize * 0.8;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      builder: (BuildContext context, GameState state) {
        var currentGameState = context.getGameEngineData().currentState;
        var lowerBoundStartLetters = currentGameState.lowerBound[0];
        var upperBoundStartLetters = currentGameState.upperBound[0];
        for (var index = 0;
            index < currentGameState.lowerBound.length;
            index++) {
          if (currentGameState.lowerBound[index] !=
              currentGameState.upperBound[index]) {
            lowerBoundStartLetters =
                currentGameState.lowerBound.substring(0, index + 1);
            upperBoundStartLetters =
                currentGameState.upperBound.substring(0, index + 1);
            break;
          }
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _createLowerBoundStartLetters(lowerBoundStartLetters, context),
            Expanded(
              child: AnimatedWordOfTheDayProximityIndicator(),
            ),
            _createUpperBoundStartLetters(upperBoundStartLetters, context),
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

  Widget _createLowerBoundStartLetters(
      String lowerBoundStartLetters, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: _letterIndicatorSize,
          height: _letterIndicatorSize,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(_lettersIndicatorRadius),
              topRight: Radius.circular(_lettersIndicatorRadius),
              bottomLeft: Radius.zero,
              bottomRight: Radius.zero,
            ),
          ),
          child: FittedBox(
            alignment: Alignment.center,
            child: Text(
              lowerBoundStartLetters.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        CustomPaint(
          painter: _RoundedRectangleWithDownArrowPainter(),
          child: SizedBox(
            width: _letterIndicatorSize,
            height: 20,
          ),
        ),
      ],
    );
  }

  Widget _createUpperBoundStartLetters(
      String upperBoundStartLetters, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomPaint(
          painter: _RoundedRectangleWithUpArrowPainter(),
          child: SizedBox(
            width: _letterIndicatorSize,
            height: 20,
          ),
        ),
        Container(
          width: _letterIndicatorSize,
          height: _letterIndicatorSize,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(
              topLeft: Radius.zero,
              topRight: Radius.zero,
              bottomLeft: Radius.circular(_lettersIndicatorRadius),
              bottomRight: Radius.circular(_lettersIndicatorRadius),
            ),
          ),
          child: FittedBox(
            alignment: Alignment.center,
            child: Text(
              upperBoundStartLetters.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge,
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
