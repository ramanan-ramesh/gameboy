import 'package:flutter/material.dart';

class UpperBoundLetter extends StatelessWidget {
  final double letterIndicatorSize;
  final String upperBoundLetters;
  static const _lettersIndicatorRadius = 12.0;
  const UpperBoundLetter({
    super.key,
    required this.letterIndicatorSize,
    required this.upperBoundLetters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomPaint(
          painter: _RoundedRectangleWithUpArrowPainter(),
          child: SizedBox(
            width: letterIndicatorSize,
            height: 20,
          ),
        ),
        Container(
          width: letterIndicatorSize,
          height: letterIndicatorSize,
          decoration: const BoxDecoration(
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
              upperBoundLetters.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      ],
    );
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
