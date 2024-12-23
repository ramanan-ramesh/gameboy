import 'package:equatable/equatable.dart';

class Game extends Equatable {
  final String name;
  final String imageAsset;
  static const _logoAssetPath = 'assets/logos';

  Game({required this.name})
      : imageAsset =
            '$_logoAssetPath/${_convertGameNameToAssetName(name)}.webp';

  static String _convertGameNameToAssetName(String gameName) {
    return gameName
        .split(RegExp(r'[-\s]'))
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join()
        .replaceFirstMapped(
            RegExp(r'^[A-Z]'), (match) => match.group(0)!.toLowerCase());
  }

  @override
  List<Object?> get props => [name, imageAsset];
}
