import 'package:flutter_bloc/flutter_bloc.dart';

import 'game_state.dart';

abstract class GameBloc<Event, State extends GameState>
    extends Bloc<Event, State> {
  GameBloc(super.initialState);
}
