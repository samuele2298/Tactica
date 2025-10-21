import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tic_tac_toe_game.dart';
import '../models/ai_difficulty.dart';

class TicTacToeNotifier extends StateNotifier<TicTacToeGame> {
  TicTacToeNotifier() : super(TicTacToeGame.initial());

  void makeHumanMove(int index) async {
    // Mossa del giocatore
    state = state.makeHumanMove(index);
    
    // Se il gioco continua e tocca all'AI, aspetta un momento e fai la mossa AI
    if (state.status == GameStatus.playing && state.currentPlayer == Player.ai) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted && state.currentPlayer == Player.ai) {
        state = state.makeAIMove();
      }
    }
  }

  void resetGame({AIStrategy? aiStrategy}) {
    state = state.reset(aiStrategy: aiStrategy);
  }

  void setAIStrategy(AIStrategy aiStrategy) {
    state = state.copyWith(aiStrategy: aiStrategy);
  }
}

// Provider per il gioco tic-tac-toe
final ticTacToeProvider = StateNotifierProvider<TicTacToeNotifier, TicTacToeGame>((ref) {
  return TicTacToeNotifier();
});