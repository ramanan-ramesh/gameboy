import 'package:gameboy/blocs/game/bloc.dart';
import 'package:gameboy/blocs/game/game_data.dart';
import 'package:gameboy/data/app/models/app_data.dart';
import 'package:gameboy/data/app/models/platform_user.dart';

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

class UpdateAvailable extends MasterPageState {
  final UpdateInfo updateInfo;

  UpdateAvailable({required this.updateInfo});
}

class UpdateInfo {
  final String latestVersion;
  final bool isForceUpdate;
  final String releaseNotes;

  UpdateInfo({
    required this.latestVersion,
    required this.isForceUpdate,
    required this.releaseNotes,
  });
}
