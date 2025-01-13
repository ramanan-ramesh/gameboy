import 'package:equatable/equatable.dart';

class Game extends Equatable {
  final String name;
  final String imageAsset;
  static const _logoAssetPath = 'assets/logos';

  Game({required this.name})
      : imageAsset =
            '$_logoAssetPath/${_convertGameNameToAssetName(name)}.webp';

  static String _convertGameNameToAssetName(String input) {
    final words = input.split(RegExp(r'[^a-zA-Z0-9]+'));

    return words.asMap().entries.map((entry) {
      final index = entry.key;
      final word = entry.value;

      if (index == 0) {
        return word[0].toLowerCase() + word.substring(1);
      } else {
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }
    }).join();
  }

  @override
  List<Object?> get props => [name, imageAsset];
}
