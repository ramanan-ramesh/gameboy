import 'package:gameboy/data/spelling_bee/implementation/stats.dart';
import 'package:gameboy/data/spelling_bee/models/stats.dart';

abstract class StatsModifier extends Stats {
  Future<bool> trySubmitWord(String word);

  static Future<StatsModifier> createInstance(String userId) async {
    return await StatsRepository.createRepository(userId);
  }
}
