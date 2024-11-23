import 'package:gameboy/data/app/models/platform_user.dart';

class PlatformUserImpl implements PlatformUserDBRef {
  static const String _userNameKey = 'userName';
  static const String _photoUrlKey = 'photoUrl';
  static const String _displayNameKey = 'displayName';

  @override
  final String? displayName;

  @override
  final String? photoUrl;

  @override
  final String userID;

  @override
  final String userName;

  PlatformUserImpl(
      {this.displayName,
      this.photoUrl,
      required this.userID,
      required this.userName});

  @override
  Map<String, dynamic> toJson() {
    return {
      _userNameKey: userName,
      _photoUrlKey: photoUrl,
      _displayNameKey: displayName,
    };
  }
}
