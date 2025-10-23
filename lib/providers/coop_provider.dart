import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coop_game.dart';
import '../models/coop_strategy_progress.dart';
import '../strategies/coop/coop_ai_strategy.dart';
import 'global_progress_provider.dart';

class CoopTicTacToeNotifier extends StateNotifier<CoopTicTacToeGame> {
  final CoopStrategyProgress _strategyProgress = CoopStrategyProgress();
  final Ref _ref;
  CoopAIStrategy _currentStrategy = CoopAIStrategy.supportive;
  int _turnCounter = 0; // Per tracciare l'ordine dei turni
  
  CoopTicTacToeNotifier(this._ref) : super(CoopTicTacToeGame.initial()) {
    // L'umano inizia per primo, non serve auto-start
  }

  // Getters
  CoopStrategyProgress get strategyProgress => _strategyProgress;
  CoopAIStrategy get currentStrategy => _currentStrategy;

  void changeStrategy(CoopAIStrategy strategy) {
    _currentStrategy = strategy;
    resetGame();
  }

  void processGameResult(CoopGameStatus status) {
    if (status == CoopGameStatus.teamWon) {
      _strategyProgress.addWin(_currentStrategy);
      
      // Registra achievement globale
      final strategyImpl = CoopAIStrategyFactory.createStrategy(_currentStrategy);
      _ref.read(globalProgressProvider.notifier).recordVictory(
        gameMode: 'coop',
        difficulty: strategyImpl.difficulty,
        strategyName: strategyImpl.displayName,
      );
    } else if (status == CoopGameStatus.enemyWon || status == CoopGameStatus.tie) {
      _strategyProgress.addLoss(_currentStrategy);
    }
  }

  /// Gestisce l'ordine corretto dei turni: Umano -> AI nemica -> AI amica -> AI nemica -> Umano -> ...
  void _executeTurn() async {
    // Continua a eseguire turni AI finché non tocca all'umano
    while (state.status != CoopGameStatus.humanTurn && !_isGameFinished()) {
      if (state.status == CoopGameStatus.friendlyAiTurn) {
        state = _makeFriendlyAIMove();
        _turnCounter++;
        
        if (!_isGameFinished()) {
          await Future.delayed(const Duration(milliseconds: 800));
        }
      } else if (state.status == CoopGameStatus.enemyAiTurn) {
        state = _makeEnemyAIMove();
        _turnCounter++;
        
        if (!_isGameFinished()) {
          await Future.delayed(const Duration(milliseconds: 800));
        }
      }
    }
  }

