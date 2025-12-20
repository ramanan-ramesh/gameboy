import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/blocs/alphaBound/states.dart';
import 'package:gameboy/blocs/game/bloc.dart';
import 'package:gameboy/blocs/game/states.dart' as gameAppState;
import 'package:gameboy/data/alphaBound/models/game_status.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:gameboy/presentation/alphaBound/extensions.dart';
import 'package:gameboy/presentation/app/theming/app_colors.dart';
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
        keyEvent.logicalKey.keyLabel.toUpperCase().contains(RegExp('[A-Z]'))) {
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
        Text(
          'Enter',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        20,
        listenToPress ? widget.onEnterPressed : null));

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final keyboardBg =
        isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF0F0F5);

    return ColoredBox(
      color: keyboardBg,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final highlightedColor =
        isDark ? const Color(0xFF2D2D44) : const Color(0xFFE0E0E8);
    final highlightedPressedColor =
        isDark ? const Color(0xFF3D3D54) : const Color(0xFFD0D0D8);
    final dimmedColor =
        isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF0F0F5);
    final dimmedPressedColor =
        isDark ? const Color(0xFF2D2D44) : const Color(0xFFE0E0E8);

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
        color: shouldHighlightLetter ? highlightedColor : dimmedColor,
        onPressedColor: shouldHighlightLetter
            ? highlightedPressedColor
            : dimmedPressedColor,
        content: Text(
          letter,
          style: TextStyle(
            color: shouldHighlightLetter
                ? GameColors.alphaBoundPrimary
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight:
                shouldHighlightLetter ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildActionInputKey(
      BuildContext context, Widget key, int flex, VoidCallback? callBack) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final actionKeyColor = isDark
        ? GameColors.alphaBoundPrimary.withValues(alpha: 0.3)
        : GameColors.alphaBoundPrimary.withValues(alpha: 0.2);
    final actionPressedColor = isDark
        ? GameColors.alphaBoundPrimary.withValues(alpha: 0.5)
        : GameColors.alphaBoundPrimary.withValues(alpha: 0.4);

    return Expanded(
      flex: flex,
      child: AnimatedButton(
          onPressed: callBack,
          color: actionKeyColor,
          onPressedColor: actionPressedColor,
          content: key),
    );
  }
}
