import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/extensions.dart';
import 'package:gameboy/presentation/wordle/bloc/bloc.dart';
import 'package:gameboy/presentation/wordle/bloc/states.dart';
import 'package:gameboy/presentation/wordle/pages/game_layout.dart';

class Wordle extends StatelessWidget {
  const Wordle({super.key});

  @override
  Widget build(BuildContext context) {
    var userId = context.getAppData().activeUser!.userID;
    return BlocProvider<WordleGameBloc>(
      create: (BuildContext context) => WordleGameBloc(userId),
      child: BlocBuilder<WordleGameBloc, WordleState>(
        buildWhen: (previousState, currentState) {
          if (currentState is WordleLoaded) {
            return true;
          } else if (currentState is WordleLoaded) {
            return true;
          }
          return false;
        },
        builder: (context, state) {
          if (state is WordleLoaded) {
            return MultiRepositoryProvider(
              providers: [
                RepositoryProvider(create: (context) => state.wordleStats),
                RepositoryProvider(create: (context) => state.gameEngineData)
              ],
              child: GameLayout(),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
