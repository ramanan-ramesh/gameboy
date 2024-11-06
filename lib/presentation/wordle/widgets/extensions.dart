import 'package:flutter/material.dart';
import 'package:gameboy/data/wordle/models/guess_letter.dart';
import 'package:gameboy/data/wordle/models/letter_match_description.dart';

extension GuessLetterExt on GuessLetter {
  Color getTextColor() {
    switch (letterMatchDescription) {
      case LetterMatchDescription.notYetMatched:
      case LetterMatchDescription.inWordRightPosition:
      case LetterMatchDescription.notInWord:
        return Colors.white;
      case LetterMatchDescription.inWordWrongPosition:
        return Colors.black;
    }
  }

  Color getGuessTileBackgroundColor() {
    switch (letterMatchDescription) {
      case LetterMatchDescription.notYetMatched:
      case LetterMatchDescription.notInWord:
        return Colors.white12;
      case LetterMatchDescription.inWordRightPosition:
        return Colors.green;
      case LetterMatchDescription.inWordWrongPosition:
        return Colors.yellow;
    }
  }

  Color getKeyboardTileBackgroundColor() {
    switch (letterMatchDescription) {
      case LetterMatchDescription.notYetMatched:
        return Colors.white12;
      case LetterMatchDescription.notInWord:
        return Colors.black12;
      case LetterMatchDescription.inWordRightPosition:
        return Colors.green;
      case LetterMatchDescription.inWordWrongPosition:
        return Colors.yellow;
    }
  }
}
