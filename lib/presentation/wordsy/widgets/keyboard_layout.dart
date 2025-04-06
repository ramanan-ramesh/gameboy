import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:gameboy/data/wordsy/models/guess_letter.dart';
import 'package:gameboy/presentation/app/blocs/game/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game/states.dart';
import 'package:gameboy/presentation/app/widgets/button.dart';
import 'package:gameboy/presentation/wordsy/bloc/events.dart';
import 'package:gameboy/presentation/wordsy/bloc/states.dart';
import 'package:gameboy/presentation/wordsy/extensions.dart';
import 'package:gameboy/presentation/wordsy/widgets/extensions.dart';

class KeyboardLayout extends StatefulWidget {
  const KeyboardLayout({super.key});

  @override
  State<KeyboardLayout> createState() => _KeyboardLayoutState();
}

class _KeyboardLayoutState extends State<KeyboardLayout> {
  static const _firstRow = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
  static const _secondRow = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
  static const _thirdRow = ['Z', 'X', 'C', 'V', 'B', 'N', 'M'];
  final _focusNode = FocusNode();

  void _handleKeyEvent(KeyEvent keyEvent) {
    if (keyEvent is! KeyUpEvent) {
      return;
    }
    if (keyEvent.logicalKey.keyLabel.isNotEmpty &&
        keyEvent.logicalKey.keyLabel.length == 1 &&
        keyEvent.logicalKey.keyLabel.toUpperCase().contains(RegExp(r'[A-Z]'))) {
      context.addGameEvent(SubmitLetter(letter: keyEvent.logicalKey.keyLabel));
    } else if (keyEvent.logicalKey == LogicalKeyboardKey.backspace) {
      context.addGameEvent(RemoveLetter());
    } else if (keyEvent.logicalKey == LogicalKeyboardKey.enter) {
      context.addGameEvent(SubmitWord());
    }
  }

  @override
  Widget build(BuildContext context) {
    var allGuessedLetters = context.getGameEngineData().allGuessedLetters;
    var firstRowWidgets = _firstRow
        .map((key) => _buildLetterInputKey(context, key, 10, allGuessedLetters))
        .toList();
    var secondRowWidgets = _secondRow
        .map(
          (key) => _buildLetterInputKey(context, key, 10, allGuessedLetters),
        )
        .toList();
    var thirdRowWidgets = _thirdRow
        .map((key) => _buildLetterInputKey(context, key, 10, allGuessedLetters))
        .toList();
    secondRowWidgets.insert(
      0,
      Expanded(
        flex: 5,
        child: Container(),
      ),
    );
    secondRowWidgets.add(
      Expanded(
        flex: 5,
        child: Container(),
      ),
    );

    thirdRowWidgets.insert(
        0,
        _buildActionIconKey(
            context, Icons.backspace_rounded, 10, RemoveLetter()));
    thirdRowWidgets
        .add(_buildActionLetterKey(context, SubmitWord(), 'Enter', 20));
    _focusNode.requestFocus();
    return KeyboardListener(
      //TODO: Make this entire widget an independent BlocConsumer, and KeyBoardListener should be a child of the BlocConsumer. Child of BlocConsumer should not be a KeyBoardListener if game is lost or won, and should be a normal layout instead.
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: BlocListener<GameBloc, GameState>(
        listener: (BuildContext context, GameState state) {
          if (state is GuessWordSubmitted ||
              state is GameWon ||
              state is GameLost) {
            Future.delayed(Duration(seconds: 6), () {
              if (mounted) {
                setState(() {});
              }
            });
          }
        },
        child: Container(
          color: Colors.white12,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: firstRowWidgets,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: secondRowWidgets,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: thirdRowWidgets,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionLetterKey(
      BuildContext context, WordsyEvent actionEvent, String keyName, int flex) {
    return _buildActionInputKey(
        context,
        actionEvent,
        Text(
          keyName,
          style: TextStyle(color: Colors.white),
        ),
        flex);
  }

  Widget _buildActionIconKey(
      BuildContext context, IconData icon, int flex, WordsyEvent event) {
    return _buildActionInputKey(
        context,
        event,
        Icon(
          icon,
          size: 20,
        ),
        flex);
  }

  Widget _buildLetterInputKey(BuildContext context, String letter, int flex,
      Iterable<GuessLetter> allGuessLetters) {
    var alreadyGuessedLetter = allGuessLetters
        .where((guessLetter) => guessLetter.guessLetter.isEqualTo(letter))
        .firstOrNull;
    return Expanded(
      flex: flex,
      child: AnimatedButton(
        color: alreadyGuessedLetter == null
            ? Colors.white38
            : alreadyGuessedLetter.getKeyboardTileBackgroundColor(),
        onPressedColor: alreadyGuessedLetter == null
            ? Colors.white60
            : alreadyGuessedLetter.getKeyboardTilePressedColor(),
        content: Text(
          letter,
          style: TextStyle(
              color: alreadyGuessedLetter == null
                  ? Colors.white
                  : alreadyGuessedLetter.getTextColor()),
        ),
        onPressed: () {
          context.addGameEvent(SubmitLetter(letter: letter));
        },
      ),
    );
  }

  Widget _buildActionInputKey(
      BuildContext context, WordsyEvent actionEvent, Widget key, int flex) {
    return Expanded(
      flex: flex,
      child: AnimatedButton(
        content: key,
        color: Colors.white12,
        onPressedColor: Colors.white38,
        onPressed: () {
          context.addGameEvent(actionEvent);
        },
      ),
    );
  }
}
