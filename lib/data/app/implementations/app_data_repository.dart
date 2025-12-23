import 'package:flutter/src/material/app.dart';
import 'package:gameboy/data/app/constants.dart';
import 'package:gameboy/data/app/models/app_data.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/data/auth/implementation/user_management.dart';
import 'package:gameboy/data/auth/models/platform_user.dart';
import 'package:gameboy/data/auth/models/user_management.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDataRepository extends AppDataModifier {
  static const _themeModeKey = 'themeMode';

  @override
  PlatformUser? get activeUser => _userManagement.activeUser;

  @override
  UserManagementModifier get userManagement => _userManagement;
  final UserManagementModifier _userManagement;

  static AppDataModifier create(SharedPreferences sharedPreferences) {
    var userManagement = UserManagement.create(sharedPreferences);
    var themeModeValue = sharedPreferences.getString(_themeModeKey);
    var themeMode = themeModeValue is String
        ? (ThemeMode.values
            .firstWhere((element) => element.name == themeModeValue))
        : ThemeMode.dark;
    return AppDataRepository._(
        userManagement: userManagement,
        activeThemeMode: themeMode,
        localStorage: sharedPreferences);
  }

  @override
  Iterable<Game> get games => _games;
  final List<Game> _games;

  @override
  ThemeMode activeThemeMode = ThemeMode.dark;

  final SharedPreferences _localStorage;

  @override
  Future toggleThemeMode() async {
    var themeModeToSet =
        activeThemeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _localStorage.setString(_themeModeKey, activeThemeMode.name);
    activeThemeMode = themeModeToSet;
  }

  AppDataRepository._(
      {required UserManagementModifier userManagement,
      required this.activeThemeMode,
      required SharedPreferences localStorage})
      : _userManagement = userManagement,
        _localStorage = localStorage,
        _games = [
          Game(
              name: AppConstants.wordsyGameIdentifier,
              description: 'Guess the word of the day in 6 attempts'),
          Game(
              name: AppConstants.beeWiseGameIdentifier,
              description:
                  'Find as many words as you can from the 7 letter hive'),
          Game(
              name: AppConstants.alphaBoundGameIdentifier,
              description: 'Navigate the dictionary to find the secret word'),
          Game(
              name: AppConstants.lexBoxGameIdentifier,
              description:
                  'Make words by connecting letters on a square\'s sides. Use all 12 letters to win.'),
        ];
}
