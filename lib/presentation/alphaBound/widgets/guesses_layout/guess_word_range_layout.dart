import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/alphaBound/models/constants.dart';
import 'package:gameboy/data/alphaBound/models/game_status.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:gameboy/presentation/alphaBound/bloc/states.dart';
import 'package:gameboy/presentation/alphaBound/extensions.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_event.dart';
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

  List<OverlayEntry> _overlayEntries = [];

  @override
  Widget build(BuildContext context) {
    var gameEngineData = context.getGameEngineData();
    return BlocConsumer<GameBloc, appGameState.GameState>(
      builder: (context, appGameState.GameState state) {
        var lowerBoundGuessWord = _createBoundaryGuessWord(
            gameEngineData.currentState.lowerBound, _lowerBoundLetterSlotsKeys);
        var middleRowGuessWord =
            _createMiddleGuessRow(gameEngineData.currentState);
        var upperBoundGuessWord = _createBoundaryGuessWord(
            gameEngineData.currentState.upperBound, _upperBoundLetterSlotsKeys);
        if (state is AlphaBoundGameState) {
          if (state.isStartup) {
            if (state.gameStatus is GameWon) {
              widget.guessLetterValueNotifier.value =
                  gameEngineData.wordOfTheDay;
              _handleGameResult(context, true);
            } else if (state.gameStatus is GameLost) {
              widget.guessLetterValueNotifier.value =
                  (state.gameStatus as GameLost).finalGuess;
              _handleGameResult(context, false);
            }
          }
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(_rowPaddingOnEachSide),
              child: lowerBoundGuessWord,
            ),
            Padding(
              padding: const EdgeInsets.all(_rowPaddingOnEachSide),
              child: middleRowGuessWord,
            ),
            Padding(
              padding: const EdgeInsets.all(_rowPaddingOnEachSide),
              child: upperBoundGuessWord,
            ),
          ],
        );
      },
      listener: (context, appGameState.GameState state) {
        if (state is AlphaBoundGameState) {
          if (state.gameStatus is GuessMovesUp) {
            _handleLowerBoundChange(context);
          } else if (state.gameStatus is GuessMovesDown) {
            _handleUpperBoundChange(context);
          } else if (state.gameStatus is GuessNotInDictionary) {
          } else if (state.gameStatus is GameWon) {
            _handleGameResult(context, true);
          } else if (state.gameStatus is GameLost) {
            _handleGameResult(context, false);
          }
        }
      },
      buildWhen: (previousState, currentState) {
        return currentState is AlphaBoundGameState &&
            (currentState.hasGameMovedAhead() ||
                currentState.gameStatus is GuessNotInDictionary);
      },
    );
  }

  Widget _createBoundaryGuessWord(
      String boundaryGuessWord, List<GlobalKey> widgetContexts) {
    var guessLetterSlots = <Widget>[];
    for (var index = 0;
        index < AlphaBoundConstants.numberOfLettersInGuess;
        index++) {
      var widgetKey = GlobalKey(
          debugLabel: 'boundaryGuessLetter $index for word $boundaryGuessWord');
      widgetContexts[index] = widgetKey;
      guessLetterSlots.add(
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: _createBoundsLetterSlot(
              index, boundaryGuessWord[index], widgetKey),
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
      _insertOverlayEntry(overlayEntry);
    }
    _onAnimationCompleted(true, true);
  }

  void _handleLowerBoundChange(BuildContext context) {
    if (_upperBoundLetterSlotsKeys.every(
            (e) => e.currentContext != null && e.currentContext!.mounted) &&
        _guessRowLetterSlotsKeys.every(
            (e) => e.currentContext != null && e.currentContext!.mounted)) {
      for (int index = 0;
          index < AlphaBoundConstants.numberOfLettersInGuess;
          index++) {
        var overlayEntry =
            _animateGuessWordOnBoundsChange(index, _lowerBoundLetterSlotsKeys);
        _insertOverlayEntry(overlayEntry);
      }
      _onAnimationCompleted(true, true);
    }
  }

  void _handleGameResult(BuildContext context, bool didWin) {
    Future.delayed(Duration(milliseconds: 500), () {
      if (_guessRowLetterSlotsKeys.every(
          (e) => e.currentContext != null && e.currentContext!.mounted)) {
        for (int index = 0;
            index < AlphaBoundConstants.numberOfLettersInGuess;
            index++) {
          var overlayEntry =
              _createAnimatedGuessLetterOnGameResult(index, didWin);
          _insertOverlayEntry(overlayEntry);
        }
        _onAnimationCompleted(false, false);
      }
    });
    Future.delayed(Duration(milliseconds: 3000), () {
      if (context.mounted) {
        context.addGameEvent(RequestStats());
      }
    });
  }

  void _onAnimationCompleted(bool shouldResetGuess, bool shouldRebuild) {
    Future.delayed(
        Duration(
            milliseconds:
                (AlphaBoundConstants.numberOfLettersInGuess * 250) + 750), () {
      if (shouldRebuild) {
        setState(() {
          _removeAllOverlays();
          if (shouldResetGuess) {
            widget.guessLetterValueNotifier.value = "";
          }
        });
      } else {
        _removeAllOverlays();
        if (shouldResetGuess) {
          widget.guessLetterValueNotifier.value = "";
        }
      }
    });
  }

  Widget _createMiddleGuessRow(AlphaBoundGameStatus gameStatus) {
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
              child: _createMiddleRowGuessLetterSlot(index, gameStatus),
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

  Widget _createMiddleRowGuessLetterSlot(
      int index, AlphaBoundGameStatus gameStatus) {
    Widget centerWidget;
    Color backgroundColor;
    var guessLetterValue = widget.guessLetterValueNotifier.value;
    var guessLetterValueLength = guessLetterValue.length;
    var didWinGame = gameStatus is GameWon;
    var widgetKey = GlobalKey(debugLabel: 'guessRowLetterSlot$index');
    _guessRowLetterSlotsKeys[index] = widgetKey;
    if (gameStatus is GuessNotInDictionary &&
        gameStatus.guess.isEqualTo(guessLetterValue)) {
      return ShakingGuessLetter(
          letter: guessLetterValue[index].toUpperCase(),
          letterSize: widget.letterSize);
    }
    if (index < guessLetterValueLength) {
      centerWidget = Text(
        guessLetterValue[index].toUpperCase(),
        style: TextStyle(
            fontSize: widget.letterSize / 2,
            color: didWinGame ? Colors.white : Colors.black),
      );
      backgroundColor = didWinGame ? Colors.green : Colors.orange;
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
      key: widgetKey,
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

  OverlayEntry _createAnimatedGuessLetterOnGameResult(int index, bool didWin) {
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

  void _insertOverlayEntry(OverlayEntry overlayEntry) {
    if (mounted) {
      _overlayEntries.add(overlayEntry);
      Overlay.of(context).insert(overlayEntry);
    }
  }

  @override
  void dispose() {
    _removeAllOverlays();
    super.dispose();
  }

  void _removeAllOverlays() {
    if (mounted) {
      for (var overlayEntry in _overlayEntries) {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }
      }
    }
  }
}
