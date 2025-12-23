import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/blocs/game/bloc.dart';
import 'package:gameboy/blocs/game/events.dart';
import 'package:gameboy/blocs/game/states.dart';
import 'package:gameboy/blocs/lexBox/events.dart';
import 'package:gameboy/blocs/lexBox/states.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/data/lexBox/models/guessed_word_state.dart';
import 'package:gameboy/presentation/app/pages/game_content_page/game_layout.dart';
import 'package:gameboy/presentation/app/pages/game_content_page/snackbar_service.dart';
import 'package:gameboy/presentation/app/theming/app_colors.dart';
import 'package:gameboy/presentation/lexBox/extensions.dart';
import 'package:gameboy/presentation/lexBox/widgets/letter_box_widget.dart';
import 'package:gameboy/presentation/lexBox/widgets/win_celebration.dart';
import 'package:gameboy/presentation/lexBox/widgets/words_list_widget.dart';

import 'stats_sheet.dart';
import 'tutorial_sheet.dart';

class LexBoxLayout implements GameLayout {
  @override
  BoxConstraints get constraints => const BoxConstraints(
        minWidth: 350.0,
        maxWidth: 600.0,
        minHeight: 600.0,
        maxHeight: 900.0,
      );

  @override
  Widget buildGameLayout(
      BuildContext layoutContext, double layoutWidth, double layoutHeight) {
    return const _LexBoxGameWidget();
  }

  @override
  Widget buildStatsSheet(BuildContext context, Game game) {
    return const LexBoxStatsSheet();
  }

  @override
  Widget buildTutorialSheet(BuildContext context, Game game) {
    return const LexBoxTutorialSheet();
  }
}

class _LexBoxGameWidget extends StatefulWidget {
  const _LexBoxGameWidget();

  @override
  State<_LexBoxGameWidget> createState() => _LexBoxGameWidgetState();
}

