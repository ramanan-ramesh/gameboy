import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/wordle/models/extensions.dart';
import 'package:gameboy/data/wordle/models/guess_letter.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_state.dart';
import 'package:gameboy/presentation/wordle/bloc/events.dart';
import 'package:gameboy/presentation/wordle/bloc/states.dart';
import 'package:gameboy/presentation/wordle/extensions.dart';
import 'package:gameboy/presentation/wordle/widgets/extensions.dart';

class KeyboardLayout extends StatefulWidget {
  const KeyboardLayout({super.key});

  @override
  State<KeyboardLayout> createState() => _KeyboardLayoutState();
}

class _KeyboardLayoutState extends State<KeyboardLayout> {
  static const _firstRow = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
  static const _secondRow = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
  static const _thirdRow = ['Z', 'X', 'C', 'V', 'B', 'N', 'M'];

  void _handleKeyEvent(KeyEvent keyEvent) {
    if (context.getCurrentWordleState() is ShowStats) {
      return;
    }
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
        child: Container(),
        flex: 5,
      ),
    );
    secondRowWidgets.add(
      Expanded(
        child: Container(),
        flex: 5,
      ),
    );

    thirdRowWidgets.insert(
        0,
        _buildActionIconKey(
            context, Icons.backspace_rounded, 10, RemoveLetter()));
    thirdRowWidgets
        .add(_buildActionLetterKey(context, SubmitWord(), 'Enter', 20));
    return KeyboardListener(
      focusNode: FocusNode(),
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
      BuildContext context, WordleEvent actionEvent, String keyName, int flex) {
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
      BuildContext context, IconData icon, int flex, WordleEvent event) {
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
      child: Container(
        margin: const EdgeInsets.all(5),
        color: alreadyGuessedLetter == null
            ? Colors.white12
            : alreadyGuessedLetter.getKeyboardTileBackgroundColor(),
        child: InkWell(
          onTap: () {
            context.addGameEvent(SubmitLetter(letter: letter));
          },
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                  color: alreadyGuessedLetter == null
                      ? Colors.white
                      : alreadyGuessedLetter.getTextColor()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionInputKey(
      BuildContext context, WordleEvent actionEvent, Widget key, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(5),
        color: Colors.white12,
        child: InkWell(
          onTap: () {
            context.addGameEvent(actionEvent);
          },
          child: Center(
            child: key,
          ),
        ),
      ),
    );
  }
}
