import 'package:gameboy/data/beeWise/models/constants.dart';

class Score {
  final int score;
  final String rank;

  int get rankIndex => BeeWiseConstants.ranks.indexOf(rank);

  const Score({required this.score, required this.rank});
}
