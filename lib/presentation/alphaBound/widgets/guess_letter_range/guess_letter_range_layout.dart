import 'package:flutter/material.dart';
import 'package:gameboy/presentation/alphaBound/widgets/guess_letter_range/animated_linear_progress_indicator.dart';
import 'package:gameboy/presentation/alphaBound/widgets/guess_letter_range/lower_bound.dart';
import 'package:gameboy/presentation/alphaBound/widgets/guess_letter_range/upper_bound.dart';

class GuessLetterRangeLayout extends StatelessWidget {
  final double _letterIndicatorSize;
  final String lowerBoundLetters;
  final String upperBoundLetters;
  final double proximityRatio;

  const GuessLetterRangeLayout(
      {super.key,
      required double letterSize,
      required this.proximityRatio,
      required this.lowerBoundLetters,
      required this.upperBoundLetters})
      : _letterIndicatorSize = letterSize * 0.8;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LowerBoundLetter(
          letterIndicatorSize: _letterIndicatorSize,
          lowerBoundLetters: lowerBoundLetters,
        ),
        Expanded(
          child: AnimatedWordOfTheDayProximityIndicator(
            proximityRatio: proximityRatio,
          ),
        ),
        UpperBoundLetter(
          letterIndicatorSize: _letterIndicatorSize,
          upperBoundLetters: upperBoundLetters,
        ),
      ],
    );
  }
}
