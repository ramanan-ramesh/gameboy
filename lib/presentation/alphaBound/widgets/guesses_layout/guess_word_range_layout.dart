import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/alphaBound/models/constants.dart';
import 'package:gameboy/data/alphaBound/models/game_engine.dart';
import 'package:gameboy/data/alphaBound/models/game_status.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:gameboy/presentation/alphaBound/bloc/states.dart';
import 'package:gameboy/presentation/alphaBound/extensions.dart';
import 'package:gameboy/presentation/app/blocs/game/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game/events.dart';
import 'package:gameboy/presentation/app/blocs/game/states.dart'
    as appGameState;

import 'animated_guess_letters.dart';

class GuessWordLayout extends StatefulWidget {
  final double letterSize;
  final ValueNotifier<String> guessWordNotifier;

  const GuessWordLayout(
      {super.key, required this.letterSize, required this.guessWordNotifier});

  @override
  State<GuessWordLayout> createState() => _GuessWordLayoutState();
}

class _GuessWordLayoutState extends State<GuessWordLayout> {
  static const _guessRowPadding = 4.0;
  final List<OverlayEntry> _overlayEntries = [];

  final List<GlobalKey> _lowerBoundLetterSlotsKeys = List.generate(
      AlphaBoundConstants.guessWordLength,
      (index) => GlobalKey(debugLabel: 'lowerBoundLetterSlot$index'));
  final List<GlobalKey> _guessRowLetterSlotsKeys = List.generate(
      AlphaBoundConstants.guessWordLength,
      (index) => GlobalKey(debugLabel: 'guessRowLetterSlot$index'));
  final List<GlobalKey> _upperBoundLetterSlotsKeys = List.generate(
      AlphaBoundConstants.guessWordLength,
      (index) => GlobalKey(debugLabel: 'upperBoundLetterSlot$index'));

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, appGameState.GameState>(
      builder: (context, appGameState.GameState state) {
        var gameEngineData = context.getGameEngineData();
        var lowerBoundGuessWord = _BoundaryGuessWord(
            letterSize: widget.letterSize,
            boundaryGuessWord: gameEngineData.currentState.lowerBound,
            slotContexts: _lowerBoundLetterSlotsKeys);
        var attemptedGuessWord = _AttemptedGuessWord(
          letterSize: widget.letterSize,
          guessWordNotifier: widget.guessWordNotifier,
          guessLetterSlotKeys: _guessRowLetterSlotsKeys,
        );
        var upperBoundGuessWord = _BoundaryGuessWord(
            letterSize: widget.letterSize,
            boundaryGuessWord: gameEngineData.currentState.upperBound,
            slotContexts: _upperBoundLetterSlotsKeys);
        // _handleStartupGameState(state, gameEngineData, context);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(_guessRowPadding),
              child: lowerBoundGuessWord,
            ),
            Padding(
              padding: const EdgeInsets.all(_guessRowPadding),
              child: attemptedGuessWord,
            ),
            Padding(
              padding: const EdgeInsets.all(_guessRowPadding),
              child: upperBoundGuessWord,
            ),
          ],
        );
      },
      listener: (context, appGameState.GameState state) {
        if (state is AlphaBoundGameState) {
          if (state.gameStatus is GuessReplacesLowerBound) {
            _handleBoundsChange(context, true);
          } else if (state.gameStatus is GuessReplacesUpperBound) {
            _handleBoundsChange(context, false);
          } else if (state.gameStatus is GameWon) {
            // _handleGameResult(context, true);
          } else if (state.gameStatus is GameLost) {
            // _handleGameResult(context, false);
          }
        } else if (state is appGameState.ShowStats) {
          _removeAllOverlays();
        }
      },
      buildWhen: (previousState, currentState) {
        return currentState is AlphaBoundGameState &&
            (currentState.hasGameMovedAhead() ||
                currentState.gameStatus is GuessNotInDictionary ||
                currentState.gameStatus is GuessNotInBounds);
      },
    );
  }

  @override
  void dispose() {
    _removeAllOverlays();
    super.dispose();
  }

  void _handleStartupGameState(appGameState.GameState state,
      AlphaBoundGameEngine gameEngineData, BuildContext context) {
    if (state is AlphaBoundGameState) {
      if (state.isStartup) {
        if (state.gameStatus is GameWon) {
          widget.guessWordNotifier.value = gameEngineData.wordOfTheDay;
          _handleGameResult(context, true);
        } else if (state.gameStatus is GameLost) {
          widget.guessWordNotifier.value =
              (state.gameStatus as GameLost).finalGuess;
          _handleGameResult(context, false);
        }
      }
    }
  }

  void _handleBoundsChange(
      BuildContext layoutContext, bool isLowerBoundChanged) {
    var letterSlotKeys = isLowerBoundChanged
        ? _lowerBoundLetterSlotsKeys
        : _upperBoundLetterSlotsKeys;
    if (letterSlotKeys.every(
            (e) => e.currentContext != null && e.currentContext!.mounted) &&
        _guessRowLetterSlotsKeys.every(
            (e) => e.currentContext != null && e.currentContext!.mounted)) {
      for (int index = 0;
          index < AlphaBoundConstants.guessWordLength;
          index++) {
        var overlayEntry =
            _animateGuessWordOnBoundsChange(index, letterSlotKeys);
        _insertOverlayEntry(overlayEntry);
      }
      _onAnimationCompleted(true, true);
    }
  }

  void _handleGameResult(BuildContext context, bool didWin) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_guessRowLetterSlotsKeys.every(
          (e) => e.currentContext != null && e.currentContext!.mounted)) {
        for (int index = 0;
            index < AlphaBoundConstants.guessWordLength;
            index++) {
          var overlayEntry =
              _createAnimatedGuessLetterOnGameResult(index, didWin);
          _insertOverlayEntry(overlayEntry);
        }
        _onAnimationCompleted(false, false);
      }
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (context.mounted) {
        context.addGameEvent(RequestStats());
      }
    });
  }

  void _onAnimationCompleted(bool shouldResetGuess, bool shouldRebuild) {
    Future.delayed(
        const Duration(
            milliseconds: (AlphaBoundConstants.guessWordLength * 250) + 750),
        () {
      if (shouldRebuild) {
        setState(() {
          _removeAllOverlays();
          if (shouldResetGuess) {
            widget.guessWordNotifier.value = "";
          }
        });
      } else {
        _removeAllOverlays();
        if (shouldResetGuess) {
          widget.guessWordNotifier.value = "";
        }
      }
    });
  }

  OverlayEntry _animateGuessWordOnBoundsChange(
      int index, List<GlobalKey> destinationWidgetKeys) {
    var guessLetter = widget.guessWordNotifier.value[index].toUpperCase();
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
    var guessLetter = widget.guessWordNotifier.value[index].toUpperCase();

    Widget guessLetterWidget = AnimatedGuessLetterShaker(
        letterSize: widget.letterSize, index: index, letter: guessLetter);
    // if (didWin) {
    //   guessLetterWidget = AnimatedGuessLetterDancer(
    //       letterSize: widget.letterSize, index: index, letter: guessLetter);
    // } else {
    //   guessLetterWidget = AnimatedGuessLetterShaker(
    //       letterSize: widget.letterSize, index: index, letter: guessLetter);
    // }
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

class _BoundaryGuessWord extends StatelessWidget {
  final double letterSize;
  final String boundaryGuessWord;
  final Iterable<GlobalKey> slotContexts;
  const _BoundaryGuessWord(
      {super.key,
      required this.letterSize,
      required this.boundaryGuessWord,
      required this.slotContexts});

  @override
  Widget build(BuildContext context) {
    var guessLetterSlots =
        List<Widget>.generate(AlphaBoundConstants.guessWordLength, (index) {
      return Padding(
        padding: const EdgeInsets.all(3.0),
        child: _createBoundsLetterSlot(index, boundaryGuessWord[index],
            slotContexts.elementAt(index), letterSize),
      );
    });
    return Row(
      children: [
        ...guessLetterSlots,
      ],
    );
  }
}

class _AttemptedGuessWord extends StatelessWidget {
  final double letterSize;
  final ValueNotifier<String> guessWordNotifier;
  final Iterable<GlobalKey> guessLetterSlotKeys;
  const _AttemptedGuessWord(
      {super.key,
      required this.letterSize,
      required this.guessWordNotifier,
      required this.guessLetterSlotKeys});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: guessWordNotifier,
      builder: (context, guessLetterValue, child) {
        var gameEngineData = context.getGameEngineData().currentState;
        var guessLetterSlots = <Widget>[];
        for (var index = 0;
            index < AlphaBoundConstants.guessWordLength;
            index++) {
          guessLetterSlots.add(
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: _buildGuessLetterSlot(index, gameEngineData),
            ),
          );
        }
        return Row(
          children: [
            ...guessLetterSlots,
          ],
        );
      },
    );
  }

  Widget _buildGuessLetterSlot(int index, AlphaBoundGameStatus gameStatus) {
    Color backgroundColor;
    Widget centerWidget;
    var guessLetterValue = guessWordNotifier.value;
    var guessLetterValueLength = guessLetterValue.length;
    var didWinGame = gameStatus is GameWon;
    if ((gameStatus is GuessNotInDictionary &&
            gameStatus.guess.isEqualTo(guessLetterValue)) ||
        (gameStatus is GuessNotInBounds &&
            gameStatus.guess.isEqualTo(guessLetterValue))) {
      return ShakingGuessLetter(
          letter: guessLetterValue[index].toUpperCase(),
          letterSize: letterSize);
    } else if (gameStatus is GameWon) {
      return AnimatedGuessLetterDancer(
        letterSize: letterSize,
        letter: guessLetterValue[index].toUpperCase(),
        didWinGame: true,
      );
    }
    if (index < guessLetterValueLength) {
      centerWidget = Text(
        guessLetterValue[index].toUpperCase(),
        style: TextStyle(
            fontSize: letterSize / 2,
            color: didWinGame ? Colors.white : Colors.black),
      );
      backgroundColor = didWinGame ? Colors.green : Colors.orange;
    } else if (index == guessLetterValueLength) {
      centerWidget = Container(
        height: 15,
        width: 20,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
      );
      backgroundColor = Colors.white;
    } else {
      centerWidget = const SizedBox.shrink();
      backgroundColor = Colors.white;
    }
    return Container(
      key: guessLetterSlotKeys.elementAt(index),
      width: letterSize,
      height: letterSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.black),
      ),
      child: Center(
        child: centerWidget,
      ),
    );
  }
}

Widget _createBoundsLetterSlot(
    int index, String letter, GlobalKey key, double letterSlotSize) {
  return Container(
    key: key,
    width: letterSlotSize,
    height: letterSlotSize,
    decoration: const BoxDecoration(
      color: Colors.blue,
    ),
    child: Center(
      child: Text(
        letter.toUpperCase(),
        style: TextStyle(fontSize: letterSlotSize / 2, color: Colors.white),
      ),
    ),
  );
}
