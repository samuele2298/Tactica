import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/simultaneous_game.dart';

class SimultaneousTicTacToeNotifier extends StateNotifier<SimultaneousTicTacToeGame> {
  SimultaneousTicTacToeNotifier() : super(SimultaneousTicTacToeGame.initial());

  void selectMove(int index) {
    state = state.selectHumanMove(index);
  }

  void confirmMove() async {
    if (state.humanSelectedMove != null) {
      // Esegui il turno simultaneo
      state = state.executeSimultaneousTurn();
      
      // Aspetta un momento per mostrare la rivelazione
      if (state.status == SimultaneousGameStatus.revealing) {
        await Future.delayed(const Duration(milliseconds: 2000));
        if (mounted && state.status == SimultaneousGameStatus.revealing) {
          state = state.prepareNextTurn();
        }
      }
    }
  }

  void resetGame() {
    state = state.reset();
  }
}

// Provider per il gioco simultaneo
final simultaneousTicTacToeProvider = 
    StateNotifierProvider<SimultaneousTicTacToeNotifier, SimultaneousTicTacToeGame>((ref) {
  return SimultaneousTicTacToeNotifier();
});