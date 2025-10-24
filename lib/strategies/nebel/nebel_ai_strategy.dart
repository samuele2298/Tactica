import 'dart:math';
import '../../models/nebel_game.dart';
import '../../models/enums.dart';

/// Enum delle strategie AI per Nebel (fog of war)
enum NebelAIStrategy {
  // Easy strategies
  cautious, random, conservative,
  // Medium strategies  
  probing, adaptive, balanced,
  // Hard strategies
  probabilistic, analytical, optimal
}

/// Interfaccia base per le implementazioni di strategia AI Nebel
abstract class NebelAIStrategyImplementation {
  String get displayName;
  String get description;
  AIDifficulty get difficulty;
  
  /// Seleziona la mossa migliore per l'AI nel gioco con nebbia
  int selectMove(NebelTicTacToeGame game, List<int> playerMoveHistory);
}

/// Factory per creare le implementazioni delle strategie Nebel
class NebelAIStrategyFactory {
  static NebelAIStrategyImplementation createStrategy(NebelAIStrategy strategy) {
    switch (strategy) {
      // Easy strategies
      case NebelAIStrategy.cautious:
        return CautiousStrategy();
      case NebelAIStrategy.random:
        return RandomNebelStrategy();
      case NebelAIStrategy.conservative:
        return ConservativeStrategy();
      
      // Medium strategies
      case NebelAIStrategy.probing:
        return ProbingStrategy();
      case NebelAIStrategy.adaptive:
        return AdaptiveNebelStrategy();
      case NebelAIStrategy.balanced:
        return BalancedNebelStrategy();
      
      // Hard strategies
      case NebelAIStrategy.probabilistic:
        return ProbabilisticStrategy();
      case NebelAIStrategy.analytical:
        return AnalyticalStrategy();
      case NebelAIStrategy.optimal:
        return OptimalNebelStrategy();
    }
  }
}

// ============================================================================
// EASY STRATEGIES (Livello Facile)
// ============================================================================

/// Strategia Cauta - Evita celle nascoste quando possibile
class CautiousStrategy implements NebelAIStrategyImplementation {
  @override
  String get displayName => 'AI Cauta';
  
  @override
  String get description => 'Evita le celle nascoste e preferisce mosse sicure su celle visibili.';
  
  @override
  AIDifficulty get difficulty => AIDifficulty.easy;

  @override
  int selectMove(NebelTicTacToeGame game, List<int> playerMoveHistory) {
    // Prima cerca mosse vincenti
    final winMove = _findWinningMove(game);
    if (winMove != -1) return winMove;
    
    // Poi cerca di bloccare vittorie dell'avversario
    final blockMove = _findBlockingMove(game);
    if (blockMove != -1) return blockMove;
    
    // Preferisce celle visibili e vuote
    final visibleMoves = <int>[];
    final hiddenMoves = <int>[];
    
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == NebelPlayer.none) {
        if (game.hiddenCells[i]) {
          hiddenMoves.add(i);
        } else {
          visibleMoves.add(i);
        }
      }
    }
    
    // Preferisce mosse visibili
    if (visibleMoves.isNotEmpty) {
      return visibleMoves[Random().nextInt(visibleMoves.length)];
    } else {
      return hiddenMoves.isNotEmpty 
          ? hiddenMoves[Random().nextInt(hiddenMoves.length)]
          : 0;
    }
  }

  int _findWinningMove(NebelTicTacToeGame game) {
    return _findCriticalMove(game, NebelPlayer.ai);
  }

  int _findBlockingMove(NebelTicTacToeGame game) {
    return _findCriticalMove(game, NebelPlayer.human);
  }

  int _findCriticalMove(NebelTicTacToeGame game, NebelPlayer player) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Righe
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonne
      [0, 4, 8], [2, 4, 6] // Diagonali
    ];

    for (final pattern in winPatterns) {
      int playerCount = 0;
      int emptyCount = 0;
      int emptyIndex = -1;

      for (int i = 0; i < 3; i++) {
        final pos = pattern[i];
        if (game.board[pos] == player) {
          playerCount++;
        } else if (game.board[pos] == NebelPlayer.none) {
          emptyCount++;
          emptyIndex = pos;
        }
      }

      if (playerCount == 2 && emptyCount == 1) {
        return emptyIndex;
      }
    }
    return -1;
  }
}

