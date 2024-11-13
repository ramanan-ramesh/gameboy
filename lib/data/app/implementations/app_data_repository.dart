import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gameboy/data/app/implementations/firebase_options.dart';
import 'package:gameboy/data/app/implementations/user_management.dart';
import 'package:gameboy/data/app/models/app_data_facade.dart';
import 'package:gameboy/data/app/models/app_data_modifier.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/data/app/models/platform_user.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppDataRepository extends AppDataModifier {
  static AppDataRepository? _appDataRepository;
  static const String _googleWebClientIdField = 'webClientId';
  static const String _platformDataBox = 'platformData';
  static const String _themeMode = "themeMode";
  static const _appConfigField = 'appConfig';

  @override
  ThemeMode activeThemeMode;

  @override
  PlatformUserFacade? get activeUser => _userManagementImpl.activeUser;
  final UserManagementImpl _userManagementImpl;

  @override
  String googleWebClientId;

  @override
  bool isBigLayout = false;

  AppDataRepository._({
    required this.googleWebClientId,
    required UserManagementImpl userManagement,
    required this.activeThemeMode,
  })  : _userManagementImpl = userManagement,
        _games = [
          Game(name: 'Wordle', imageAsset: 'assets/wordle/logo.webp'),
          Game(name: 'Spelling-Bee', imageAsset: 'assets/spelling_bee/logo.png')
        ];

  static Future<AppDataFacade> create() async {
    if (_appDataRepository != null) {
      return _appDataRepository!;
    }
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    var appConfigReference =
        FirebaseDatabase.instance.ref().child(_appConfigField);
    var googleWebClientIdField =
        await appConfigReference.child(_googleWebClientIdField).get();
    var googleWebClientId = googleWebClientIdField.value as String;
    await Hive.initFlutter();
    var userManagement = await UserManagementImpl.create();
    var platformDataBox = await Hive.openBox(_platformDataBox);
    var themeModeValue = await platformDataBox.get(_themeMode);
    await platformDataBox.close();
    ThemeMode themeMode = themeModeValue is String
        ? (ThemeMode.values
            .firstWhere((element) => element.name == themeModeValue))
        : ThemeMode.dark;

    return AppDataRepository._(
        googleWebClientId: googleWebClientId,
        userManagement: userManagement,
        activeThemeMode: themeMode);
  }

  @override
  Future updateActiveThemeMode(ThemeMode themeMode) async {
    var platformLocalBox = await Hive.openBox(_platformDataBox);
    await _writeRecordToLocalStorage(
        platformLocalBox, _themeMode, themeMode.name);
    await platformLocalBox.close();
    activeThemeMode = themeMode;
  }

  @override
  Future updateActiveUser(User? platformUser) async {
    if (platformUser != null) {
      await _userManagementImpl.tryUpdateActiveUser(
          authProviderUser: platformUser);
    } else {
      await _userManagementImpl.trySignOut();
    }
  }

  @override
  void updateLayoutType(bool isBigLayout) {}

  @override
  Iterable<Game> get games => _games;
  List<Game> _games;

  Future _writeRecordToLocalStorage(
      Box hiveBox, String recordKey, String recordValue) async {
    await hiveBox.put(recordKey, recordValue);
  }
}
