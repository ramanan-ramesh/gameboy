import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:gameboy/data/app/models/app_data.dart';
import 'package:gameboy/presentation/app/blocs/master_page/master_page_bloc.dart';
import 'package:gameboy/presentation/app/blocs/master_page/master_page_states.dart';
import 'package:gameboy/presentation/app/pages/games_list_view/games_list_view.dart';
import 'package:gameboy/presentation/app/theming/dark_theme_data.dart';
import 'package:rive/rive.dart';

import 'startup_page.dart';

class MasterPage extends StatelessWidget {
  static const String _appTitle = 'gameboy';
  const MasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _appTitle,
      debugShowCheckedModeBanner: false,
      darkTheme: createDarkThemeData(context),
      themeMode: ThemeMode.dark,
      theme: createDarkThemeData(context),
      home: Material(
        child: SafeArea(
          child: BlocProvider<MasterPageBloc>(
            create: (context) => MasterPageBloc(),
            child: const _AppDataRepositoryLoader(),
          ),
        ),
      ),
    );
    ;
  }
}

class _AppDataRepositoryLoader extends StatefulWidget {
  const _AppDataRepositoryLoader({super.key});

  @override
  State<_AppDataRepositoryLoader> createState() =>
      _AppDataRepositoryLoaderState();
}

class _AppDataRepositoryLoaderState extends State<_AppDataRepositoryLoader> {
  var _hasMinimumAnimationTimePassed = false;
  static final _animationController = SimpleAnimation('Hover');
  static const _minimumAnimationTime = Duration(seconds: 2);

  @override
  Widget build(BuildContext context) {
    if (BlocProvider.of<MasterPageBloc>(context).state
        is LoadingAppDataRepository) {
      if (!_hasMinimumAnimationTimePassed) {
        _tryStartLoadingAnimation();
      }
    }
    return BlocConsumer<MasterPageBloc, MasterPageState>(
      builder: (BuildContext context, MasterPageState state) {
        if (state is LoadedAppDataRepository &&
            _hasMinimumAnimationTimePassed) {
          return RepositoryProvider<AppDataFacade>(
            create: (BuildContext context) => state.appData,
            child: const _ContentPage(),
          );
        }
        return _createAnimatedLoadingScreen(context);
      },
      buildWhen: (previousState, currentState) {
        return previousState != currentState &&
                currentState is LoadedAppDataRepository ||
            currentState is LoadingAppDataRepository;
      },
      listener: (BuildContext context, MasterPageState state) {
        if (state is LoadingAppDataRepository) {
          _tryStartLoadingAnimation();
        }
      },
    );
  }

  Widget _createAnimatedLoadingScreen(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          RiveAnimation.asset(
            'assets/game_loading.riv',
            fit: BoxFit.fitHeight,
            controllers: [
              _animationController,
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                'Loading user data and theme',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _tryStartLoadingAnimation() {
    _hasMinimumAnimationTimePassed = false;
    Future.delayed(_minimumAnimationTime, () {
      setState(() {
        _hasMinimumAnimationTimePassed = true;
      });
    });
  }
}

class _ContentPage extends StatelessWidget {
  const _ContentPage();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MasterPageBloc, MasterPageState>(
      builder: (BuildContext context, MasterPageState state) {
        return context.activeUser == null
            ? const StartupPage()
            : const GamesListView();
      },
      buildWhen: (previousState, currentState) {
        return currentState is ActiveUserChanged;
      },
      listener: (BuildContext context, MasterPageState state) {},
    );
  }
}