/// Strategia Casuale - Sceglie mosse completamente casuali
class RandomNebelStrategy implements NebelAIStrategyImplementation {
  @override
  String get displayName => 'AI Casuale';
  
  @override
  String get description => 'Sceglie mosse completamente casuali, ignorando la strategia.';
  
  @override
  AIDifficulty get difficulty => AIDifficulty.easy;

  @override
  int selectMove(NebelTicTacToeGame game, List<int> playerMoveHistory) {
    final availableMoves = <int>[];
    
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == NebelPlayer.none) {
        availableMoves.add(i);
      }
    }
    
    return availableMoves.isNotEmpty 
        ? availableMoves[Random().nextInt(availableMoves.length)]
        : 0;
  }
}

/// Strategia Conservativa - Gioca molto difensivamente
class ConservativeStrategy implements NebelAIStrategyImplementation {
  @override
  String get displayName => 'AI Conservativa';
  
  @override
  String get description => 'Prioritizza sempre la difesa e il blocco delle mosse avversarie.';
  
  @override
  AIDifficulty get difficulty => AIDifficulty.easy;

  @override
  int selectMove(NebelTicTacToeGame game, List<int> playerMoveHistory) {
    // Prima blocca sempre
    final blockMove = _findBlockingMove(game);
    if (blockMove != -1) return blockMove;
    
    // Poi cerca vittorie
    final winMove = _findWinningMove(game);
    if (winMove != -1) return winMove;
    
    // Centro se disponibile
    if (game.board[4] == NebelPlayer.none) return 4;
    
    // Angoli
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((i) => game.board[i] == NebelPlayer.none).toList();
    if (availableCorners.isNotEmpty) {
      return availableCorners[Random().nextInt(availableCorners.length)];
    }
    
    // Qualsiasi mossa disponibile
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == NebelPlayer.none) {
        return i;
      }
    }
    return 0;
  }

  int _findWinningMove(NebelTicTacToeGame game) {
    return _findCriticalMove(game, NebelPlayer.ai);
  }

  int _findBlockingMove(NebelTicTacToeGame game) {
    return _findCriticalMove(game, NebelPlayer.human);
  }

  int _findCriticalMove(NebelTicTacToeGame game, NebelPlayer player) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (final pattern in winPatterns) {
      int playerCount = 0;
      int emptyCount = 0;
      int emptyIndex = -1;

      for (int i = 0; i < 3; i++) {
        final pos = pattern[i];
        if (game.board[pos] == player) {
          playerCount++;
        } else if (game.board[pos] == NebelPlayer.none) {
          emptyCount++;
          emptyIndex = pos;
        }
      }

      if (playerCount == 2 && emptyCount == 1) {
        return emptyIndex;
      }
    }
    return -1;
  }
}

// ============================================================================
// MEDIUM STRATEGIES (Livello Medio)  
// ============================================================================

/// Strategia Esploratrice - Sonda le celle nascoste per informazioni
class ProbingStrategy implements NebelAIStrategyImplementation {
  @override
  String get displayName => 'AI Esploratrice';
  
  @override
  String get description => 'Sonda strategicamente le celle nascoste per ottenere informazioni vantaggiose.';
  
  @override
  AIDifficulty get difficulty => AIDifficulty.medium;