  void makeHumanMove(int position) {
    if (state.status != CoopGameStatus.humanTurn) {
      return;
    }

    if (state.board[position] != CoopPlayer.none) {
      return;
    }

    final newBoard = List<CoopPlayer>.from(state.board);
    newBoard[position] = CoopPlayer.team; // Umano e AI amica sono nel team

    state = state.copyWith(
      board: newBoard,
      status: _getNextTurnStatus(),
    );
    
    _turnCounter++;

    if (!_isGameFinished()) {
      // Ritarda leggermente e poi continua con i turni AI
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _executeTurn();
      });
    }
  }

  bool _isGameFinished() {
    return state.status == CoopGameStatus.teamWon ||
           state.status == CoopGameStatus.enemyWon ||
           state.status == CoopGameStatus.tie;
  }

  CoopGameStatus _getNextTurnStatus() {
    // Ordine corretto: Umano -> AI nemica -> AI amica -> AI nemica -> Umano -> ...
    // Pattern semplice e chiaro:
    // 0=Umano, 1=AI_nemica, 2=AI_amica, 3=AI_nemica, 4=Umano, 5=AI_nemica, 6=AI_amica, 7=AI_nemica, ...
    final pattern = [
      CoopGameStatus.humanTurn,       // 0 - Umano inizia
      CoopGameStatus.enemyAiTurn,     // 1 - AI nemica
      CoopGameStatus.friendlyAiTurn,  // 2 - AI amica
      CoopGameStatus.enemyAiTurn,     // 3 - AI nemica
    ];
    
    return pattern[_turnCounter % pattern.length];
  }

  CoopTicTacToeGame _makeHumanMove(int index) {
    if (state.status != CoopGameStatus.humanTurn || 
        state.board[index] != CoopPlayer.none) {
      return state;
    }

    final newBoard = List<CoopPlayer>.from(state.board);
    newBoard[index] = CoopPlayer.team;
    
    final newStatus = _checkGameStatus(newBoard);
    final winningLine = _findWinningLine(newBoard);

    if (newStatus == CoopGameStatus.teamWon || 
        newStatus == CoopGameStatus.enemyWon || 
        newStatus == CoopGameStatus.tie) {
      return state.copyWith(
        board: newBoard,
        status: newStatus,
        winningLine: winningLine,
        lastMoveDescription: 'Hai fatto una mossa decisiva!',
      );
    }

    return state.copyWith(
      board: newBoard,
      status: _getNextTurnStatus(),
      winningLine: winningLine,
      lastMoveDescription: 'Hai fatto una mossa ottima! Ora continuano le AI.',
    );
  }

  CoopTicTacToeGame _makeEnemyAIMove() {
    if (state.status != CoopGameStatus.enemyAiTurn) {
      return state;
    }

    final strategyImpl = CoopAIStrategyFactory.createStrategy(_currentStrategy);
    final enemyMove = strategyImpl.selectEnemyMove(state, _strategyProgress.getPlayerMoveHistory());

    final newBoard = List<CoopPlayer>.from(state.board);
    newBoard[enemyMove] = CoopPlayer.enemy;

    final newStatus = _checkGameStatus(newBoard);
    final winningLine = _findWinningLine(newBoard);

    if (newStatus == CoopGameStatus.teamWon || 
        newStatus == CoopGameStatus.enemyWon || 
        newStatus == CoopGameStatus.tie) {
      return state.copyWith(
        board: newBoard,
        status: newStatus,
        winningLine: winningLine,
        lastMoveDescription: newStatus == CoopGameStatus.enemyWon 
            ? 'L\'AI nemica ha vinto!' 
            : newStatus == CoopGameStatus.tie 
                ? 'Pareggio!' 
                : 'Il team ha vinto!',
      );
    }

    return state.copyWith(
      board: newBoard,
      status: _getNextTurnStatus(),
      winningLine: winningLine,
      lastMoveDescription: 'L\'AI nemica ha fatto la sua mossa.',
    );
  }

  CoopTicTacToeGame _makeFriendlyAIMove() {
    if (state.status != CoopGameStatus.friendlyAiTurn) {
      return state;
    }

    final strategyImpl = CoopAIStrategyFactory.createStrategy(_currentStrategy);
    final friendlyMove = strategyImpl.selectFriendlyMove(state, _strategyProgress.getPlayerMoveHistory());

    final newBoard = List<CoopPlayer>.from(state.board);
    newBoard[friendlyMove] = CoopPlayer.team;

    final newStatus = _checkGameStatus(newBoard);
    final winningLine = _findWinningLine(newBoard);

    if (newStatus == CoopGameStatus.teamWon || 
        newStatus == CoopGameStatus.enemyWon || 
        newStatus == CoopGameStatus.tie) {
      return state.copyWith(
        board: newBoard,
        status: newStatus,
        winningLine: winningLine,
        lastMoveDescription: newStatus == CoopGameStatus.teamWon 
            ? 'La vostra AI amica ha completato la vittoria!' 
            : newStatus == CoopGameStatus.tie 
                ? 'Pareggio!' 
                : 'L\'AI nemica ha vinto.',
      );
    }

    return state.copyWith(
      board: newBoard,
      status: _getNextTurnStatus(),
      winningLine: winningLine,
      lastMoveDescription: 'La tua AI amica ha fatto una mossa strategica!',
    );
  }

  void resetGame() {
    _turnCounter = 0;
    state = state.reset();
    // L'umano inizia di nuovo - non serve fare altro
  }

  // Helper methods copiati dal modello
  CoopGameStatus _checkGameStatus(List<CoopPlayer> newBoard) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Righe
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonne
      [0, 4, 8], [2, 4, 6] // Diagonali
    ];

    for (final pattern in winPatterns) {
      final [a, b, c] = pattern;
      if (newBoard[a] != CoopPlayer.none &&
          newBoard[a] == newBoard[b] &&
          newBoard[b] == newBoard[c]) {
        return newBoard[a] == CoopPlayer.team 
            ? CoopGameStatus.teamWon 
            : CoopGameStatus.enemyWon;
      }
    }

    // Controlla pareggio
    if (newBoard.every((cell) => cell != CoopPlayer.none)) {
      return CoopGameStatus.tie;
    }

    return state.status;
  }

  List<int>? _findWinningLine(List<CoopPlayer> board) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Righe
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonne
      [0, 4, 8], [2, 4, 6] // Diagonali
    ];

    for (final pattern in winPatterns) {
      final [a, b, c] = pattern;
      if (board[a] != CoopPlayer.none &&
          board[a] == board[b] &&
          board[b] == board[c]) {
        return pattern;
      }
    }
    return null;
  }


}

// Provider per il gioco cooperativo
final coopTicTacToeProvider = 
    StateNotifierProvider<CoopTicTacToeNotifier, CoopTicTacToeGame>((ref) {
  return CoopTicTacToeNotifier(ref);
});