import 'package:flutter_bloc/flutter_bloc.dart';

import 'game_state.dart';

abstract class GameBloc<TEvent, TState extends GameState>
    extends Bloc<TEvent, TState> {
  GameBloc(super.initialState);
}