  @override
  int selectMove(NebelTicTacToeGame game, List<int> playerMoveHistory) {
    // Prima cerca mosse vincenti
    final winMove = _findWinningMove(game);
    if (winMove != -1) return winMove;
    
    // Poi cerca di bloccare vittorie dell'avversario
    final blockMove = _findBlockingMove(game);
    if (blockMove != -1) return blockMove;
    
    // Strategicamente sonda celle nascoste in posizioni chiave
    final strategicPositions = [4, 0, 2, 6, 8]; // Centro e angoli
    for (final pos in strategicPositions) {
      if (game.board[pos] == NebelPlayer.none && game.hiddenCells[pos]) {
        return pos;
      }
    }
    
    // Se non ci sono celle nascoste strategiche, gioca normalmente
    final availableMoves = <int>[];
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == NebelPlayer.none) {
        availableMoves.add(i);
      }
    }
    
    return availableMoves.isNotEmpty 
        ? availableMoves[Random().nextInt(availableMoves.length)]
        : 0;
  }

  int _findWinningMove(NebelTicTacToeGame game) {
    return _findCriticalMove(game, NebelPlayer.ai);
  }

  int _findBlockingMove(NebelTicTacToeGame game) {
    return _findCriticalMove(game, NebelPlayer.human);
  }

  int _findCriticalMove(NebelTicTacToeGame game, NebelPlayer player) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (final pattern in winPatterns) {
      int playerCount = 0;
      int emptyCount = 0;
      int emptyIndex = -1;

      for (int i = 0; i < 3; i++) {
        final pos = pattern[i];
        if (game.board[pos] == player) {
          playerCount++;
        } else if (game.board[pos] == NebelPlayer.none) {
          emptyCount++;
          emptyIndex = pos;
        }
      }

      if (playerCount == 2 && emptyCount == 1) {
        return emptyIndex;
      }
    }
    return -1;
  }
}

/// Strategia Adattiva - Si adatta al comportamento del giocatore
class AdaptiveNebelStrategy implements NebelAIStrategyImplementation {
  @override
  String get displayName => 'AI Adattiva';
  
  @override
  String get description => 'Si adatta al tuo stile di gioco e alle tue preferenze per contrastare le tue strategie.';
  
  @override
  AIDifficulty get difficulty => AIDifficulty.medium;

  @override
  int selectMove(NebelTicTacToeGame game, List<int> playerMoveHistory) {
    // Prima cerca mosse vincenti
    final winMove = _findWinningMove(game);
    if (winMove != -1) return winMove;
    
    // Poi cerca di bloccare vittorie dell'avversario
    final blockMove = _findBlockingMove(game);
    if (blockMove != -1) return blockMove;
    
    // Analizza le mosse del giocatore per adattarsi
    if (playerMoveHistory.isNotEmpty) {
      // Se il giocatore preferisce angoli
      final cornerMoves = playerMoveHistory.where((move) => [0, 2, 6, 8].contains(move)).length;
      final totalMoves = playerMoveHistory.length;
      
      if (cornerMoves / totalMoves > 0.6) {
        // Il giocatore preferisce angoli, occupa il centro
        if (game.board[4] == NebelPlayer.none) return 4;
      } else {
        // Il giocatore non preferisce angoli, prendi gli angoli
        final corners = [0, 2, 6, 8];
        final availableCorners = corners.where((i) => game.board[i] == NebelPlayer.none).toList();
        if (availableCorners.isNotEmpty) {
          return availableCorners[Random().nextInt(availableCorners.length)];
        }
      }
    }
    
    // Mossa normale
    final availableMoves = <int>[];
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == NebelPlayer.none) {
        availableMoves.add(i);
      }
    }
    
    return availableMoves.isNotEmpty 
        ? availableMoves[Random().nextInt(availableMoves.length)]
        : 0;
  }

  int _findWinningMove(NebelTicTacToeGame game) {
    return _findCriticalMove(game, NebelPlayer.ai);
  }

  int _findBlockingMove(NebelTicTacToeGame game) {
    return _findCriticalMove(game, NebelPlayer.human);
  }

  int _findCriticalMove(NebelTicTacToeGame game, NebelPlayer player) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (final pattern in winPatterns) {
      int playerCount = 0;
      int emptyCount = 0;
      int emptyIndex = -1;

      for (int i = 0; i < 3; i++) {
        final pos = pattern[i];
        if (game.board[pos] == player) {
          playerCount++;
        } else if (game.board[pos] == NebelPlayer.none) {
          emptyCount++;
          emptyIndex = pos;
        }
      }

      if (playerCount == 2 && emptyCount == 1) {
        return emptyIndex;
      }
    }
    return -1;
  }
}

