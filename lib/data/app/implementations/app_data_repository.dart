import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gameboy/data/app/constants.dart';
import 'package:gameboy/data/app/implementations/firebase_options.dart';
import 'package:gameboy/data/app/implementations/user_management.dart';
import 'package:gameboy/data/app/models/app_data.dart';
import 'package:gameboy/data/app/models/app_data_modifier.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/data/app/models/platform_user.dart';
import 'package:gameboy/data/app/models/user_management.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppDataRepository extends AppDataModifier {
  static AppDataRepository? _appDataRepository;
  static const String _localDataBoxName = 'localAppData';
  static const String _themeMode = "themeMode";
  static const _appConfigDBField = 'appConfig';
  static const String _googleWebClientIdField = 'webClientId';

  @override
  ThemeMode activeThemeMode;

  @override
  PlatformUser? get activeUser => _userManagement.activeUser;
  final UserManagementFacade _userManagement;

  @override
  String googleWebClientId;

  static Future<AppDataFacade> create() async {
    if (_appDataRepository != null) {
      return _appDataRepository!;
    }
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    var appConfigReference =
        FirebaseDatabase.instance.ref().child(_appConfigDBField);
    var googleWebClientIdField =
        await appConfigReference.child(_googleWebClientIdField).get();
    var googleWebClientId = googleWebClientIdField.value as String;
    await Hive.initFlutter();
    var userManagement = await UserManagementImpl.create();
    var platformDataBox = await Hive.openBox(_localDataBoxName);
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
    var platformLocalBox = await Hive.openBox(_localDataBoxName);
    await _writeRecordToLocalStorage(
        platformLocalBox, _themeMode, themeMode.name);
    await platformLocalBox.close();
    activeThemeMode = themeMode;
  }

  @override
  Future<bool> updateActiveUser(User? platformUser) async {
    if (platformUser != null) {
      return await _userManagement.tryUpdateActiveUser(
          authProviderUser: platformUser);
    } else {
      return await _userManagement.trySignOut();
    }
  }

  @override
  Iterable<Game> get games => _games;
  List<Game> _games;

  Future _writeRecordToLocalStorage(
      Box hiveBox, String recordKey, String recordValue) async {
    await hiveBox.put(recordKey, recordValue);
  }

  AppDataRepository._({
    required this.googleWebClientId,
    required UserManagementFacade userManagement,
    required this.activeThemeMode,
  })  : _userManagement = userManagement,
        _games = [
          Game(name: AppConstants.wordleGameIdentifier),
          Game(
            name: AppConstants.spellingBeeGameIdentifier,
          ),
          Game(
            name: AppConstants.alphaBoundGameIdentifier,
          ),
        ];
}
