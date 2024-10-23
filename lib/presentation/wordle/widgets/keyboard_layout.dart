import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/wordle/models/extensions.dart';
import 'package:gameboy/data/wordle/models/guess_letter.dart';
import 'package:gameboy/presentation/extensions.dart';
import 'package:gameboy/presentation/wordle/bloc/bloc.dart';
import 'package:gameboy/presentation/wordle/bloc/events.dart';
import 'package:gameboy/presentation/wordle/bloc/extensions.dart';
import 'package:gameboy/presentation/wordle/bloc/states.dart';

class KeyboardLayout extends StatefulWidget {
  const KeyboardLayout({super.key});

  @override
  State<KeyboardLayout> createState() => _KeyboardLayoutState();
}

class _KeyboardLayoutState extends State<KeyboardLayout> {
  static const _firstRow = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
  static const _secondRow = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
  static const _thirdRow = ['Z', 'X', 'C', 'V', 'B', 'N', 'M'];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WordleGameBloc, WordleState>(
      buildWhen: (previousState, currentState) {
        return false;
      },
      builder: (BuildContext context, WordleState state) {
        var allGuessedLetters = context.getGameEngineData().allGuessedLetters;
        var firstRowWidgets = _firstRow
            .map((key) =>
                _buildLetterInputKey(context, key, 10, allGuessedLetters))
            .toList();
        var secondRowWidgets = _secondRow
            .map(
              (key) =>
                  _buildLetterInputKey(context, key, 10, allGuessedLetters),
            )
            .toList();
        var thirdRowWidgets = _thirdRow
            .map((key) =>
                _buildLetterInputKey(context, key, 10, allGuessedLetters))
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
                context, Icons.backspace_rounded, 10, KeyType.backspace));
        thirdRowWidgets
            .add(_buildActionLetterKey(context, KeyType.enter, 'Enter', 20));

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
      },
      listener: (BuildContext context, WordleState state) {
        if (state is GuessWordSubmitted ||
            state is GameWon ||
            state is GameLost) {
          Future.delayed(Duration(seconds: 6), () {
            setState(() {});
          });
        }
      },
    );
  }

  Widget _buildActionLetterKey(
      BuildContext context, KeyType keyType, String keyName, int flex) {
    return _buildActionInputKey(
        context,
        keyType,
        Text(
          keyName,
          style: TextStyle(color: Colors.white),
        ),
        flex);
  }

  Widget _buildActionIconKey(
      BuildContext context, IconData icon, int flex, KeyType keyType) {
    return _buildActionInputKey(
        context,
        keyType,
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
      BuildContext context, KeyType keyType, Widget key, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(5),
        color: Colors.black12,
        child: InkWell(
          onTap: () {
            context.addGameEvent(SubmitKey(key: keyType));
          },
          child: Center(
            child: key,
          ),
        ),
      ),
    );
  }
}