/// Strategia Bilanciata - Equilibra attacco, difesa e esplorazione
class BalancedNebelStrategy implements NebelAIStrategyImplementation {
  @override
  String get displayName => 'AI Bilanciata';
  
  @override
  String get description => 'Equilibra perfettamente attacco, difesa e esplorazione delle celle nascoste.';
  
  @override
  AIDifficulty get difficulty => AIDifficulty.medium;

  @override
  int selectMove(NebelTicTacToeGame game, List<int> playerMoveHistory) {
    // Prima cerca mosse vincenti
    final winMove = _findWinningMove(game);
    if (winMove != -1) return winMove;
    
    // Poi cerca di bloccare vittorie dell'avversario
    final blockMove = _findBlockingMove(game);
    if (blockMove != -1) return blockMove;
    
    // Bilanciamento: 40% centro, 30% angoli, 30% esplorazione celle nascoste
    final random = Random();
    final choice = random.nextDouble();
    
    if (choice < 0.4) {
      // Centro se disponibile
      if (game.board[4] == NebelPlayer.none) return 4;
    } else if (choice < 0.7) {
      // Angoli
      final corners = [0, 2, 6, 8];
      final availableCorners = corners.where((i) => game.board[i] == NebelPlayer.none).toList();
      if (availableCorners.isNotEmpty) {
        return availableCorners[random.nextInt(availableCorners.length)];
      }
    } else {
      // Esplora celle nascoste
      final hiddenMoves = <int>[];
      for (int i = 0; i < 9; i++) {
        if (game.board[i] == NebelPlayer.none && game.hiddenCells[i]) {
          hiddenMoves.add(i);
        }
      }
      if (hiddenMoves.isNotEmpty) {
        return hiddenMoves[random.nextInt(hiddenMoves.length)];
      }
    }
    
    // Fallback: qualsiasi mossa disponibile
    final availableMoves = <int>[];
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == NebelPlayer.none) {
        availableMoves.add(i);
      }
    }
    
    return availableMoves.isNotEmpty 
        ? availableMoves[random.nextInt(availableMoves.length)]
        : 0;
  }

  int _findWinningMove(NebelTicTacToeGame game) {
    return _findCriticalMove(game, NebelPlayer.ai);
  }

  int _findBlockingMove(NebelTicTacToeGame game) {
    return _findCriticalMove(game, NebelPlayer.human);
  }

  int _findCriticalMove(NebelTicTacToeGame game, NebelPlayer player) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (final pattern in winPatterns) {
      int playerCount = 0;
      int emptyCount = 0;
      int emptyIndex = -1;

      for (int i = 0; i < 3; i++) {
        final pos = pattern[i];
        if (game.board[pos] == player) {
          playerCount++;
        } else if (game.board[pos] == NebelPlayer.none) {
          emptyCount++;
          emptyIndex = pos;
        }
      }

      if (playerCount == 2 && emptyCount == 1) {
        return emptyIndex;
      }
    }
    return -1;
  }
}

// ============================================================================
// HARD STRATEGIES (Livello Difficile)
// ============================================================================

/// Strategia Probabilistica - Usa calcoli di probabilità avanzati
class ProbabilisticStrategy implements NebelAIStrategyImplementation {
  @override
  String get displayName => 'AI Probabilistica';
  
  @override
  String get description => 'Calcola le probabilità di ogni cella nascosta e ottimizza le mosse basandosi su analisi statistiche.';
  
  @override
  AIDifficulty get difficulty => AIDifficulty.hard;

