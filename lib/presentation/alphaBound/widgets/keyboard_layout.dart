import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/alphaBound/models/game_status.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:gameboy/presentation/alphaBound/bloc/states.dart';
import 'package:gameboy/presentation/alphaBound/extensions.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_state.dart' as gameAppState;

class KeyboardLayout extends StatefulWidget {
  final Function(String letter)? onLetterPressed;
  final VoidCallback? onBackspacePressed;
  final VoidCallback? onEnterPressed;

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

  void _handleKeyEvent(KeyEvent keyEvent) {
    if (keyEvent is! KeyUpEvent) {
      return;
    }
    if (keyEvent.logicalKey.keyLabel.isNotEmpty &&
        keyEvent.logicalKey.keyLabel.length == 1 &&
        keyEvent.logicalKey.keyLabel.toUpperCase().contains(RegExp(r'[A-Z]'))) {
      widget.onLetterPressed?.call(keyEvent.logicalKey.keyLabel);
    } else if (keyEvent.logicalKey == LogicalKeyboardKey.backspace) {
      widget.onBackspacePressed?.call();
    } else if (keyEvent.logicalKey == LogicalKeyboardKey.enter) {
      widget.onEnterPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, gameAppState.GameState>(
      builder: (BuildContext context, gameAppState.GameState state) {
        var currentState = context.getCurrentAlphaBoundGameStatus();
        if (currentState is GameWon || currentState is GameLost) {
          return _createKeyBoardLayout(
              currentState.lowerBound, currentState.upperBound);
        }

        _focusNode.requestFocus();
        return KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: _createKeyBoardLayout(
              currentState.lowerBound, currentState.upperBound),
        );
      },
      listener: (BuildContext context, gameAppState.GameState state) {},
      buildWhen: (previousState, currentState) {
        return currentState is AlphaBoundGameState &&
            (currentState.gameStatus is GameWon ||
                currentState.gameStatus is GameLost);
      },
    );
  }

  Widget _createKeyBoardLayout(String lowerBound, String upperBound) {
    var firstRowWidgets = _firstRow
        .map((key) =>
            _buildLetterInputKey(context, key, 10, lowerBound, upperBound))
        .toList();
    var secondRowWidgets = _secondRow
        .map(
          (key) =>
              _buildLetterInputKey(context, key, 10, lowerBound, upperBound),
        )
        .toList();
    var thirdRowWidgets = _thirdRow
        .map((key) =>
            _buildLetterInputKey(context, key, 10, lowerBound, upperBound))
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
            context, Icons.backspace_rounded, 10, widget.onBackspacePressed));
    thirdRowWidgets.add(
        _buildActionLetterKey(context, 'Enter', 20, widget.onEnterPressed));
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

  Widget _buildActionLetterKey(
      BuildContext context, String keyName, int flex, VoidCallback? callBack) {
    return _buildActionInputKey(
        context,
        Text(
          keyName,
          style: TextStyle(color: Colors.white),
        ),
        flex,
        callBack);
  }

  Widget _buildActionIconKey(
      BuildContext context, IconData icon, int flex, VoidCallback? callBack) {
    return _buildActionInputKey(
        context,
        Icon(
          icon,
          size: 20,
        ),
        flex,
        callBack);
  }

  Widget _buildLetterInputKey(BuildContext context, String letter, int flex,
      String lowerBoundWord, String upperBoundWord) {
    var shouldHighlightLetter = letter.comparedTo(lowerBoundWord, false) >= 0 ||
        letter.comparedTo(upperBoundWord, false) <= 0;
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(5),
        color: shouldHighlightLetter ? Colors.white38 : Colors.white12,
        child: InkWell(
          onTap: () {
            widget.onLetterPressed?.call(letter);
          },
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                  color: shouldHighlightLetter ? Colors.black : Colors.green),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionInputKey(
      BuildContext context, Widget key, int flex, VoidCallback? callBack) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(5),
        color: Colors.white12,
        child: InkWell(
          onTap: () {
            callBack?.call();
          },
          child: Center(
            child: key,
          ),
        ),
      ),
    );
  }
}
