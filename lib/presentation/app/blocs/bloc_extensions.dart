import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_data.dart';

import 'authentication/auth_bloc.dart';
import 'authentication/auth_events.dart';
import 'master_page/master_page_bloc.dart';
import 'master_page/master_page_events.dart';
import 'master_page/master_page_states.dart';

extension BlocProviderExt on BuildContext {
  void addAuthenticationEvent(AuthenticationEvent event) {
    BlocProvider.of<AuthenticationBloc>(this).add(event);
  }

  void addMasterPageEvent(MasterPageEvent event) {
    BlocProvider.of<MasterPageBloc>(this).add(event);
  }

  GameData get currentGameData =>
      (BlocProvider.of<MasterPageBloc>(this).state as LoadedGame).gameData;
}
