import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tic_tac_toe_game.dart';
import '../models/enums.dart';
import 'global_progress_provider.dart';

class TicTacToeNotifier extends StateNotifier<TicTacToeGame> {
  final Ref ref;
  
  TicTacToeNotifier(this.ref) : super(TicTacToeGame.initial());

  void makeHumanMove(int index) async {
    // Mossa del giocatore
    state = state.makeHumanMove(index);
    
    // Controlla se il gioco è finito dopo la mossa umana
    if (state.status == GameStatus.humanWon) {
      // Record victory for achievements
      ref.read(globalProgressProvider.notifier).recordVictory(
        gameMode: 'classic', 
        difficulty: state.aiStrategy.difficulty,
        strategyName: state.aiStrategy.name
      );
    }
    
    // Se il gioco continua e tocca all'AI, aspetta un momento e fai la mossa AI
    if (state.status == GameStatus.playing && state.currentPlayer == Player.ai) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted && state.currentPlayer == Player.ai) {
        state = state.makeAIMove();
        
        // Controlla se il gioco è finito dopo la mossa AI
        if (state.status == GameStatus.humanWon) {
          // Record victory for achievements
          ref.read(globalProgressProvider.notifier).recordVictory(
            gameMode: 'classic', 
            difficulty: state.aiStrategy.difficulty,
            strategyName: state.aiStrategy.name
          );
        }
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
  return TicTacToeNotifier(ref);
});