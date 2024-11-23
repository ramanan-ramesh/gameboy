import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/implementations/app_data_repository.dart';
import 'package:gameboy/data/app/models/app_data_facade.dart';
import 'package:gameboy/presentation/app/blocs/master_page/master_page_bloc.dart';
import 'package:gameboy/presentation/app/blocs/master_page/master_page_states.dart';
import 'package:gameboy/presentation/app/extensions.dart';
import 'package:gameboy/presentation/app/pages/games_list_view/games_list_view.dart';

import 'startup_page.dart';

class MasterPage extends StatefulWidget {
  const MasterPage({super.key});

  @override
  State<MasterPage> createState() => _MasterPageState();
}

class _MasterPageState extends State<MasterPage> {
  MasterPageBloc? _masterPageBloc;
  AppDataFacade? _appDataFacade;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AppDataRepository.create(),
      builder: (BuildContext context, AsyncSnapshot<AppDataFacade> snapshot) {
        if (_masterPageBloc != null) {
          return _buildMasterPage(_appDataFacade!);
        }
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          _appDataFacade = snapshot.data!;
          return _buildMasterPage(snapshot.data!);
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  @override
  void dispose() {
    _masterPageBloc?.close();
    super.dispose();
  }

  Widget _buildMasterPage(AppDataFacade appDataFacade) {
    return RepositoryProvider<AppDataFacade>(
      create: (context) => appDataFacade,
      child: BlocProvider<MasterPageBloc>(
        create: (context) {
          if (_masterPageBloc != null) {
            return _masterPageBloc!;
          }
          _masterPageBloc = MasterPageBloc(appDataFacade: appDataFacade);
          return _masterPageBloc!;
        },
        child: _ContentPage(),
      ),
    );
  }
}

class _ContentPage extends StatelessWidget {
  static const String _appTitle = 'Gameboy';

  const _ContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MasterPageBloc, MasterPageState>(
      listener: (context, state) {},
      builder: (context, state) {
        var appLevelData = context.getAppData();
        var currentTheme = appLevelData.activeThemeMode;
        return MaterialApp(
          title: _appTitle,
          debugShowCheckedModeBanner: false,
          darkTheme: _createDarkThemeData(context),
          themeMode: currentTheme,
          home: Material(
            child: DropdownButtonHideUnderline(
              child: SafeArea(
                child: _buildContentPage(context),
              ),
            ),
          ),
        );
      },
    );
  }

  ThemeData _createDarkThemeData(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(Colors.green),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.black),
          foregroundColor: WidgetStatePropertyAll(Colors
              .green), //TODO: Is this the right way to set text color? Note: TextStyle(color: Colors.black) doesn't work, so how else to theme the color?
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.green),
      listTileTheme: ListTileThemeData(
        tileColor: Colors.grey.shade900,
        textColor: Colors.green,
        iconColor: Colors.green,
        selectedTileColor: Colors.white10,
        selectedColor: Colors.green,
      ),
      cardTheme: CardTheme(color: Colors.grey.shade900),
      dividerTheme: DividerThemeData(
        color: Colors.green,
        indent: 20,
        endIndent: 20,
      ),
      popupMenuTheme: PopupMenuThemeData(),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          iconColor: WidgetStatePropertyAll(Colors.green),
          backgroundColor: WidgetStatePropertyAll(Colors.black),
          foregroundColor: WidgetStatePropertyAll(Colors.green),
        ),
      ),
      iconTheme: IconThemeData(color: Colors.green),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        splashColor: Colors.grey,
        backgroundColor: Colors.black,
        foregroundColor: Colors.green,
      ),
      tabBarTheme: TabBarTheme(
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: Theme.of(context).textTheme.headlineMedium,
        unselectedLabelStyle: Theme.of(context).textTheme.headlineMedium,
        indicatorColor: Colors.white10,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
      ),
      appBarTheme: AppBarTheme(
        color: Colors.grey.shade900,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelStyle: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        iconColor: Colors.green,
      ),
    );
  }

  Widget _buildContentPage(BuildContext context) {
    var activeUser = context.getAppData().activeUser;
    if (activeUser == null) {
      return StartupPage();
    } else {
      return GamesListView();
    }
  }
}
