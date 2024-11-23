import 'package:gameboy/data/spelling_bee/models/constants.dart';

class Score {
  final int score;
  final String rank;
  int get rankIndex => SpellingBeeConstants.ranks.indexOf(rank);
  const Score({required this.score, required this.rank});
}
