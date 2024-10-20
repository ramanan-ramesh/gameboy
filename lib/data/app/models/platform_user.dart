class PlatformUserFacade {
  String userName;
  String userID;
  String? displayName;
  String? photoUrl;

  PlatformUserFacade({
    required this.userName,
    required this.userID,
    this.photoUrl,
    this.displayName,
  });
}
