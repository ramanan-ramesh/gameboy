import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/models/app_data_facade.dart';
import 'package:gameboy/data/app/models/app_data_modifier.dart';

import 'master_page_events.dart';
import 'master_page_states.dart';

class MasterPageBloc extends Bloc<MasterPageEvent, MasterPageState> {
  final AppDataModifier _appDataRepository;

  MasterPageBloc({required AppDataFacade appDataFacade})
      : _appDataRepository = appDataFacade as AppDataModifier,
        super(Startup()) {
    on<ChangeTheme>(_onThemeChange);
    on<ChangeLanguage>(_onLanguageChange);
    on<ChangeUser>(_onUserChange);
    on<Logout>(_onLogout);
    on<LoadGame>(_onLoadGame);
  }

  FutureOr<void> _onThemeChange(
      ChangeTheme event, Emitter<MasterPageState> emit) {
    emit(ActiveThemeModeChanged(themeMode: event.themeModeToChangeTo));
  }

  FutureOr<void> _onLanguageChange(
      ChangeLanguage event, Emitter<MasterPageState> emit) async {
    if (_appDataRepository.activeLanguage == event.languageToChangeTo) {
      return;
    }
    await _appDataRepository.updateActiveLanguage(event.languageToChangeTo);
    emit(ActiveLanguageChanged(language: event.languageToChangeTo));
  }

  FutureOr<void> _onUserChange(
      ChangeUser event, Emitter<MasterPageState> emit) async {
    if (event.authProviderUser != null) {
      await _appDataRepository.updateActiveUser(event.authProviderUser!);
      emit(ActiveUserChanged(user: _appDataRepository.activeUser));
    }
  }

  FutureOr<void> _onLogout(Logout event, Emitter<MasterPageState> emit) async {
    await _appDataRepository.updateActiveUser(null);
    emit(ActiveUserChanged(user: null));
  }

  FutureOr<void> _onLoadGame(LoadGame event, Emitter<MasterPageState> emit) {
    emit(LoadedGame(game: event.game));
  }
}
