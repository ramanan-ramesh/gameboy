import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/blocs/game/bloc.dart';
import 'package:gameboy/blocs/game/events.dart';
import 'package:gameboy/blocs/game/states.dart' as appGameState;
import 'package:gameboy/blocs/lexBox/events.dart' as lexBoxEvents;
import 'package:gameboy/blocs/lexBox/states.dart' as lexBoxStates;
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/data/lexBox/models/guessed_word_state.dart';
import 'package:gameboy/presentation/app/pages/game_content_page/game_layout.dart';
import 'package:gameboy/presentation/lexBox/extensions.dart';
import 'package:gameboy/presentation/lexBox/widgets/letter_box_widget.dart';
import 'package:gameboy/presentation/lexBox/widgets/words_list_widget.dart';

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
    return const _LexBoxStatsSheet();
  }

  @override
  Widget buildTutorialSheet(BuildContext context, Game game) {
    return const _LexBoxTutorialSheet();
  }
}

class _LexBoxGameWidget extends StatefulWidget {
  const _LexBoxGameWidget();

  @override
  State<_LexBoxGameWidget> createState() => _LexBoxGameWidgetState();
}

class _LexBoxGameWidgetState extends State<_LexBoxGameWidget> {
  List<int> _currentWordIndices = [];
  Set<int> _usedLetterIndices = {};
  String _currentWord = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateUsedLetters();
  }

  void _updateUsedLetters() {
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
    setState(() {
      _usedLetterIndices = used;
    });
  }

  void _onWordComplete(List<int> indices) {
    final gameEngine = context.getGameEngineData();
    final letters = gameEngine.lettersOfTheDay;
    final word = indices.map((i) => letters[i]).join();

    if (word.length >= 3) {
      context.addGameEvent(lexBoxEvents.SubmitWord(word));
    }

    setState(() {
      _currentWordIndices = [];
      _currentWord = '';
    });
  }

  void _onCurrentWordChanged(List<int> indices) {
    final gameEngine = context.getGameEngineData();
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
    context.addGameEvent(lexBoxEvents.EraseLastWord());
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameEngine = context.getGameEngineData();
    final letters = gameEngine.lettersOfTheDay;
    final guessedWords = gameEngine.guessedWords.toList();

    return BlocListener<GameBloc, appGameState.GameState>(
      listener: (context, state) {
        if (state is lexBoxStates.WordErased) {
          _showSnackBar('Erased: ${state.erasedWord.toUpperCase()}');
          _updateUsedLetters();
        } else if (state is lexBoxStates.GuessedWordResult) {
          switch (state.guessedWordState) {
            case LexBoxGuessedWordState.valid:
              _showSnackBar('Word accepted!');
              _updateUsedLetters();
            case LexBoxGuessedWordState.win:
              _showSnackBar('Congratulations! You solved it!');
              _updateUsedLetters();
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  context.addGameEvent(RequestStats());
                }
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
      child: Column(
        children: [
          // Progress indicator
          LettersProgressIndicator(
            usedCount: _usedLetterIndices.length,
            totalCount: 12,
          ),
          const SizedBox(height: 8),
          // Words list with erase button
          Expanded(
            flex: 2,
            child: WordsListWidget(
              words: guessedWords,
              currentWord: _currentWord,
              onEraseLastWord:
                  guessedWords.isNotEmpty ? _onEraseLastWord : null,
            ),
          ),
          // Current word display (simple text, no buttons)
          if (_currentWord.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _currentWord.toUpperCase(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C63FF),
                  letterSpacing: 4,
                ),
              ),
            ),
          // Letter box
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LetterBoxWidget(
                lettersOfTheDay: letters,
                currentWordIndices: _currentWordIndices,
                usedLetterIndices: _usedLetterIndices,
                onWordComplete: _onWordComplete,
                onWordCancelled: _onClearWord,
                onCurrentWordChanged: _onCurrentWordChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LexBoxStatsSheet extends StatelessWidget {
  const _LexBoxStatsSheet();

  @override
  Widget build(BuildContext context) {
    final stats = context.getStatsRepository();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                value: stats.winCount.toString(),
                label: 'Wins',
              ),
              _StatItem(
                value: stats.wordsSubmittedToday.length.toString(),
                label: 'Words Today',
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (stats.wordsSubmittedToday.isNotEmpty) ...[
            const Text(
              'Today\'s Words',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stats.wordsSubmittedToday
                  .map((w) => Chip(label: Text(w.toUpperCase())))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _LexBoxTutorialSheet extends StatelessWidget {
  const _LexBoxTutorialSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: Text(
                'How to Play',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildRule(
              icon: Icons.gesture,
              title: 'Connect Letters',
              description:
                  'Drag your finger to connect letters around the square to spell words.',
            ),
            _buildRule(
              icon: Icons.text_fields,
              title: 'Word Length',
              description: 'Words must be at least 3 letters long.',
            ),
            _buildRule(
              icon: Icons.block,
              title: 'No Same Side',
              description:
                  'Consecutive letters cannot be from the same side of the square.',
            ),
            _buildRule(
              icon: Icons.repeat,
              title: 'No Repeats',
              description:
                  'The same letter cannot be used consecutively (but can be reused later).',
            ),
            _buildRule(
              icon: Icons.link,
              title: 'Chain Words',
              description:
                  'The last letter of each word becomes the first letter of the next word.',
            ),
            _buildRule(
              icon: Icons.check_circle,
              title: 'Goal',
              description:
                  'Use all 12 letters in as few words as possible to complete the puzzle.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRule({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: const Color(0xFF6C63FF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
