import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/alphaBound/models/constants.dart';
import 'package:gameboy/data/alphaBound/models/game_state.dart';
import 'package:gameboy/presentation/alphaBound/bloc/states.dart';
import 'package:gameboy/presentation/alphaBound/extensions.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_state.dart' as appGameState;

import 'animated_guess_letters.dart';

class GuessWordRangeLayout extends StatefulWidget {
  final double letterSize;
  final ValueNotifier<String> guessLetterValueNotifier;

  GuessWordRangeLayout(
      {super.key,
      required this.letterSize,
      required this.guessLetterValueNotifier});

  @override
  State<GuessWordRangeLayout> createState() => _GuessWordRangeLayoutState();
}

class _GuessWordRangeLayoutState extends State<GuessWordRangeLayout> {
  static const _rowPaddingOnEachSide = 4.0;
  final List<GlobalKey> _lowerBoundLetterSlotsKeys = List.generate(
      AlphaBoundConstants.numberOfLettersInGuess,
      (index) => GlobalKey(debugLabel: 'lowerBoundLetterSlot$index'));

  final List<GlobalKey> _guessRowLetterSlotsKeys = List.generate(
      AlphaBoundConstants.numberOfLettersInGuess,
      (index) => GlobalKey(debugLabel: 'guessRowLetterSlot$index'));

  final List<GlobalKey> _upperBoundLetterSlotsKeys = List.generate(
      AlphaBoundConstants.numberOfLettersInGuess,
      (index) => GlobalKey(debugLabel: 'upperBoundLetterSlot$index'));

