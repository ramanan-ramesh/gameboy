class PlatformUser {
  final String userName;
  final String id;
  final String? displayName;
  final String? photoUrl;

  PlatformUser({
    required this.userName,
    required this.id,
    this.photoUrl,
    this.displayName,
  });
}