class _LexBoxGameWidgetState extends State<_LexBoxGameWidget> {
  List<int> _currentWordIndices = [];
  String _currentWord = '';
  bool _showCelebration = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if game was already won on startup (state emitted before listener registered)
    final currentState = context.getCurrentLexBoxState();
    if (currentState is LexBoxWinOnStartup && !_showCelebration) {
      // Defer setState to avoid calling it during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _showCelebration = true;
          });
        }
      });
    }
  }

  Set<int> _getUsedLetterIndices() {
    final gameEngine = context.getGameEngineData();
    final allWords = gameEngine.guessedWords;
    final letters = gameEngine.lettersOfTheDay;

    Set<int> used = {};
    for (var word in allWords) {
      for (var char in word.toLowerCase().split('')) {
        final idx = letters.toLowerCase().indexOf(char);
        if (idx >= 0) {
          used.add(idx);
        }
      }
    }
    return used;
  }

  void _onWordComplete(List<int> indices) {
    final gameEngine = context.getGameEngineData();
    // Don't allow new words if already won
    if (gameEngine.isWon) return;

    final letters = gameEngine.lettersOfTheDay;
    final word = indices.map((i) => letters[i]).join();

    if (word.length >= 3) {
      context.addGameEvent(SubmitWord(word));
    }

    setState(() {
      _currentWordIndices = [];
      _currentWord = '';
    });
  }

  void _onCurrentWordChanged(List<int> indices) {
    final gameEngine = context.getGameEngineData();
    // Don't allow new words if already won
    if (gameEngine.isWon) return;

    final letters = gameEngine.lettersOfTheDay;

    setState(() {
      _currentWordIndices = indices;
      _currentWord = indices.map((i) => letters[i]).join();
    });
  }

  void _onClearWord() {
    setState(() {
      _currentWordIndices = [];
      _currentWord = '';
    });
  }

  void _onEraseLastWord() {
    context.addGameEvent(EraseLastWord());
  }

  void _onCelebrationComplete(BuildContext context) {
    setState(() {
      _showCelebration = false;
    });
    // Show stats sheet after celebration
    context.addGameEvent(RequestStats());
  }

  void _showSnackBar(String message) {
    if (mounted) {
      context.showGameSnackBar(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameEngine = context.getGameEngineData();
    final letters = gameEngine.lettersOfTheDay;
    final guessedWords = gameEngine.guessedWords.toList();
    final usedLetterIndices = _getUsedLetterIndices();
    final isWon = gameEngine.isWon;

    return BlocListener<GameBloc, GameState>(
      listenWhen: (previous, current) {
        // Listen to LexBox-specific states and ShowStats
        return current is LexBoxState || current is ShowStats;
      },
      listener: (context, state) {
        if (state is LexBoxWinOnStartup) {
          // Show celebration on startup if already won
          setState(() {
            _showCelebration = true;
          });
        } else if (state is WordErased) {
          _showSnackBar('Erased: ${state.erasedWord.toUpperCase()}');
        } else if (state is GuessedWordResult) {
          switch (state.guessedWordState) {
            case LexBoxGuessedWordState.valid:
              _showSnackBar('Word accepted!');
            case LexBoxGuessedWordState.win:
              setState(() {
                _showCelebration = true;
              });
            case LexBoxGuessedWordState.tooShort:
              _showSnackBar('Word is too short');
            case LexBoxGuessedWordState.notInDictionary:
              _showSnackBar('Word not in dictionary');
            case LexBoxGuessedWordState.mustStartWithPreviousWordLastLetter:
              _showSnackBar(
                  'Word must start with last letter of previous word');
            case LexBoxGuessedWordState.invalidConsecutiveSameSide:
              _showSnackBar('Cannot use letters from same side consecutively');
          }
        }
      },
      child: Stack(
        children: [
          // Main game content
          Column(
            children: [
              // Progress indicator
              LettersProgressIndicator(
                usedCount: usedLetterIndices.length,
                totalCount: 12,
              ),
              const SizedBox(height: 8),
              // Win badge (shown after celebration)
              if (isWon && !_showCelebration)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: LexBoxWinBadge(),
                ),
              // Words list with erase button
              Expanded(
                flex: 2,
                child: WordsListWidget(
                  words: guessedWords,
                  currentWord: null, // Current word shown in indicator instead
                  onEraseLastWord: guessedWords.isNotEmpty && !isWon
                      ? _onEraseLastWord
                      : null,
                ),
              ),
              // Current word display - show disabled state if won
              _CurrentWordIndicator(
                currentWord: _currentWord,
                isValid: _currentWord.length >= 3,
                isDisabled: isWon,
              ),
              // Letter box
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IgnorePointer(
                    ignoring: isWon,
                    child: Opacity(
                      opacity: isWon ? 0.5 : 1.0,
                      child: LetterBoxWidget(
                        lettersOfTheDay: letters,
                        currentWordIndices: _currentWordIndices,
                        usedLetterIndices: usedLetterIndices,
                        onWordComplete: _onWordComplete,
                        onWordCancelled: _onClearWord,
                        onCurrentWordChanged: _onCurrentWordChanged,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Win celebration overlay
          if (_showCelebration)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _onCelebrationComplete(context),
                child: ColoredBox(
                  color: Theme.of(context)
                      .scaffoldBackgroundColor
                      .withValues(alpha: 0.9),
                  child: LexBoxWinCelebration(
                    lettersOfTheDay: letters,
                    onAnimationComplete: () {
                      // Auto-dismiss after 3 seconds and show stats
                      Future.delayed(const Duration(seconds: 3), () {
                        if (mounted && _showCelebration) {
                          _onCelebrationComplete(context);
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CurrentWordIndicator extends StatelessWidget {
  final String currentWord;
  final bool isValid;
  final bool isDisabled;

  const _CurrentWordIndicator({
    required this.currentWord,
    required this.isValid,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameColor = GameColors.lexBoxPrimary;
    final hasWord = currentWord.isNotEmpty;

    // Show "Puzzle Solved!" when disabled (won)
    if (isDisabled) {
      return Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: gameColor.withValues(alpha: 0.1),
          borderRadius:
              BorderRadius.circular(DesignConstants.borderRadiusMedium),
          border: Border.all(
            color: gameColor.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: gameColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Puzzle Solved!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: gameColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DesignConstants.borderRadiusMedium),
        border: Border.all(
          color: !hasWord
              ? theme.colorScheme.outline
              : (isValid
                  ? gameColor
                  : theme.colorScheme.error.withValues(alpha: 0.5)),
          width: hasWord && isValid ? 2 : 1,
        ),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: hasWord
              ? Text(
                  currentWord.toUpperCase(),
                  key: ValueKey(currentWord),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isValid
                        ? gameColor
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    letterSpacing: 6,
                  ),
                )
              : Text(
                  'Drag to connect letters...',
                  key: const ValueKey('placeholder'),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
        ),
      ),
    );
  }
}
