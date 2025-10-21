import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coop_game.dart';

class CoopTicTacToeNotifier extends StateNotifier<CoopTicTacToeGame> {
  CoopTicTacToeNotifier() : super(CoopTicTacToeGame.initial());

  void makeHumanMove(int index) async {
    // Mossa del giocatore
    state = state.makeHumanMove(index);
    
    // Se il gioco continua, fai la mossa dell'AI nemica
    if (state.status == CoopGameStatus.enemyAiTurn) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted && state.status == CoopGameStatus.enemyAiTurn) {
        state = state.makeEnemyAIMove();
        
        // Poi la mossa dell'AI amica
        if (state.status == CoopGameStatus.friendlyAiTurn) {
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted && state.status == CoopGameStatus.friendlyAiTurn) {
            state = state.makeFriendlyAIMove();
          }
        }
      }
    }
  }

  void resetGame() {
    state = state.reset();
  }
}

// Provider per il gioco cooperativo
final coopTicTacToeProvider = 
    StateNotifierProvider<CoopTicTacToeNotifier, CoopTicTacToeGame>((ref) {
  return CoopTicTacToeNotifier();
});