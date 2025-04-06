import 'game.dart';
import 'platform_user.dart';

abstract class AppDataFacade {
  PlatformUser? get activeUser;

  Iterable<Game> get games;
}
