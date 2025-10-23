import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/guess_game.dart';
import '../models/guess_strategy_progress.dart';
import '../strategies/guess/guess_ai_strategy.dart';
import 'global_progress_provider.dart';

class GuessNotifierState {
  final GuessTicTacToeGame game;
  final GuessAIStrategy currentStrategy;
  final GuessStrategyProgress strategyProgress;
  final List<int> playerBetHistory;

  const GuessNotifierState({
    required this.game,
    required this.currentStrategy,
    required this.strategyProgress,
    required this.playerBetHistory,
  });

  GuessNotifierState copyWith({
    GuessTicTacToeGame? game,
    GuessAIStrategy? currentStrategy,
    GuessStrategyProgress? strategyProgress,
    List<int>? playerBetHistory,
  }) {
    return GuessNotifierState(
      game: game ?? this.game,
      currentStrategy: currentStrategy ?? this.currentStrategy,
      strategyProgress: strategyProgress ?? this.strategyProgress,
      playerBetHistory: playerBetHistory ?? this.playerBetHistory,
    );
  }
}

class GuessNotifier extends StateNotifier<GuessNotifierState> {
  final Ref ref;
  
  GuessNotifier(this.ref) : super(GuessNotifierState(
    game: GuessTicTacToeGame.initial(),
    currentStrategy: GuessAIStrategy.sequential,
    strategyProgress: GuessStrategyProgress(),
    playerBetHistory: [],
  ));

  // Cambia la strategia AI
  void changeStrategy(GuessAIStrategy newStrategy) {
    state = state.copyWith(
      currentStrategy: newStrategy,
      game: GuessTicTacToeGame.initial(), // Reset del gioco con nuova strategia
    );
  }

  // L'utente piazza una scommessa su dove AI1 giocherà
  void placeBet(int cellIndex) async {
    if (state.game.status != GuessGameStatus.waitingForBet) return;
    
    // Registra la scommessa nella cronologia
    final updatedHistory = List<int>.from(state.playerBetHistory)..add(cellIndex);
    
    // Piazza la scommessa
    var updatedGame = state.game.placeBet(cellIndex);
    
    state = state.copyWith(
      game: updatedGame,
      playerBetHistory: updatedHistory,
    );
    
    // Aspetta un momento per mostrare la scommessa
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      // AI1 fa la sua mossa usando la strategia selezionata
      updatedGame = _makeAI1Move(updatedGame);
      state = state.copyWith(game: updatedGame);
      
      // Se il gioco continua, AI2 fa la sua mossa
      if (updatedGame.status == GuessGameStatus.ai2Turn) {
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) {
          updatedGame = _makeAI2Move(updatedGame);
          state = state.copyWith(game: updatedGame);
          
          // Processa il risultato del gioco
          if (updatedGame.status == GuessGameStatus.gameOver) {
            _processGameResult(updatedGame, cellIndex);
          }
        }
      }
    }
  }

  // Fa la mossa dell'AI1 usando la strategia selezionata
  GuessTicTacToeGame _makeAI1Move(GuessTicTacToeGame game) {
    final strategy = GuessAIStrategyFactory.createStrategy(state.currentStrategy);
    final ai1Move = strategy.selectAI1Move(game, state.playerBetHistory);
    return game.makeAI1Move(ai1Move);
  }

  // Fa la mossa dell'AI2 usando la strategia selezionata
  GuessTicTacToeGame _makeAI2Move(GuessTicTacToeGame game) {
    final strategy = GuessAIStrategyFactory.createStrategy(state.currentStrategy);
    final ai2Move = strategy.selectAI2Move(game, state.playerBetHistory);
    return game.makeAI2Move(ai2Move);
  }

  // Processa il risultato del gioco e aggiorna le statistiche
  void _processGameResult(GuessTicTacToeGame game, int playerBet) {
    final updatedProgress = GuessStrategyProgress.fromMapFactory(state.strategyProgress.toMap());
    
    // Determina se la scommessa era corretta
    final ai1ActualMove = game.ai1Moves.isNotEmpty ? game.ai1Moves.last : -1;
    final guessedCorrectly = playerBet == ai1ActualMove;
    
    // Determina il vincitore
    String winner = 'Tie';
    if (game.winner == GuessPlayer.ai1) {
      winner = 'AI1';
    } else if (game.winner == GuessPlayer.ai2) {
      winner = 'AI2';
    }
    
    // Record victory for achievements - player wins by guessing correctly
    if (guessedCorrectly) {
      final strategyImpl = GuessAIStrategyFactory.createStrategy(state.currentStrategy);
      ref.read(globalProgressProvider.notifier).recordVictory(
        gameMode: 'guess', 
        difficulty: strategyImpl.difficulty,
        strategyName: strategyImpl.displayName
      );
    }
    
    // Aggiorna le statistiche
    updatedProgress.updateStats(
      guessedCorrectly: guessedCorrectly,
      winner: winner,
    );
    
    state = state.copyWith(strategyProgress: updatedProgress);
  }
  


  void resetGame() {
    state = state.copyWith(
      game: GuessTicTacToeGame.initial(),
    );
  }

  // Resetta le statistiche
  void resetStats() {
    final resetProgress = GuessStrategyProgress();
    state = state.copyWith(strategyProgress: resetProgress);
  }
}

// Provider per il gioco Guess con strategie
final guessNotifierProvider = 
    StateNotifierProvider<GuessNotifier, GuessNotifierState>((ref) {
  return GuessNotifier(ref);
});

// Provider legacy per compatibilità con la UI esistente
final guessTicTacToeProvider = 
    StateNotifierProvider<GuessTicTacToeNotifier, GuessTicTacToeGame>((ref) {
  return GuessTicTacToeNotifier();
});

// Classe legacy per compatibilità
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