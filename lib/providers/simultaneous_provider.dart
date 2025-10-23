import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/simultaneous_game.dart';
import '../models/simultaneous_strategy_progress.dart';
import '../strategies/simultaneous/simultaneous_ai_strategy.dart';
import 'global_progress_provider.dart';

class SimultaneousTicTacToeNotifier extends StateNotifier<SimultaneousTicTacToeGame> {
  final Ref ref;
  final SimultaneousStrategyProgress _strategyProgress = SimultaneousStrategyProgress();
  SimultaneousAIStrategy _currentStrategy = SimultaneousAIStrategy.easy1;
  
  SimultaneousTicTacToeNotifier(this.ref) : super(SimultaneousTicTacToeGame.initial());

  // Getters
  SimultaneousStrategyProgress get strategyProgress => _strategyProgress;
  SimultaneousAIStrategy get currentStrategy => _currentStrategy;

  void selectMove(int index) {
    final newState = state.selectHumanMove(index);
    state = newState;
    
    // Se il gioco è finito con l'ultima mossa, non serve fare altro
    if (newState.isGameFinished) {
      return;
    }
  }

  void confirmMove() async {
    if (state.humanSelectedMove != null) {
      // Traccia la mossa del giocatore per le strategie AI
      _strategyProgress.addPlayerMove(state.humanSelectedMove!);
      
      // Esegui il turno simultaneo con la strategia corrente
      state = _executeSimultaneousTurnWithAI();
      
      // Aspetta un momento per mostrare la rivelazione
      if (state.status == SimultaneousGameStatus.revealing) {
        await Future.delayed(const Duration(milliseconds: 2000));
        if (mounted && state.status == SimultaneousGameStatus.revealing) {
          state = state.prepareNextTurn();
        }
      }
    }
  }

  SimultaneousTicTacToeGame _executeSimultaneousTurnWithAI() {
    if (state.status != SimultaneousGameStatus.selectingMoves || 
        state.humanSelectedMove == null) {
      return state;
    }

    // Ottieni le mosse disponibili
    final availableMoves = <int>[];
    for (int i = 0; i < state.board.length; i++) {
      if (state.board[i] == SimultaneousPlayer.none) {
        availableMoves.add(i);
      }
    }

    if (availableMoves.isEmpty) return state;

    // Usa la strategia AI corrente per scegliere la mossa
    final strategyImpl = SimultaneousAIStrategyFactory.createStrategy(_currentStrategy);
    final aiMove = strategyImpl.selectMove(state, _strategyProgress.getPlayerMoveHistory());

    // Esegui le mosse simultaneamente
    final newBoard = List<SimultaneousPlayer>.from(state.board);
    
    // Se entrambi scelgono la stessa cella, nessuno la ottiene (conflitto)
    if (state.humanSelectedMove == aiMove) {
      // Conflitto! Nessuno ottiene la cella
    } else {
      // Applica entrambe le mosse
      newBoard[state.humanSelectedMove!] = SimultaneousPlayer.human;
      newBoard[aiMove] = SimultaneousPlayer.ai;
    }

    final newStatus = _checkGameStatus(newBoard);
    final winningLine = _findWinningLine(newBoard);

    return state.copyWith(
      board: newBoard,
      status: newStatus == SimultaneousGameStatus.selectingMoves ? SimultaneousGameStatus.revealing : newStatus,
      winningLine: winningLine,
      aiSelectedMove: aiMove,
      isRevealingMoves: true,
    );
  }

  // Helper methods copiati dal modello per il provider
  SimultaneousGameStatus _checkGameStatus(List<SimultaneousPlayer> newBoard) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Righe
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonne
      [0, 4, 8], [2, 4, 6] // Diagonali
    ];

    for (final pattern in winPatterns) {
      final [a, b, c] = pattern;
      if (newBoard[a] != SimultaneousPlayer.none &&
          newBoard[a] == newBoard[b] &&
          newBoard[b] == newBoard[c]) {
        return newBoard[a] == SimultaneousPlayer.human 
            ? SimultaneousGameStatus.humanWon 
            : SimultaneousGameStatus.aiWon;
      }
    }

    // Controlla pareggio
    if (newBoard.every((cell) => cell != SimultaneousPlayer.none)) {
      return SimultaneousGameStatus.tie;
    }

    return SimultaneousGameStatus.selectingMoves;
  }

  List<int>? _findWinningLine(List<SimultaneousPlayer> board) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Righe
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonne
      [0, 4, 8], [2, 4, 6] // Diagonali
    ];

    for (final pattern in winPatterns) {
      final [a, b, c] = pattern;
      if (board[a] != SimultaneousPlayer.none &&
          board[a] == board[b] &&
          board[b] == board[c]) {
        return pattern;
      }
    }
    return null;
  }

  void changeStrategy(SimultaneousAIStrategy newStrategy) {
    _currentStrategy = newStrategy;
    resetGame();
  }

  void processGameResult(SimultaneousGameStatus status) {
    switch (status) {
      case SimultaneousGameStatus.humanWon:
        _strategyProgress.addWin(_currentStrategy);
        // Record victory for achievements
        final strategyImpl = SimultaneousAIStrategyFactory.createStrategy(_currentStrategy);
        ref.read(globalProgressProvider.notifier).recordVictory(
          gameMode: 'simultaneous', 
          difficulty: strategyImpl.difficulty,
          strategyName: strategyImpl.displayName
        );
        break;
      case SimultaneousGameStatus.aiWon:
      case SimultaneousGameStatus.tie:
        _strategyProgress.addLoss(_currentStrategy);
        break;
      default:
        break;
    }
  }
  


  void resetGame() {
    state = state.reset();
    _strategyProgress.resetGameHistory(); // Reset solo la storia delle mosse
  }

  void resetAllProgress() {
    _strategyProgress.reset();
    resetGame();
  }

  bool isStrategyDefeated(SimultaneousAIStrategy strategy) {
    return _strategyProgress.isDefeated(strategy);
  }

  int getConsecutiveWins(SimultaneousAIStrategy strategy) {
    return _strategyProgress.getConsecutiveWins(strategy);
  }
}

// Provider per il gioco simultaneo
final simultaneousTicTacToeProvider = 
    StateNotifierProvider<SimultaneousTicTacToeNotifier, SimultaneousTicTacToeGame>((ref) {
  return SimultaneousTicTacToeNotifier(ref);
});