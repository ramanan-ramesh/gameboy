import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/presentation/app/pages/game_content_page/game_layout.dart';

import 'game_bloc.dart';

class GameData<TGameBloc extends GameBloc> {
  TGameBloc gameBloc;
  GameLayout gameLayout;
  Game game;
  GameData(
      {required this.gameBloc, required this.gameLayout, required this.game});
}
