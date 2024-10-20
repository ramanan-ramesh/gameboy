import 'package:flutter/material.dart';
import 'package:gameboy/presentation/wordle/widgets/game_bar.dart';
import 'package:gameboy/presentation/wordle/widgets/guesses_layout.dart';
import 'package:gameboy/presentation/wordle/widgets/keyboard_layout.dart';

class GameLayout extends StatelessWidget {
  static const _maxWidth = 700.0;
  static const _minHeight = 500.0;

  const GameLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > _maxWidth) {
          if (constraints.maxHeight < _minHeight) {
            return Scaffold(
              appBar: GameBar(
                contentWidth: _maxWidth,
              ),
              body: SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: _maxWidth,
                    height: _minHeight,
                    child: _buildGameLayout(context, true),
                  ),
                ),
              ),
            );
          } else {
            return Scaffold(
              appBar: GameBar(
                contentWidth: _maxWidth,
              ),
              body: Center(
                child: SizedBox(
                  width: _maxWidth,
                  height: constraints.maxHeight,
                  child: _buildGameLayout(context, true),
                ),
              ),
            );
          }
        } else {
          if (constraints.maxHeight < _minHeight) {
            return Scaffold(
              appBar: GameBar(),
              body: SingleChildScrollView(
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: _minHeight,
                  child: _buildGameLayout(context, false),
                ),
              ),
            );
          } else {
            return Scaffold(
              appBar: GameBar(),
              body: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: _buildGameLayout(context, false),
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildGameLayout(BuildContext context, bool isConstrainedWidth) {
    return Column(
      children: [
        Expanded(
          flex: 7,
          child: GuessesLayout(),
        ),
        Expanded(
          flex: 3,
          child: KeyboardLayout(),
        ),
      ],
    );
  }
}
