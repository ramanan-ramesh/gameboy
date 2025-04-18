import 'package:gameboy/data/app/models/app_data.dart';
import 'package:gameboy/data/app/models/platform_user.dart';
import 'package:gameboy/presentation/app/blocs/game/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_data.dart';

abstract class MasterPageState {}

class LoadingAppDataRepository extends MasterPageState {}

class LoadedAppDataRepository extends MasterPageState {
  final AppDataFacade appData;
  LoadedAppDataRepository({required this.appData});
}

class ActiveUserChanged extends MasterPageState {
  PlatformUser? user;

  ActiveUserChanged({required this.user});
}

class LoadedGame<TGameBloc extends GameBloc> extends MasterPageState {
  GameData<TGameBloc> gameData;

  LoadedGame({required this.gameData});
}
