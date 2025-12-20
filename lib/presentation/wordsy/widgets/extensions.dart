import 'package:flutter/material.dart';
import 'package:gameboy/data/wordsy/models/guess_letter.dart';
import 'package:gameboy/data/wordsy/models/letter_match_description.dart';
import 'package:gameboy/presentation/app/theming/app_colors.dart';

extension GuessLetterExt on GuessLetter {
  Color getTextColor() {
    switch (letterMatchDescription) {
      case LetterMatchDescription.notYetMatched:
      case LetterMatchDescription.rightPositionInWord:
      case LetterMatchDescription.notInWord:
        return Colors.white;
      case LetterMatchDescription.wrongPositionInWord:
        return Colors.black;
    }
  }

  Color getGuessTileBackgroundColor() {
    switch (letterMatchDescription) {
      case LetterMatchDescription.notYetMatched:
      case LetterMatchDescription.notInWord:
        return Colors.white12;
      case LetterMatchDescription.rightPositionInWord:
        return GameColors.wordsyPrimary;
      case LetterMatchDescription.wrongPositionInWord:
        return GameColors.beeWisePrimary; // Yellow/amber for wrong position
    }
  }

  Color getKeyboardTileBackgroundColor() {
    switch (letterMatchDescription) {
      case LetterMatchDescription.notYetMatched:
        return Colors.white12;
      case LetterMatchDescription.notInWord:
        return Colors.black26;
      case LetterMatchDescription.rightPositionInWord:
        return GameColors.wordsyPrimary;
      case LetterMatchDescription.wrongPositionInWord:
        return GameColors.beeWisePrimary;
    }
  }

  Color getKeyboardTilePressedColor() {
    switch (letterMatchDescription) {
      case LetterMatchDescription.notYetMatched:
        return Colors.white38;
      case LetterMatchDescription.notInWord:
        return Colors.white12;
      case LetterMatchDescription.rightPositionInWord:
        return GameColors.wordsySecondary;
      case LetterMatchDescription.wrongPositionInWord:
        return GameColors.beeWiseSecondary;
    }
  }
}
