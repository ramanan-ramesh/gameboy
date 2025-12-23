import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/blocs/app/bloc.dart';
import 'package:gameboy/blocs/app/states.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:gameboy/data/app/models/app_data.dart';
import 'package:gameboy/data/auth/models/status.dart';
import 'package:gameboy/presentation/app/pages/games_list_view/games_list_view.dart';
import 'package:gameboy/presentation/app/pages/startup_page.dart';
import 'package:gameboy/presentation/app/theming/light_theme_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theming/dark_theme_data.dart';
import 'update_dialog.dart';

class MasterPage extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const MasterPage(this.sharedPreferences);

  @override
  Widget build(BuildContext context) => BlocProvider<MasterPageBloc>(
        create: (context) => MasterPageBloc(sharedPreferences),
        child: RepositoryProvider<AppDataFacade>(
          create: (BuildContext context) =>
              (BlocProvider.of<MasterPageBloc>(context).state
                      as LoadedAppDataRepository)
                  .appData,
          child: _ContentPageRouter(),
        ),
      );
}

class _ContentPageRouter extends StatefulWidget {
  const _ContentPageRouter();

  @override
  State<_ContentPageRouter> createState() => _ContentPageLoader();
}

class _ContentPageLoader extends State<_ContentPageRouter> {
  static const String _appTitle = 'gameboy';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MasterPageBloc, MasterPageState>(
      builder: (BuildContext pageContext, MasterPageState state) {
        var appLevelData = context.appDataRepository;
        var currentTheme = appLevelData.activeThemeMode;
        return MaterialApp(
          title: _appTitle,
          debugShowCheckedModeBanner: false,
          darkTheme: createDarkThemeData(),
          themeMode: currentTheme,
          theme: createLightThemeData(),
          home: _ContentPage(),
        );
      },
      buildWhen: (previousState, currentState) =>
          currentState is ThemeModeToggled,
      listener: (BuildContext context, MasterPageState state) {},
    );
  }
}

class _ContentPage extends StatelessWidget {
  const _ContentPage();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MasterPageBloc, MasterPageState>(
      builder: (BuildContext pageContext, MasterPageState state) => Material(
        child: SafeArea(
          child: context.activeUser == null
              ? const StartupPage()
              : const GamesListView(),
        ),
      ),
      buildWhen: (previousState, currentState) =>
          currentState is AuthStateChanged &&
          (currentState.authStatus == AuthStatus.loggedIn ||
              currentState.authStatus == AuthStatus.loggedOut),
      listenWhen: (previousState, currentState) =>
          currentState is UpdateAvailable,
      listener: (BuildContext context, MasterPageState state) {
        if (state is UpdateAvailable) {
          _showUpdateDialog(context, state);
        }
      },
    );
  }

  void _showUpdateDialog(BuildContext context, UpdateAvailable state) {
    showDialog(
      context: context,
      barrierDismissible: !state.updateInfo.isForceUpdate,
      builder: (BuildContext dialogContext) {
        return UpdateDialog(
          updateInfo: state.updateInfo,
        );
      },
    );
  }
}