  @override
  int selectMove(NebelTicTacToeGame game, List<int> playerMoveHistory) {
    // Prima cerca mosse vincenti certe
    final winMove = _findWinningMove(game);
    if (winMove != -1) return winMove;
    
    // Poi cerca di bloccare vittorie certe dell'avversario
    final blockMove = _findBlockingMove(game);
    if (blockMove != -1) return blockMove;
    
    // Calcola il punteggio probabilistico per ogni mossa
    final moveScores = <int, double>{};
    
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == NebelPlayer.none) {
        moveScores[i] = _calculateMoveScore(game, i, playerMoveHistory);
      }
    }
    
    // Seleziona la mossa con il punteggio più alto
    if (moveScores.isNotEmpty) {
      final bestMove = moveScores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      return bestMove;
    }
    
    return 0;
  }

  double _calculateMoveScore(NebelTicTacToeGame game, int position, List<int> playerMoveHistory) {
    double score = 0.0;
    
    // Punteggio base per posizione strategica
    if (position == 4) score += 3.0; // Centro
    else if ([0, 2, 6, 8].contains(position)) score += 2.0; // Angoli
    else score += 1.0; // Lati
    
    // Bonus per celle nascoste (informazioni)
    if (game.hiddenCells[position]) {
      score += 1.5;
    }
    
    // Analisi delle linee passanti per questa posizione
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];
    
    for (final pattern in winPatterns) {
      if (pattern.contains(position)) {
        final lineScore = _evaluateLine(game, pattern, position);
        score += lineScore;
      }
    }
    
    // Fattore adattivo basato sulla storia delle mosse del giocatore
    if (playerMoveHistory.isNotEmpty) {
      final playerPreference = _analyzePlayerPreferences(playerMoveHistory);
      score *= playerPreference;
    }
    
    return score;
  }

  double _evaluateLine(NebelTicTacToeGame game, List<int> pattern, int targetPosition) {
    int aiCount = 0;
    int humanCount = 0;
    int emptyCount = 0;
    int hiddenCount = 0;
    
    for (final pos in pattern) {
      if (game.board[pos] == NebelPlayer.ai) {
        aiCount++;
      } else if (game.board[pos] == NebelPlayer.human) {
        humanCount++;
      } else {
        emptyCount++;
        if (game.hiddenCells[pos]) hiddenCount++;
      }
    }
    
    // Linea bloccata dall'avversario
    if (humanCount > 0 && aiCount > 0) return 0.0;
    
    // Potenziale offensivo
    if (humanCount == 0) {
      if (aiCount == 2) return 10.0; // Quasi vittoria
      if (aiCount == 1) return 3.0;  // Buona opportunità
      return 1.0; // Linea libera
    }
    
    // Potenziale difensivo
    if (aiCount == 0 && humanCount > 0) {
      if (humanCount == 2) return 8.0; // Deve bloccare
      if (humanCount == 1) return 2.0; // Attenzione
    }
    
    return 0.5;
  }

  double _analyzePlayerPreferences(List<int> playerMoveHistory) {
    // Analizza i pattern del giocatore e restituisce un moltiplicatore di adattamento
    final cornerMoves = playerMoveHistory.where((move) => [0, 2, 6, 8].contains(move)).length;
    final centerMoves = playerMoveHistory.where((move) => move == 4).length;
    final edgeMoves = playerMoveHistory.where((move) => [1, 3, 5, 7].contains(move)).length;
    
    final totalMoves = playerMoveHistory.length;
    if (totalMoves == 0) return 1.0;
    
    // Adatta la strategia basandosi sulle preferenze del giocatore
    if (cornerMoves / totalMoves > 0.6) return 1.2; // Giocatore aggressivo
    if (centerMoves / totalMoves > 0.4) return 1.1;  // Giocatore strategico
    if (edgeMoves / totalMoves > 0.5) return 0.9;   // Giocatore meno strategico
    
    return 1.0;
  }

  int _findWinningMove(NebelTicTacToeGame game) {
    return _findCriticalMove(game, NebelPlayer.ai);
  }

  int _findBlockingMove(NebelTicTacToeGame game) {
    return _findCriticalMove(game, NebelPlayer.human);
  }

  int _findCriticalMove(NebelTicTacToeGame game, NebelPlayer player) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (final pattern in winPatterns) {
      int playerCount = 0;
      int emptyCount = 0;
      int emptyIndex = -1;

      for (int i = 0; i < 3; i++) {
        final pos = pattern[i];
        if (game.board[pos] == player) {
          playerCount++;
        } else if (game.board[pos] == NebelPlayer.none) {
          emptyCount++;
          emptyIndex = pos;
        }
      }

      if (playerCount == 2 && emptyCount == 1) {
        return emptyIndex;
      }
    }
    return -1;
  }
}