  @override
  Widget build(BuildContext context) {
    var gameEngineData = context.getGameEngineData();
    return BlocListener<GameBloc, appGameState.GameState>(
      listener: (context, appGameState.GameState state) {
        if (state is AlphaBoundGameState) {
          if (state.gameState is GuessMovesUp) {
            _handleLowerBoundChange(context);
          } else if (state.gameState is GuessMovesDown) {
            _handleUpperBoundChange(context);
          } else if (state.gameState is GameWon) {
            _handleGameResult(context, true);
          } else if (state.gameState is GameLost) {
            _handleGameResult(context, false);
          }
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(_rowPaddingOnEachSide),
            child: _createBoundaryGuessWord(
                gameEngineData.currentState.lowerBound,
                _lowerBoundLetterSlotsKeys),
          ),
          Padding(
            padding: const EdgeInsets.all(_rowPaddingOnEachSide),
            child: _createMiddleRowGuessLetters(),
          ),
          Padding(
            padding: const EdgeInsets.all(_rowPaddingOnEachSide),
            child: _createBoundaryGuessWord(
                gameEngineData.currentState.upperBound,
                _upperBoundLetterSlotsKeys),
          ),
        ],
      ),
    );
  }

  Widget _createBoundaryGuessWord(
      String boundaryGuessWord, List<GlobalKey> widgetContexts) {
    var guessLetterSlots = <Widget>[];
    for (var index = 0;
        index < AlphaBoundConstants.numberOfLettersInGuess;
        index++) {
      guessLetterSlots.add(
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: _createBoundsLetterSlot(
              index, boundaryGuessWord[index], widgetContexts[index]),
        ),
      );
    }
    return Row(
      children: [
        ...guessLetterSlots,
      ],
    );
  }

  void _handleUpperBoundChange(BuildContext layoutContext) {
    var overlays = <OverlayEntry>[];
    for (int index = 0;
        index < AlphaBoundConstants.numberOfLettersInGuess;
        index++) {
      var upperBoundLetterSlotContext =
          _upperBoundLetterSlotsKeys[index].currentContext;
      var guessRowLetterSlotContext =
          _guessRowLetterSlotsKeys[index].currentContext;
      if (upperBoundLetterSlotContext == null ||
          guessRowLetterSlotContext == null) {
        continue;
      }
      if (!upperBoundLetterSlotContext.mounted ||
          !guessRowLetterSlotContext.mounted) {
        continue;
      }
      var overlayEntry =
          _animateGuessWordOnBoundsChange(index, _upperBoundLetterSlotsKeys);
      overlays.add(overlayEntry);
      Overlay.of(layoutContext).insert(overlayEntry);
    }
    _onAnimationCompleted(overlays, true);
  }

  void _handleLowerBoundChange(BuildContext context) {
    var overlays = <OverlayEntry>[];
    if (_upperBoundLetterSlotsKeys.every(
            (e) => e.currentContext != null && e.currentContext!.mounted) &&
        _guessRowLetterSlotsKeys.every(
            (e) => e.currentContext != null && e.currentContext!.mounted)) {
      for (int index = 0;
          index < AlphaBoundConstants.numberOfLettersInGuess;
          index++) {
        var overlayEntry =
            _animateGuessWordOnBoundsChange(index, _lowerBoundLetterSlotsKeys);
        overlays.add(overlayEntry);
        Overlay.of(context).insert(overlayEntry);
      }
      _onAnimationCompleted(overlays, true);
    }
  }

  void _handleGameResult(BuildContext context, bool didWin) {
    var overlays = <OverlayEntry>[];
    if (_guessRowLetterSlotsKeys
        .every((e) => e.currentContext != null && e.currentContext!.mounted)) {
      for (int index = 0;
          index < AlphaBoundConstants.numberOfLettersInGuess;
          index++) {
        var overlayEntry = _animateGuessWordOnResult(index, didWin);
        overlays.add(overlayEntry);
        Overlay.of(context).insert(overlayEntry);
      }
      _onAnimationCompleted(overlays, false);
    }
  }

  void _onAnimationCompleted(
      Iterable<OverlayEntry> overlays, bool shouldResetGuess) {
    Future.delayed(
        Duration(
            milliseconds:
                (AlphaBoundConstants.numberOfLettersInGuess * 250) + 750), () {
      setState(() {
        for (var overlayEntry in overlays) {
          overlayEntry.remove();
        }
        if (shouldResetGuess) {
          widget.guessLetterValueNotifier.value = "";
        }
      });
    });
  }

  Widget _createMiddleRowGuessLetters() {
    return ValueListenableBuilder<String>(
      valueListenable: widget.guessLetterValueNotifier,
      builder: (context, guessLetterValue, child) {
        var guessRowLetterSlots = <Widget>[];
        for (var index = 0;
            index < AlphaBoundConstants.numberOfLettersInGuess;
            index++) {
          guessRowLetterSlots.add(
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: _createMiddleRowGuessLetterSlot(index),
            ),
          );
        }
        return Row(
          children: [
            ...guessRowLetterSlots,
          ],
        );
      },
    );
  }

  Widget _createBoundsLetterSlot(int index, String letter, GlobalKey key) {
    return Container(
      key: key,
      width: widget.letterSize,
      height: widget.letterSize,
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style:
              TextStyle(fontSize: widget.letterSize / 2, color: Colors.white),
        ),
      ),
    );
  }

  Widget _createMiddleRowGuessLetterSlot(int index) {
    Widget centerWidget;
    Color backgroundColor;
    var guessLetterValue = widget.guessLetterValueNotifier.value;
    var guessLetterValueLength = guessLetterValue.length;
    if (index < guessLetterValueLength) {
      centerWidget = Text(
        guessLetterValue[index].toUpperCase(),
        style: TextStyle(fontSize: widget.letterSize / 2, color: Colors.black),
      );
      backgroundColor = Colors.orange;
    } else if (index == guessLetterValueLength) {
      centerWidget = Container(
        height: 15,
        width: 20,
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
      );
      backgroundColor = Colors.white;
    } else {
      centerWidget = SizedBox.shrink();
      backgroundColor = Colors.white;
    }
    return Container(
      key: _guessRowLetterSlotsKeys[index],
      width: widget.letterSize,
      height: widget.letterSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.black),
      ),
      child: Center(
        child: centerWidget,
      ),
    );
  }

  OverlayEntry _animateGuessWordOnBoundsChange(
      int index, List<GlobalKey> destinationWidgetKeys) {
    var guessLetter =
        widget.guessLetterValueNotifier.value[index].toUpperCase();
    var middleRowGuessLetterSlotContext =
        _guessRowLetterSlotsKeys[index].currentContext!;
    var middleRowGuessLetterSlotRenderBox =
        middleRowGuessLetterSlotContext.findRenderObject() as RenderBox;
    var middleRowGuessLetterSlotPosition =
        middleRowGuessLetterSlotRenderBox.localToGlobal(Offset.zero);

    var destinationGuessLetterSlotRenderBox = destinationWidgetKeys[index]
        .currentContext!
        .findRenderObject() as RenderBox;
    var destinationGuessLetterSlotPosition =
        destinationGuessLetterSlotRenderBox.localToGlobal(Offset.zero);
    var animatedGuessedLetterSlot = AnimatedGuessLetterPositioner(
      startPosition: middleRowGuessLetterSlotPosition,
      endPosition: destinationGuessLetterSlotPosition,
      letter: guessLetter,
      index: index,
      letterSize: widget.letterSize,
    );
    return OverlayEntry(builder: (context) => animatedGuessedLetterSlot);
  }

  OverlayEntry _animateGuessWordOnResult(int index, bool didWin) {
    var guessLetter =
        widget.guessLetterValueNotifier.value[index].toUpperCase();

    Widget guessLetterWidget;
    if (didWin) {
      guessLetterWidget = AnimatedGuessLetterDancer(
          letterSize: widget.letterSize, index: index, letter: guessLetter);
    } else {
      guessLetterWidget = AnimatedGuessLetterShaker(
          letterSize: widget.letterSize, index: index, letter: guessLetter);
    }
    var middleRowGuessLetterSlotContext =
        _guessRowLetterSlotsKeys[index].currentContext!;
    var middleRowGuessLetterSlotRenderBox =
        middleRowGuessLetterSlotContext.findRenderObject() as RenderBox;
    var middleRowGuessLetterSlotPosition =
        middleRowGuessLetterSlotRenderBox.localToGlobal(Offset.zero);
    return OverlayEntry(
      builder: (context) => Positioned(
        left: middleRowGuessLetterSlotPosition.dx,
        top: middleRowGuessLetterSlotPosition.dy,
        child: Material(child: guessLetterWidget),
      ),
    );
  }
}
