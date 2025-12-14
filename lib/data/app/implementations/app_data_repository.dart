import 'package:gameboy/data/app/constants.dart';
import 'package:gameboy/data/app/models/app_data.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/data/auth/implementation/user_management.dart';
import 'package:gameboy/data/auth/models/platform_user.dart';
import 'package:gameboy/data/auth/models/user_management.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDataRepository extends AppDataModifier {
  static AppDataRepository? _appDataRepository;

  @override
  PlatformUser? get activeUser => _userManagement.activeUser;

  @override
  UserManagementModifier get userManagement => _userManagement;
  final UserManagementModifier _userManagement;

  static AppDataModifier create(SharedPreferences sharedPreferences) {
    if (_appDataRepository != null) {
      return _appDataRepository!;
    }
    var userManagement = UserManagement.create(sharedPreferences);

    return AppDataRepository._(userManagement: userManagement);
  }

  @override
  Iterable<Game> get games => _games;
  final List<Game> _games;

  AppDataRepository._({required UserManagementModifier userManagement})
      : _userManagement = userManagement,
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
        ];
}
