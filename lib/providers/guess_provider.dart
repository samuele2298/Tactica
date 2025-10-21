import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/guess_game.dart';

class GuessTicTacToeNotifier extends StateNotifier<GuessTicTacToeGame> {
  GuessTicTacToeNotifier() : super(GuessTicTacToeGame.initial());

  // L'utente piazza una scommessa su dove AI1 giocherà
  void placeBet(int cellIndex) async {
    if (state.status != GuessGameStatus.waitingForBet) return;
    
    state = state.placeBet(cellIndex);
    
    // Aspetta un momento per mostrare la scommessa
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      // AI1 fa la sua mossa
      state = state.makeAI1Move();
      
      // Se il gioco continua, AI2 fa la sua mossa
      if (state.status == GuessGameStatus.ai2Turn) {
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) {
          state = state.makeAI2Move();
        }
      }
    }
  }

  void resetGame() {
    state = state.reset();
  }
}

// Provider per il gioco Guess & Bet
final guessTicTacToeProvider = 
    StateNotifierProvider<GuessTicTacToeNotifier, GuessTicTacToeGame>((ref) {
  return GuessTicTacToeNotifier();
});