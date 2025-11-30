import 'package:firebase_auth/firebase_auth.dart';
import 'package:gameboy/data/app/models/game.dart';

abstract class MasterPageEvent {}

class ChangeUser extends MasterPageEvent {
  User? authProviderUser;

  ChangeUser.signIn({required User this.authProviderUser});

  ChangeUser.signOut();
}

class Logout extends MasterPageEvent {
  Logout();
}

class LoadGame extends MasterPageEvent {
  Game game;

  LoadGame(this.game);
}
