import 'package:equatable/equatable.dart';
import 'package:gameboy/asset_manager/assets.gen.dart';
import 'package:gameboy/asset_manager/extension.dart';

class Game extends Equatable {
  final String name;
  final String description;
  final AssetGenImage imageAsset;
  Game({required this.name, required this.description})
      : imageAsset = Assets.logos.values.singleWhere((logoAsset) =>
            logoAsset.fileName.toLowerCase() == name.toLowerCase());

  @override
  List<Object?> get props => [name, description, imageAsset];
}