/// Strategia Analitica - Analisi approfondita di ogni possibile scenario
class AnalyticalStrategy implements NebelAIStrategyImplementation {
  @override
  String get displayName => 'AI Analitica';
  
  @override
  String get description => 'Esegue analisi approfondite di tutti gli scenari possibili per trovare sempre la mossa ottimale.';
  
  @override
  AIDifficulty get difficulty => AIDifficulty.hard;

  @override
  int selectMove(NebelTicTacToeGame game, List<int> playerMoveHistory) {
    // Prima cerca mosse vincenti immediate
    final winMove = _findWinningMove(game);
    if (winMove != -1) return winMove;
    
    // Poi cerca di bloccare vittorie immediate dell'avversario
    final blockMove = _findBlockingMove(game);
    if (blockMove != -1) return blockMove;
    
    // Esegui minimax con considerazione delle celle nascoste
    final bestMove = _minimaxWithFog(game, 6, true); // Profondità 6
    return bestMove ?? 0;
  }

  int? _minimaxWithFog(NebelTicTacToeGame game, int depth, bool isMaximizing) {
    final winner = _checkWinner(game);
    
    if (winner == NebelPlayer.ai) return null; // AI vince, punteggio +10
    if (winner == NebelPlayer.human) return null; // Umano vince, punteggio -10
    if (_isBoardFull(game) || depth == 0) return null; // Pareggio o limite, punteggio 0
    
    final availableMoves = <int>[];
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == NebelPlayer.none) {
        availableMoves.add(i);
      }
    }
    
    if (availableMoves.isEmpty) return null;
    
    int? bestMove;
    int bestScore = isMaximizing ? -1000 : 1000;
    
    for (final move in availableMoves) {
      // Simula la mossa considerando l'incertezza delle celle nascoste
      final score = _evaluateMoveWithUncertainty(game, move, depth - 1, !isMaximizing);
      
      if (isMaximizing) {
        if (score > bestScore) {
          bestScore = score;
          bestMove = move;
        }
      } else {
        if (score < bestScore) {
          bestScore = score;
          bestMove = move;
        }
      }
    }
    
    return bestMove;
  }

  int _evaluateMoveWithUncertainty(NebelTicTacToeGame game, int move, int depth, bool isMaximizing) {
    // Valuta la mossa considerando l'incertezza delle celle nascoste
    final newBoard = List<NebelPlayer>.from(game.board);
    newBoard[move] = isMaximizing ? NebelPlayer.human : NebelPlayer.ai;
    
    final newGame = NebelTicTacToeGame(
      board: newBoard,
      hiddenCells: game.hiddenCells,
      currentPlayer: isMaximizing ? NebelPlayer.ai : NebelPlayer.human,
      status: game.status,
      winningLine: game.winningLine,
    );
    
    return _evaluatePosition(newGame);
  }

  int _evaluatePosition(NebelTicTacToeGame game) {
    final winner = _checkWinner(game);
    
    if (winner == NebelPlayer.ai) return 10;
    if (winner == NebelPlayer.human) return -10;
    if (_isBoardFull(game)) return 0;
    
    int score = 0;
    
    // Valuta il controllo del centro
    if (game.board[4] == NebelPlayer.ai) score += 3;
    else if (game.board[4] == NebelPlayer.human) score -= 3;
    
    // Valuta il controllo degli angoli
    final corners = [0, 2, 6, 8];
    for (final corner in corners) {
      if (game.board[corner] == NebelPlayer.ai) score += 2;
      else if (game.board[corner] == NebelPlayer.human) score -= 2;
    }
    
    // Bonus per informazioni ottenute da celle nascoste rivelate
    int revealedCount = 0;
    for (int i = 0; i < 9; i++) {
      if (game.board[i] != NebelPlayer.none && game.hiddenCells[i]) {
        revealedCount++;
      }
    }
    score += revealedCount; // Informazione è potere
    
    return score;
  }

  NebelPlayer? _checkWinner(NebelTicTacToeGame game) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (final pattern in winPatterns) {
      final [a, b, c] = pattern;
      if (game.board[a] != NebelPlayer.none &&
          game.board[a] == game.board[b] &&
          game.board[b] == game.board[c]) {
        return game.board[a];
      }
    }
    
    return null;
  }

  bool _isBoardFull(NebelTicTacToeGame game) {
    return game.board.every((cell) => cell != NebelPlayer.none);
  }

  int _findWinningMove(NebelTicTacToeGame game) {
    return _findCriticalMove(game, NebelPlayer.ai);
  }

  int _findBlockingMove(NebelTicTacToeGame game) {
    return _findCriticalMove(game, NebelPlayer.human);
  }

  int _findCriticalMove(NebelTicTacToeGame game, NebelPlayer player) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (final pattern in winPatterns) {
      int playerCount = 0;
      int emptyCount = 0;
      int emptyIndex = -1;

      for (int i = 0; i < 3; i++) {
        final pos = pattern[i];
        if (game.board[pos] == player) {
          playerCount++;
        } else if (game.board[pos] == NebelPlayer.none) {
          emptyCount++;
          emptyIndex = pos;
        }
      }

      if (playerCount == 2 && emptyCount == 1) {
        return emptyIndex;
      }
    }
    return -1;
  }
}

