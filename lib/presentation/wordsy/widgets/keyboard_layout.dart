import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/blocs/game/bloc.dart';
import 'package:gameboy/blocs/game/states.dart';
import 'package:gameboy/blocs/wordsy/events.dart';
import 'package:gameboy/blocs/wordsy/states.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:gameboy/data/wordsy/models/guess_letter.dart';
import 'package:gameboy/presentation/app/theming/app_colors.dart';
import 'package:gameboy/presentation/app/widgets/button.dart';
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
        keyEvent.logicalKey.keyLabel.toUpperCase().contains(RegExp('[A-Z]'))) {
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
            Future.delayed(const Duration(seconds: 6), () {
              if (mounted) {
                setState(() {});
              }
            });
          }
        },
        child: Builder(
          builder: (context) {
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
          },
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
          style: const TextStyle(color: Colors.white),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultKeyColor =
        isDark ? const Color(0xFF2D2D44) : const Color(0xFFE0E0E8);
    final defaultPressedColor =
        isDark ? const Color(0xFF3D3D54) : const Color(0xFFD0D0D8);
    final defaultTextColor = theme.colorScheme.onSurface;

    var alreadyGuessedLetter = allGuessLetters
        .where((guessLetter) => guessLetter.guessLetter.isEqualTo(letter))
        .firstOrNull;
    return Expanded(
      flex: flex,
      child: AnimatedButton(
        color: alreadyGuessedLetter == null
            ? defaultKeyColor
            : alreadyGuessedLetter.getKeyboardTileBackgroundColor(),
        onPressedColor: alreadyGuessedLetter == null
            ? defaultPressedColor
            : alreadyGuessedLetter.getKeyboardTilePressedColor(),
        content: Text(
          letter,
          style: TextStyle(
              color: alreadyGuessedLetter == null
                  ? defaultTextColor
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final actionKeyColor = isDark
        ? GameColors.wordsyPrimary.withValues(alpha: 0.3)
        : GameColors.wordsyPrimary.withValues(alpha: 0.2);
    final actionPressedColor = isDark
        ? GameColors.wordsyPrimary.withValues(alpha: 0.5)
        : GameColors.wordsyPrimary.withValues(alpha: 0.4);

    return Expanded(
      flex: flex,
      child: AnimatedButton(
        content: key,
        color: actionKeyColor,
        onPressedColor: actionPressedColor,
        onPressed: () {
          context.addGameEvent(actionEvent);
        },
      ),
    );
  }
}
