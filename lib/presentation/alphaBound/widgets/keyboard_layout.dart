import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/alphaBound/models/game_status.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:gameboy/presentation/alphaBound/bloc/states.dart';
import 'package:gameboy/presentation/alphaBound/extensions.dart';
import 'package:gameboy/presentation/app/blocs/game/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game/states.dart'
    as gameAppState;
import 'package:gameboy/presentation/app/widgets/button.dart';

class KeyboardLayout extends StatefulWidget {
  final Function(String letter) onLetterPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback onEnterPressed;

  const KeyboardLayout(
      {super.key,
      required this.onLetterPressed,
      required this.onBackspacePressed,
      required this.onEnterPressed});

  @override
  State<KeyboardLayout> createState() => _KeyboardLayoutState();
}

class _KeyboardLayoutState extends State<KeyboardLayout> {
  static const _firstRow = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
  static const _secondRow = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
  static const _thirdRow = ['Z', 'X', 'C', 'V', 'B', 'N', 'M'];
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, gameAppState.GameState>(
      builder: (BuildContext context, gameAppState.GameState state) {
        var currentState = context.getCurrentAlphaBoundGameStatus();
        if (currentState is GameWon || currentState is GameLost) {
          return _createKeyBoardLayout(currentState, false);
        }

        _focusNode.requestFocus();
        return KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: _createKeyBoardLayout(currentState, true),
        );
      },
      listener: (BuildContext context, gameAppState.GameState state) {},
      buildWhen: (previousState, currentState) {
        return currentState is AlphaBoundGameState &&
            currentState.hasGameMovedAhead();
      },
    );
  }

  void _handleKeyEvent(KeyEvent keyEvent) {
    if (keyEvent is! KeyUpEvent) {
      return;
    }
    if (keyEvent.logicalKey.keyLabel.isNotEmpty &&
        keyEvent.logicalKey.keyLabel.length == 1 &&
        keyEvent.logicalKey.keyLabel.toUpperCase().contains(RegExp(r'[A-Z]'))) {
      widget.onLetterPressed.call(keyEvent.logicalKey.keyLabel);
    } else if (keyEvent.logicalKey == LogicalKeyboardKey.backspace) {
      widget.onBackspacePressed.call();
    } else if (keyEvent.logicalKey == LogicalKeyboardKey.enter) {
      widget.onEnterPressed.call();
    }
  }

  Widget _createKeyBoardLayout(
      AlphaBoundGameStatus alphaBoundGameStatus, bool listenToPress) {
    var firstRowWidgets = _firstRow
        .map((key) => _buildLetterInputKey(
            context,
            key,
            10,
            alphaBoundGameStatus.lowerBound,
            alphaBoundGameStatus.upperBound,
            listenToPress))
        .toList();
    var secondRowWidgets = _secondRow
        .map(
          (key) => _buildLetterInputKey(
              context,
              key,
              10,
              alphaBoundGameStatus.lowerBound,
              alphaBoundGameStatus.upperBound,
              listenToPress),
        )
        .toList();
    var thirdRowWidgets = _thirdRow
        .map((key) => _buildLetterInputKey(
            context,
            key,
            10,
            alphaBoundGameStatus.lowerBound,
            alphaBoundGameStatus.upperBound,
            listenToPress))
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
        _buildActionInputKey(
            context,
            const Icon(
              Icons.backspace_rounded,
              size: 20,
            ),
            10,
            listenToPress ? widget.onBackspacePressed : null));
    thirdRowWidgets.add(_buildActionInputKey(
        context,
        const Text(
          'Enter',
          style: TextStyle(color: Colors.white),
        ),
        20,
        listenToPress ? widget.onEnterPressed : null));
    return Container(
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
    );
  }

  Widget _buildLetterInputKey(BuildContext context, String letter, int flex,
      String lowerBoundWord, String upperBoundWord, bool listenToPress) {
    var shouldHighlightLetter =
        letter.comparedTo(lowerBoundWord[0], false) >= 0 ||
            letter.comparedTo(upperBoundWord[0], false) <= 0;
    return Expanded(
      flex: flex,
      child: AnimatedButton(
        onPressed: listenToPress
            ? () {
                widget.onLetterPressed(letter);
              }
            : null,
        color: shouldHighlightLetter ? Colors.white38 : Colors.white12,
        onPressedColor: shouldHighlightLetter ? Colors.white60 : Colors.white38,
        content: Text(
          letter,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildActionInputKey(
      BuildContext context, Widget key, int flex, VoidCallback? callBack) {
    return Expanded(
      flex: flex,
      child: AnimatedButton(
          onPressed: callBack,
          color: Colors.white12,
          onPressedColor: Colors.white38,
          content: key),
    );
  }
}