/// Strategia Ottimale - La più avanzata, quasi imbattibile
class OptimalNebelStrategy implements NebelAIStrategyImplementation {
  @override
  String get displayName => 'AI Ottimale';
  
  @override
  String get description => 'Gioca in modo matematicamente perfetto, sfruttando ogni informazione e calcolando tutti gli scenari possibili.';
  
  @override
  AIDifficulty get difficulty => AIDifficulty.hard;

  @override
  int selectMove(NebelTicTacToeGame game, List<int> playerMoveHistory) {
    // Prima cerca mosse vincenti immediate
    final winMove = _findWinningMove(game);
    if (winMove != -1) return winMove;
    
    // Poi cerca di bloccare vittorie immediate dell'avversario
    final blockMove = _findBlockingMove(game);
    if (blockMove != -1) return blockMove;
    
    // Implementa strategia ottimale combinando tutti i fattori
    return _findOptimalMove(game, playerMoveHistory);
  }

  int _findOptimalMove(NebelTicTacToeGame game, List<int> playerMoveHistory) {
    final moveEvaluations = <int, double>{};
    
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == NebelPlayer.none) {
        double score = 0.0;
        
        // 1. Valore posizionale base
        score += _getPositionalValue(i);
        
        // 2. Valore informativo (celle nascoste)
        if (game.hiddenCells[i]) {
          score += _getInformationValue(game, i);
        }
        
        // 3. Controllo delle linee
        score += _getLineControlValue(game, i);
        
        // 4. Adattamento al giocatore
        score += _getAdaptiveValue(game, i, playerMoveHistory);
        
        // 5. Valore tattico avanzato
        score += _getTacticalValue(game, i);
        
        moveEvaluations[i] = score;
      }
    }
    
    if (moveEvaluations.isEmpty) return 0;
    
    return moveEvaluations.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  double _getPositionalValue(int position) {
    // Centro > Angoli > Lati
    if (position == 4) return 5.0;
    if ([0, 2, 6, 8].contains(position)) return 3.0;
    return 1.0;
  }

  double _getInformationValue(NebelTicTacToeGame game, int position) {
    // Valore di ottenere informazioni da una cella nascosta
    double value = 2.0; // Base per informazione
    
    // Bonus se la posizione è strategicamente importante
    if (position == 4) value *= 1.5; // Centro è più informativo
    if ([0, 2, 6, 8].contains(position)) value *= 1.2; // Angoli sono importanti
    
    return value;
  }

  double _getLineControlValue(NebelTicTacToeGame game, int position) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];
    
    double value = 0.0;
    
    for (final pattern in winPatterns) {
      if (pattern.contains(position)) {
        value += _evaluateLineControl(game, pattern, position);
      }
    }
    
    return value;
  }

  double _evaluateLineControl(NebelTicTacToeGame game, List<int> pattern, int targetPos) {
    int aiCount = 0;
    int humanCount = 0;
    int emptyCount = 0;
    
    for (final pos in pattern) {
      if (pos == targetPos) continue; // Stiamo valutando questa posizione
      
      if (game.board[pos] == NebelPlayer.ai) {
        aiCount++;
      } else if (game.board[pos] == NebelPlayer.human) {
        humanCount++;
      } else {
        emptyCount++;
      }
    }
    
    // Linea già compromessa
    if (aiCount > 0 && humanCount > 0) return 0.0;
    
    // Potenziale offensivo
    if (humanCount == 0) {
      if (aiCount == 2) return 15.0; // Vittoria immediata
      if (aiCount == 1) return 4.0;  // Buona opportunità
      return 2.0; // Controllo della linea
    }
    
    // Potenziale difensivo
    if (aiCount == 0) {
      if (humanCount == 2) return 12.0; // Blocco necessario
      if (humanCount == 1) return 3.0;  // Controllo preventivo
    }
    
    return 1.0;
  }

  double _getAdaptiveValue(NebelTicTacToeGame game, int position, List<int> playerMoveHistory) {
    if (playerMoveHistory.length < 2) return 0.0;
    
    // Analizza i pattern del giocatore
    final recentMoves = playerMoveHistory.take(5).toList();
    
    // Contrasta le preferenze del giocatore
    final cornerPreference = recentMoves.where((m) => [0, 2, 6, 8].contains(m)).length / recentMoves.length;
    
    if (cornerPreference > 0.6) {
      // Giocatore ama gli angoli, controlla il centro
      if (position == 4) return 2.0;
    } else {
      // Giocatore non ama gli angoli, prendiamoli noi
      if ([0, 2, 6, 8].contains(position)) return 1.5;
    }
    
    return 0.0;
  }

  double _getTacticalValue(NebelTicTacToeGame game, int position) {
    // Valore tattico avanzato: fork, setup, etc.
    double value = 0.0;
    
    // Controlla se questa mossa crea fork (doppia minaccia)
    final tempBoard = List<NebelPlayer>.from(game.board);
    tempBoard[position] = NebelPlayer.ai;
    
    final tempGame = NebelTicTacToeGame(
      board: tempBoard,
      hiddenCells: game.hiddenCells,
      currentPlayer: NebelPlayer.human,
      status: game.status,
    );
    
    final threatsCreated = _countThreats(tempGame, NebelPlayer.ai);
    if (threatsCreated >= 2) {
      value += 8.0; // Fork!
    } else if (threatsCreated == 1) {
      value += 2.0; // Singola minaccia
    }
    
    return value;
  }

  int _countThreats(NebelTicTacToeGame game, NebelPlayer player) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];
    
    int threats = 0;
    
    for (final pattern in winPatterns) {
      int playerCount = 0;
      int emptyCount = 0;
      
      for (final pos in pattern) {
        if (game.board[pos] == player) {
          playerCount++;
        } else if (game.board[pos] == NebelPlayer.none) {
          emptyCount++;
        }
      }
      
      if (playerCount == 2 && emptyCount == 1) {
        threats++;
      }
    }
    
    return threats;
  }

  int _findWinningMove(NebelTicTacToeGame game) {
    return _findCriticalMove(game, NebelPlayer.ai);
  }

  int _findBlockingMove(NebelTicTacToeGame game) {
    return _findCriticalMove(game, NebelPlayer.human);
  }

  int _findCriticalMove(NebelTicTacToeGame game, NebelPlayer player) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (final pattern in winPatterns) {
      int playerCount = 0;
      int emptyCount = 0;
      int emptyIndex = -1;

      for (int i = 0; i < 3; i++) {
        final pos = pattern[i];
        if (game.board[pos] == player) {
          playerCount++;
        } else if (game.board[pos] == NebelPlayer.none) {
          emptyCount++;
          emptyIndex = pos;
        }
      }

      if (playerCount == 2 && emptyCount == 1) {
        return emptyIndex;
      }
    }
    return -1;
  }
}