import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nebel_game.dart';

class NebelTicTacToeNotifier extends StateNotifier<NebelTicTacToeGame> {
  NebelTicTacToeNotifier() : super(NebelTicTacToeGame.initial());

  void makeHumanMove(int index) async {
    // Mossa del giocatore
    state = state.makeHumanMove(index);
    
    // Se il gioco continua e tocca all'AI, aspetta un momento e fai la mossa AI
    if (state.status == NebelGameStatus.playing && state.currentPlayer == NebelPlayer.ai) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted && state.currentPlayer == NebelPlayer.ai) {
        state = state.makeAIMove();
      }
    }
  }

  void resetGame() {
    state = state.reset();
  }
}

// Provider per il gioco Nebel
final nebelTicTacToeProvider = 
    StateNotifierProvider<NebelTicTacToeNotifier, NebelTicTacToeGame>((ref) {
  return NebelTicTacToeNotifier();
});