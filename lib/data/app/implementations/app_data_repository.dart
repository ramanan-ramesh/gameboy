import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gameboy/data/app/constants.dart';
import 'package:gameboy/data/app/implementations/firebase_options.dart';
import 'package:gameboy/data/app/implementations/user_management.dart';
import 'package:gameboy/data/app/models/app_data_modifier.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/data/app/models/platform_user.dart';
import 'package:gameboy/data/app/models/user_management.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDataRepository extends AppDataModifier {
  static AppDataRepository? _appDataRepository;
  static const _appConfigDBField = 'appConfig';
  static const String _googleWebClientIdField = 'webClientId';

  @override
  PlatformUser? get activeUser => _userManagement.activeUser;
  final UserManagementFacade _userManagement;

  @override
  String googleWebClientId;

  static Future<AppDataModifier> create() async {
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
    var sharedPreferences = await SharedPreferences.getInstance();
    var userManagement = await UserManagementImpl.create(sharedPreferences);

    return AppDataRepository._(
        googleWebClientId: googleWebClientId, userManagement: userManagement);
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
  final List<Game> _games;

  AppDataRepository._(
      {required this.googleWebClientId,
      required UserManagementFacade userManagement})
      : _userManagement = userManagement,
        _games = [
          Game(name: AppConstants.wordsyGameIdentifier),
          Game(
            name: AppConstants.beeWiseGameIdentifier,
          ),
          Game(
            name: AppConstants.alphaBoundGameIdentifier,
          ),
        ];
}
