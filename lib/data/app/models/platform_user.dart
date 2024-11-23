class PlatformUserFacade {
  final String userName;
  final String userID;
  final String? displayName;
  final String? photoUrl;

  PlatformUserFacade({
    required this.userName,
    required this.userID,
    this.photoUrl,
    this.displayName,
  });
}

abstract class PlatformUserDBRef extends PlatformUserFacade {
  PlatformUserDBRef({required super.userName, required super.userID});

  Map<String, dynamic> toJson();
}
