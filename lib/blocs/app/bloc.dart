import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/blocs/alphaBound/bloc.dart';
import 'package:gameboy/blocs/beeWise/bloc.dart';
import 'package:gameboy/blocs/game/game_data.dart';
import 'package:gameboy/blocs/lexBox/bloc.dart';
import 'package:gameboy/blocs/wordsy/bloc.dart';
import 'package:gameboy/data/app/constants.dart';
import 'package:gameboy/data/app/implementations/app_data_repository.dart';
import 'package:gameboy/data/app/models/app_data.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/data/auth/models/status.dart';
import 'package:gameboy/presentation/alphaBound/pages/game_layout.dart';
import 'package:gameboy/presentation/beeWise/pages/game_layout.dart';
import 'package:gameboy/presentation/lexBox/pages/game_layout.dart';
import 'package:gameboy/presentation/wordsy/pages/game_layout.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'events.dart';
import 'states.dart';

class _StartupInternal extends MasterPageEvent {}

class _UpdateAvailableInternal extends MasterPageEvent {
  final UpdateInfo updateInfo;

  _UpdateAvailableInternal({required this.updateInfo});
}

class MasterPageBloc extends Bloc<MasterPageEvent, MasterPageState> {
  AppDataModifier? _appDataRepository;
  late final StreamSubscription _updateRemoteConfigSubscription;

  MasterPageBloc(SharedPreferences sharedPreferences)
      : super(LoadedAppDataRepository(
            appData: AppDataRepository.create(sharedPreferences))) {
    on<_StartupInternal>(_onStartupInternal);
    on<AuthenticateWithGoogle>(_onAuthenticateWithGoogle);
    on<Logout>(_onLogout);
    on<LoadGame>(_onLoadGame);
    on<ToggleThemeMode>(_onToggleThemeMode);
    on<_UpdateAvailableInternal>((event, emit) {
      emit(UpdateAvailable(updateInfo: event.updateInfo));
    });

    _appDataRepository =
        (state as LoadedAppDataRepository).appData as AppDataModifier;
    add(_StartupInternal());
  }

  @override
  Future<void> close() {
    _updateRemoteConfigSubscription.cancel();
    return super.close();
  }

  FutureOr<void> _onStartupInternal(
      _StartupInternal event, Emitter<MasterPageState> emit) async {
    var updateInfo = await _checkForUpdate();
    if (updateInfo != null && updateInfo.isForceUpdate) {
      emit(UpdateAvailable(updateInfo: updateInfo));
      return;
    }
    if (updateInfo != null) {
      emit(UpdateAvailable(updateInfo: updateInfo));
    }
    await _initUpdateListener();
  }

  FutureOr<void> _onAuthenticateWithGoogle(
      AuthenticateWithGoogle event, Emitter<MasterPageState> emit) async {
    emit(AuthStateChanged(authStatus: AuthStatus.authenticating));
    var authStatus =
        await _appDataRepository!.userManagement.trySignInWithGoogle();
    if (authStatus == AuthStatus.loggedIn) {
      emit(AuthStateChanged(authStatus: AuthStatus.loggedIn));
    } else {
      emit(AuthStateChanged(authStatus: AuthStatus.undefined));
    }
  }

  FutureOr<void> _onLogout(Logout event, Emitter<MasterPageState> emit) async {
    emit(AuthStateChanged(authStatus: AuthStatus.authenticating));
    var didLogout = await _appDataRepository!.userManagement.trySignOut();
    if (didLogout) {
      emit(AuthStateChanged(authStatus: AuthStatus.loggedOut));
    } else {
      emit(AuthStateChanged(authStatus: AuthStatus.undefined));
    }
  }

  FutureOr<void> _onLoadGame(LoadGame event, Emitter<MasterPageState> emit) {
    var gameData = _getGameData(event.game);
    if (gameData != null) {
      emit(LoadedGame(gameData: gameData));
    }
  }

  FutureOr<void> _onToggleThemeMode(
      ToggleThemeMode event, Emitter<MasterPageState> emit) async {
    await _appDataRepository!.toggleThemeMode();
    emit(ThemeModeToggled());
  }

  Future<void> _initUpdateListener() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 30),
        minimumFetchInterval: const Duration(minutes: 5)));
    await remoteConfig.fetchAndActivate();

    _updateRemoteConfigSubscription =
        remoteConfig.onConfigUpdated.listen((event) async {
      await remoteConfig.activate();
      var updateInfo = await _checkForUpdate();
      if (updateInfo != null) {
        add(_UpdateAvailableInternal(updateInfo: updateInfo));
      }
    });
  }

  Future<UpdateInfo?> _checkForUpdate() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    final latestVersion = remoteConfig.getString('latest_version');
    final minVersion = remoteConfig.getString('min_version');
    final releaseNotes = remoteConfig.getString('release_notes');

    final packageInfo = await PackageInfo.fromPlatform();
    final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;
    final latestBuildNumber = int.tryParse(latestVersion.split('+').last) ?? 0;
    final minBuildNumber = int.tryParse(minVersion.split('+').last) ?? 0;

    final updateRequired = latestBuildNumber > currentBuildNumber;
    final isForceUpdate = minBuildNumber >= currentBuildNumber;

    final versionName = latestVersion.split('+').first;

    return updateRequired
        ? UpdateInfo(
            latestVersion: versionName,
            isForceUpdate: isForceUpdate,
            releaseNotes: releaseNotes,
          )
        : null;
  }

  GameData? _getGameData(Game game) {
    var userId = _appDataRepository!.activeUser!.id;
    switch (game.name) {
      case AppConstants.wordsyGameIdentifier:
        return GameData<WordsyGameBloc>(
            gameBloc: WordsyGameBloc(userId),
            gameLayout: WordsyLayout(),
            game: game);
      case AppConstants.beeWiseGameIdentifier:
        return GameData<BeeWiseBloc>(
            gameBloc: BeeWiseBloc(userId),
            gameLayout: BeeWiseLayout(),
            game: game);
      case AppConstants.alphaBoundGameIdentifier:
        return GameData<AlphaBoundBloc>(
            gameBloc: AlphaBoundBloc(userId),
            gameLayout: AlphaBoundLayout(),
            game: game);
      case AppConstants.lexBoxGameIdentifier:
        return GameData<LexBoxBloc>(
            gameBloc: LexBoxBloc(userId),
            gameLayout: LexBoxLayout(),
            game: game);
      default:
        return null;
    }
  }
}
