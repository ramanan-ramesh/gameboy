import 'package:flutter/material.dart';

class LowerBoundLetter extends StatelessWidget {
  final double letterIndicatorSize;
  final String lowerBoundLetters;
  static const _lettersIndicatorRadius = 12.0;
  const LowerBoundLetter({
    super.key,
    required this.letterIndicatorSize,
    required this.lowerBoundLetters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: letterIndicatorSize,
          height: letterIndicatorSize,
          decoration: const BoxDecoration(
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
              lowerBoundLetters.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        CustomPaint(
          painter: _RoundedRectangleWithDownArrowPainter(),
          child: SizedBox(
            width: letterIndicatorSize,
            height: 20,
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
