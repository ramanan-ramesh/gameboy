import 'package:gameboy/data/app/models/game.dart';

abstract class MasterPageEvent {}

class AuthenticateWithGoogle extends MasterPageEvent {}

class Logout extends MasterPageEvent {}

class LoadGame extends MasterPageEvent {
  Game game;

  LoadGame(this.game);
}
