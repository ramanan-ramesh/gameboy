import 'package:flutter/material.dart';
import 'package:gameboy/data/wordsy/models/guess_letter.dart';
import 'package:gameboy/data/wordsy/models/letter_match_description.dart';

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
        return Colors.green;
      case LetterMatchDescription.wrongPositionInWord:
        return Colors.yellow;
    }
  }

  Color getKeyboardTileBackgroundColor() {
    switch (letterMatchDescription) {
      case LetterMatchDescription.notYetMatched:
        return Colors.white12;
      case LetterMatchDescription.notInWord:
        return Colors.black12;
      case LetterMatchDescription.rightPositionInWord:
        return Colors.green;
      case LetterMatchDescription.wrongPositionInWord:
        return Colors.yellow;
    }
  }

  Color getKeyboardTilePressedColor() {
    switch (letterMatchDescription) {
      case LetterMatchDescription.notYetMatched:
        return Colors.white38;
      case LetterMatchDescription.notInWord:
        return Colors.white12;
      case LetterMatchDescription.rightPositionInWord:
        return Colors.green.shade300;
      case LetterMatchDescription.wrongPositionInWord:
        return Colors.yellow.shade300;
    }
  }
}
