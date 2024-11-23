import 'package:equatable/equatable.dart';

class Game extends Equatable {
  final String name;
  final String imageAsset;

  const Game({required this.name, required this.imageAsset});

  @override
  List<Object?> get props => [name, imageAsset];
}
