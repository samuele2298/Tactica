import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nebel_game.dart';
import '../models/nebel_strategy_progress.dart';
import '../strategies/nebel/nebel_ai_strategy.dart';
import 'global_progress_provider.dart';

class NebelTicTacToeNotifier extends StateNotifier<NebelTicTacToeGame> {
  final Ref ref;
  final NebelStrategyProgress _strategyProgress = NebelStrategyProgress();
  NebelAIStrategy _currentStrategy = NebelAIStrategy.cautious;
  
  NebelTicTacToeNotifier(this.ref) : super(NebelTicTacToeGame.initial());

  // Getters
  NebelStrategyProgress get strategyProgress => _strategyProgress;
  NebelAIStrategy get currentStrategy => _currentStrategy;

  void changeStrategy(NebelAIStrategy strategy) {
    _currentStrategy = strategy;
    resetGame();
  }

  void makeHumanMove(int index) async {
    // Traccia la mossa del giocatore per le strategie AI
    _strategyProgress.addPlayerMove(index);
    
    // Mossa del giocatore
    state = state.makeHumanMove(index);
    
    // Processa il risultato del gioco se terminato
    if (state.status != NebelGameStatus.playing) {
      _processGameResult(state.status);
    }
    
    // Se il gioco continua e tocca all'AI, aspetta un momento e fai la mossa AI
    if (state.status == NebelGameStatus.playing && state.currentPlayer == NebelPlayer.ai) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted && state.currentPlayer == NebelPlayer.ai) {
        _makeAIMove();
      }
    }
  }
  
  void _makeAIMove() {
    // Usa la strategia AI corrente per scegliere la mossa
    final strategyImpl = NebelAIStrategyFactory.createStrategy(_currentStrategy);
    final aiMove = strategyImpl.selectMove(state, _strategyProgress.getPlayerMoveHistory());
    
    // Esegui la mossa AI
    state = state.makeAIMove(aiMove);
    
    // Processa il risultato del gioco se terminato
    if (state.status != NebelGameStatus.playing) {
      _processGameResult(state.status);
    }
  }
  
  void _processGameResult(NebelGameStatus status) {
    switch (status) {
      case NebelGameStatus.humanWon:
        _strategyProgress.addWin(_currentStrategy);
        // Record victory for achievements
        final strategyImpl = NebelAIStrategyFactory.createStrategy(_currentStrategy);
        ref.read(globalProgressProvider.notifier).recordVictory(
          gameMode: 'nebel', 
          difficulty: strategyImpl.difficulty,
          strategyName: strategyImpl.displayName
        );
        break;
      case NebelGameStatus.aiWon:
      case NebelGameStatus.tie:
        _strategyProgress.addLoss(_currentStrategy);
        break;
      case NebelGameStatus.playing:
        // Gioco in corso, nessuna azione
        break;
    }
  }
  


  void resetGame() {
    state = NebelTicTacToeGame.initial();
  }
}

// Provider per il gioco Nebel
final nebelTicTacToeProvider = 
    StateNotifierProvider<NebelTicTacToeNotifier, NebelTicTacToeGame>((ref) {
  return NebelTicTacToeNotifier(ref);
});