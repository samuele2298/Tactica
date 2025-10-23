import 'dart:math';
import '../../models/guess_game.dart';
import '../../models/ai_difficulty.dart';

/// Enum delle strategie AI per Guess mode (scommesse su AI1 vs AI2)
enum GuessAIStrategy {
  // Easy strategies - AI1 prevedibili
  sequential, corners, center,
  // Medium strategies - AI1 con pattern riconoscibili  
  predictable, positional, defensive,
  // Hard strategies - AI1 complesse da indovinare
  unpredictable, adaptive, chaotic
}

/// Interfaccia base per le implementazioni di strategia AI Guess
abstract class GuessAIStrategyImplementation {
  String get displayName;
  String get description;
  AIDifficulty get difficulty;
  
  /// Seleziona la mossa per AI1 (quella su cui l'umano scommette)
  int selectAI1Move(GuessTicTacToeGame game, List<int> playerBetHistory);
  
  /// Seleziona la mossa per AI2 (contrastante AI1)
  int selectAI2Move(GuessTicTacToeGame game, List<int> playerBetHistory);
}

/// Factory per creare le implementazioni delle strategie Guess
class GuessAIStrategyFactory {
  static GuessAIStrategyImplementation createStrategy(GuessAIStrategy strategy) {
    switch (strategy) {
      // Easy strategies
      case GuessAIStrategy.sequential:
        return SequentialStrategy();
      case GuessAIStrategy.corners:
        return CornersStrategy();
      case GuessAIStrategy.center:
        return CenterStrategy();
      
      // Medium strategies
      case GuessAIStrategy.predictable:
        return PredictableStrategy();
      case GuessAIStrategy.positional:
        return PositionalStrategy();
      case GuessAIStrategy.defensive:
        return DefensiveGuessStrategy();
      
      // Hard strategies
      case GuessAIStrategy.unpredictable:
        return UnpredictableStrategy();
      case GuessAIStrategy.adaptive:
        return AdaptiveGuessStrategy();
      case GuessAIStrategy.chaotic:
        return ChaoticStrategy();
    }
  }
}

// ============================================================================
// EASY STRATEGIES (Livello Facile) - AI1 molto prevedibili
// ============================================================================

/// AI1 Sequenziale - Gioca in ordine 0,1,2,3...
class SequentialStrategy implements GuessAIStrategyImplementation {
  @override
  String get displayName => 'AI Sequenziale';
  
  @override
  String get description => 'AI1 gioca in sequenza ordinata (0,1,2,3...), molto facile da prevedere.';
  
  @override
  AIDifficulty get difficulty => AIDifficulty.easy;

  @override
  int selectAI1Move(GuessTicTacToeGame game, List<int> playerBetHistory) {
    // Prima cerca vittorie immediate
    final winMove = _findWinningMove(game, GuessPlayer.ai1);
    if (winMove != -1) return winMove;
    
    // Poi cerca blocchi critici
    final blockMove = _findWinningMove(game, GuessPlayer.ai2);
    if (blockMove != -1) return blockMove;
    
    // Altrimenti gioca in sequenza
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == GuessPlayer.none) {
        return i;
      }
    }
    return 0;
  }

  @override
  int selectAI2Move(GuessTicTacToeGame game, List<int> playerBetHistory) {
    return _standardAI2Move(game);
  }

  int _findWinningMove(GuessTicTacToeGame game, GuessPlayer player) {
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
        } else if (game.board[pos] == GuessPlayer.none) {
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

  int _standardAI2Move(GuessTicTacToeGame game) {
    // AI2 gioca una strategia standard per dare un'opposizione decente
    final winMove = _findWinningMove(game, GuessPlayer.ai2);
    if (winMove != -1) return winMove;
    
    final blockMove = _findWinningMove(game, GuessPlayer.ai1);
    if (blockMove != -1) return blockMove;
    
    // Centro se disponibile
    if (game.board[4] == GuessPlayer.none) return 4;
    
    // Angoli casuali
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((i) => game.board[i] == GuessPlayer.none).toList();
    if (availableCorners.isNotEmpty) {
      return availableCorners[Random().nextInt(availableCorners.length)];
    }
    
    // Qualsiasi cella disponibile
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == GuessPlayer.none) {
        return i;
      }
    }
    return 0;
  }
}

/// AI1 Angoli - Preferisce sempre gli angoli
class CornersStrategy implements GuessAIStrategyImplementation {
  @override
  String get displayName => 'AI Angoli';
  
  @override
  String get description => 'AI1 preferisce sempre giocare negli angoli quando possibile.';
  
  @override
  AIDifficulty get difficulty => AIDifficulty.easy;

  @override
  int selectAI1Move(GuessTicTacToeGame game, List<int> playerBetHistory) {
    // Prima cerca vittorie immediate
    final winMove = _findWinningMove(game, GuessPlayer.ai1);
    if (winMove != -1) return winMove;
    
    // Poi cerca blocchi critici
    final blockMove = _findWinningMove(game, GuessPlayer.ai2);
    if (blockMove != -1) return blockMove;
    
    // Preferisce angoli
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((i) => game.board[i] == GuessPlayer.none).toList();
    if (availableCorners.isNotEmpty) {
      return availableCorners[0]; // Sempre il primo angolo disponibile
    }
    
    // Centro come fallback
    if (game.board[4] == GuessPlayer.none) return 4;
    
    // Qualsiasi altra cella
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == GuessPlayer.none) {
        return i;
      }
    }
    return 0;
  }

  @override
  int selectAI2Move(GuessTicTacToeGame game, List<int> playerBetHistory) {
    return _standardAI2Move(game);
  }

  int _findWinningMove(GuessTicTacToeGame game, GuessPlayer player) {
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
        } else if (game.board[pos] == GuessPlayer.none) {
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

  int _standardAI2Move(GuessTicTacToeGame game) {
    final winMove = _findWinningMove(game, GuessPlayer.ai2);
    if (winMove != -1) return winMove;
    
    final blockMove = _findWinningMove(game, GuessPlayer.ai1);
    if (blockMove != -1) return blockMove;
    
    if (game.board[4] == GuessPlayer.none) return 4;
    
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((i) => game.board[i] == GuessPlayer.none).toList();
    if (availableCorners.isNotEmpty) {
      return availableCorners[Random().nextInt(availableCorners.length)];
    }
    
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == GuessPlayer.none) {
        return i;
      }
    }
    return 0;
  }
}

/// AI1 Centro - Cerca sempre di controllare il centro
class CenterStrategy implements GuessAIStrategyImplementation {
  @override
  String get displayName => 'AI Centro';
  
  @override
  String get description => 'AI1 prioritizza sempre il centro e poi le posizioni centrali.';
  
  @override
  AIDifficulty get difficulty => AIDifficulty.easy;

  @override
  int selectAI1Move(GuessTicTacToeGame game, List<int> playerBetHistory) {
    // Prima cerca vittorie immediate
    final winMove = _findWinningMove(game, GuessPlayer.ai1);
    if (winMove != -1) return winMove;
    
    // Poi cerca blocchi critici
    final blockMove = _findWinningMove(game, GuessPlayer.ai2);
    if (blockMove != -1) return blockMove;
    
    // Centro prioritario
    if (game.board[4] == GuessPlayer.none) return 4;
    
    // Posizioni centrali (lati)
    final centerPositions = [1, 3, 5, 7];
    for (final pos in centerPositions) {
      if (game.board[pos] == GuessPlayer.none) {
        return pos;
      }
    }
    
    // Angoli come ultima risorsa
    final corners = [0, 2, 6, 8];
    for (final corner in corners) {
      if (game.board[corner] == GuessPlayer.none) {
        return corner;
      }
    }
    
    return 0;
  }

  @override
  int selectAI2Move(GuessTicTacToeGame game, List<int> playerBetHistory) {
    return _standardAI2Move(game);
  }

  int _findWinningMove(GuessTicTacToeGame game, GuessPlayer player) {
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
        } else if (game.board[pos] == GuessPlayer.none) {
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

  int _standardAI2Move(GuessTicTacToeGame game) {
    final winMove = _findWinningMove(game, GuessPlayer.ai2);
    if (winMove != -1) return winMove;
    
    final blockMove = _findWinningMove(game, GuessPlayer.ai1);
    if (blockMove != -1) return blockMove;
    
    if (game.board[4] == GuessPlayer.none) return 4;
    
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((i) => game.board[i] == GuessPlayer.none).toList();
    if (availableCorners.isNotEmpty) {
      return availableCorners[Random().nextInt(availableCorners.length)];
    }
    
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == GuessPlayer.none) {
        return i;
      }
    }
    return 0;
  }
}

// ============================================================================
// MEDIUM STRATEGIES (Livello Medio) - Pattern riconoscibili ma non ovvi
// ============================================================================

/// AI1 Prevedibile - Segue pattern logici ma riconoscibili
class PredictableStrategy implements GuessAIStrategyImplementation {
  @override
  String get displayName => 'AI Prevedibile';
  
  @override
  String get description => 'AI1 segue pattern logici riconoscibili: prima angoli opposti, poi centro, poi completamento.';
  
  @override
  AIDifficulty get difficulty => AIDifficulty.medium;

  @override
  int selectAI1Move(GuessTicTacToeGame game, List<int> playerBetHistory) {
    // Prima cerca vittorie immediate
    final winMove = _findWinningMove(game, GuessPlayer.ai1);
    if (winMove != -1) return winMove;
    
    // Poi cerca blocchi critici
    final blockMove = _findWinningMove(game, GuessPlayer.ai2);
    if (blockMove != -1) return blockMove;
    
    // Pattern prevedibile: angoli opposti
    if (game.board[0] == GuessPlayer.none && game.board[8] == GuessPlayer.none) {
      return 0; // Prima angolo superiore sinistro
    }
    if (game.board[0] == GuessPlayer.ai1 && game.board[8] == GuessPlayer.none) {
      return 8; // Poi angolo opposto
    }
    if (game.board[2] == GuessPlayer.none && game.board[6] == GuessPlayer.none) {
      return 2; // Altra diagonale
    }
    if (game.board[2] == GuessPlayer.ai1 && game.board[6] == GuessPlayer.none) {
      return 6;
    }
    
    // Centro se disponibile
    if (game.board[4] == GuessPlayer.none) return 4;
    
    // Completa pattern
    final availableMoves = <int>[];
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == GuessPlayer.none) {
        availableMoves.add(i);
      }
    }
    
    return availableMoves.isNotEmpty ? availableMoves[0] : 0;
  }

  @override
  int selectAI2Move(GuessTicTacToeGame game, List<int> playerBetHistory) {
    return _standardAI2Move(game);
  }

  int _findWinningMove(GuessTicTacToeGame game, GuessPlayer player) {
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
        } else if (game.board[pos] == GuessPlayer.none) {
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

  int _standardAI2Move(GuessTicTacToeGame game) {
    final winMove = _findWinningMove(game, GuessPlayer.ai2);
    if (winMove != -1) return winMove;
    
    final blockMove = _findWinningMove(game, GuessPlayer.ai1);
    if (blockMove != -1) return blockMove;
    
    if (game.board[4] == GuessPlayer.none) return 4;
    
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((i) => game.board[i] == GuessPlayer.none).toList();
    if (availableCorners.isNotEmpty) {
      return availableCorners[Random().nextInt(availableCorners.length)];
    }
    
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == GuessPlayer.none) {
        return i;
      }
    }
    return 0;
  }
}

/// AI1 Posizionale - Strategia posizionale classica
class PositionalStrategy implements GuessAIStrategyImplementation {
  @override
  String get displayName => 'AI Posizionale';
  
  @override
  String get description => 'AI1 segue la strategia posizionale classica: centro > angoli > lati, ma con alcune variazioni riconoscibili.';
  
  @override
  AIDifficulty get difficulty => AIDifficulty.medium;

  @override
  int selectAI1Move(GuessTicTacToeGame game, List<int> playerBetHistory) {
    // Prima cerca vittorie immediate
    final winMove = _findWinningMove(game, GuessPlayer.ai1);
    if (winMove != -1) return winMove;
    
    // Poi cerca blocchi critici
    final blockMove = _findWinningMove(game, GuessPlayer.ai2);
    if (blockMove != -1) return blockMove;
    
    // Strategia posizionale con leggere variazioni
    final turnNumber = game.ai1Moves.length + 1;
    
    // Centro prioritario
    if (game.board[4] == GuessPlayer.none) return 4;
    
    // Angoli con preferenza per quelli che creano fork
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((i) => game.board[i] == GuessPlayer.none).toList();
    if (availableCorners.isNotEmpty) {
      // Leggera preferenza per angoli che potrebbero creare fork
      if (availableCorners.contains(0) && turnNumber % 2 == 1) return 0;
      return availableCorners[0];
    }
    
    // Lati come ultima risorsa
    final edges = [1, 3, 5, 7];
    for (final edge in edges) {
      if (game.board[edge] == GuessPlayer.none) {
        return edge;
      }
    }
    
    return 0;
  }

  @override
  int selectAI2Move(GuessTicTacToeGame game, List<int> playerBetHistory) {
    return _standardAI2Move(game);
  }

  int _findWinningMove(GuessTicTacToeGame game, GuessPlayer player) {
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
        } else if (game.board[pos] == GuessPlayer.none) {
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

  int _standardAI2Move(GuessTicTacToeGame game) {
    final winMove = _findWinningMove(game, GuessPlayer.ai2);
    if (winMove != -1) return winMove;
    
    final blockMove = _findWinningMove(game, GuessPlayer.ai1);
    if (blockMove != -1) return blockMove;
    
    if (game.board[4] == GuessPlayer.none) return 4;
    
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((i) => game.board[i] == GuessPlayer.none).toList();
    if (availableCorners.isNotEmpty) {
      return availableCorners[Random().nextInt(availableCorners.length)];
    }
    
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == GuessPlayer.none) {
        return i;
      }
    }
    return 0;
  }
}

/// AI1 Difensiva - Prioritizza sempre la difesa
class DefensiveGuessStrategy implements GuessAIStrategyImplementation {
  @override
  String get displayName => 'AI Difensiva';
  
  @override
  String get description => 'AI1 gioca sempre difensivamente, bloccando prima le minacce di AI2 e poi cercando le proprie opportunità.';
  
  @override
  AIDifficulty get difficulty => AIDifficulty.medium;

  @override
  int selectAI1Move(GuessTicTacToeGame game, List<int> playerBetHistory) {
    // Prima blocca sempre AI2
    final blockMove = _findWinningMove(game, GuessPlayer.ai2);
    if (blockMove != -1) return blockMove;
    
    // Poi cerca le proprie vittorie
    final winMove = _findWinningMove(game, GuessPlayer.ai1);
    if (winMove != -1) return winMove;
    
    // Posizioni difensive: centro e angoli
    if (game.board[4] == GuessPlayer.none) return 4;
    
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((i) => game.board[i] == GuessPlayer.none).toList();
    if (availableCorners.isNotEmpty) {
      return availableCorners[0];
    }
    
    // Qualsiasi altra posizione
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == GuessPlayer.none) {
        return i;
      }
    }
    
    return 0;
  }

  @override
  int selectAI2Move(GuessTicTacToeGame game, List<int> playerBetHistory) {
    // AI2 più aggressiva per bilanciare AI1 difensiva
    final winMove = _findWinningMove(game, GuessPlayer.ai2);
    if (winMove != -1) return winMove;
    
    // Crea minacce multiple se possibile
    final bestMove = _findBestAggressiveMove(game);
    if (bestMove != -1) return bestMove;
    
    final blockMove = _findWinningMove(game, GuessPlayer.ai1);
    if (blockMove != -1) return blockMove;
    
    if (game.board[4] == GuessPlayer.none) return 4;
    
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((i) => game.board[i] == GuessPlayer.none).toList();
    if (availableCorners.isNotEmpty) {
      return availableCorners[Random().nextInt(availableCorners.length)];
    }
    
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == GuessPlayer.none) {
        return i;
      }
    }
    return 0;
  }

  int _findBestAggressiveMove(GuessTicTacToeGame game) {
    // Trova mosse che potrebbero creare minacce multiple
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == GuessPlayer.none) {
        final tempBoard = List<GuessPlayer>.from(game.board);
        tempBoard[i] = GuessPlayer.ai2;
        
        // Conta quante linee questa mossa potrebbe minacciare
        int threats = _countPotentialThreats(tempBoard, GuessPlayer.ai2);
        if (threats >= 2) {
          return i;
        }
      }
    }
    return -1;
  }

  int _countPotentialThreats(List<GuessPlayer> board, GuessPlayer player) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];
    
    int threats = 0;
    for (final pattern in winPatterns) {
      int playerCount = 0;
      int emptyCount = 0;
      int enemyCount = 0;
      
      for (final pos in pattern) {
        if (board[pos] == player) {
          playerCount++;
        } else if (board[pos] == GuessPlayer.none) {
          emptyCount++;
        } else {
          enemyCount++;
        }
      }
      
      // È una minaccia se ci sono 1+ del player, 0 nemici, e 2+ vuote
      if (playerCount >= 1 && enemyCount == 0 && emptyCount >= 2) {
        threats++;
      }
    }
    
    return threats;
  }

  int _findWinningMove(GuessTicTacToeGame game, GuessPlayer player) {
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
        } else if (game.board[pos] == GuessPlayer.none) {
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
// HARD STRATEGIES (Livello Difficile) - AI1 imprevedibili e complesse
// ============================================================================

/// AI1 Imprevedibile - Mescola logica e casualità
class UnpredictableStrategy implements GuessAIStrategyImplementation {
  @override
  String get displayName => 'AI Imprevedibile';
  
  @override
  String get description => 'AI1 mescola strategia ottimale con elementi casuali, rendendo difficile prevedere le sue mosse.';
  
  @override
  AIDifficulty get difficulty => AIDifficulty.hard;

  @override
  int selectAI1Move(GuessTicTacToeGame game, List<int> playerBetHistory) {
    // Prima cerca vittorie immediate
    final winMove = _findWinningMove(game, GuessPlayer.ai1);
    if (winMove != -1) return winMove;
    
    // Poi cerca blocchi critici
    final blockMove = _findWinningMove(game, GuessPlayer.ai2);
    if (blockMove != -1) return blockMove;
    
    // 70% strategico, 30% casuale
    final random = Random();
    if (random.nextDouble() < 0.7) {
      return _selectStrategicMove(game);
    } else {
      return _selectRandomMove(game);
    }
  }

  int _selectStrategicMove(GuessTicTacToeGame game) {
    // Centro se disponibile
    if (game.board[4] == GuessPlayer.none) return 4;
    
    // Angoli con preferenza casuale
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((i) => game.board[i] == GuessPlayer.none).toList();
    if (availableCorners.isNotEmpty) {
      availableCorners.shuffle();
      return availableCorners[0];
    }
    
    // Lati
    final edges = [1, 3, 5, 7];
    final availableEdges = edges.where((i) => game.board[i] == GuessPlayer.none).toList();
    if (availableEdges.isNotEmpty) {
      return availableEdges[Random().nextInt(availableEdges.length)];
    }
    
    return 0;
  }

  int _selectRandomMove(GuessTicTacToeGame game) {
    final availableMoves = <int>[];
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == GuessPlayer.none) {
        availableMoves.add(i);
      }
    }
    
    return availableMoves.isNotEmpty 
        ? availableMoves[Random().nextInt(availableMoves.length)]
        : 0;
  }

  @override
  int selectAI2Move(GuessTicTacToeGame game, List<int> playerBetHistory) {
    return _standardAI2Move(game);
  }

  int _findWinningMove(GuessTicTacToeGame game, GuessPlayer player) {
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
        } else if (game.board[pos] == GuessPlayer.none) {
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

  int _standardAI2Move(GuessTicTacToeGame game) {
    final winMove = _findWinningMove(game, GuessPlayer.ai2);
    if (winMove != -1) return winMove;
    
    final blockMove = _findWinningMove(game, GuessPlayer.ai1);
    if (blockMove != -1) return blockMove;
    
    if (game.board[4] == GuessPlayer.none) return 4;
    
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((i) => game.board[i] == GuessPlayer.none).toList();
    if (availableCorners.isNotEmpty) {
      return availableCorners[Random().nextInt(availableCorners.length)];
    }
    
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == GuessPlayer.none) {
        return i;
      }
    }
    return 0;
  }
}

/// AI1 Adattiva - Si adatta alle scommesse del giocatore
class AdaptiveGuessStrategy implements GuessAIStrategyImplementation {
  @override
  String get displayName => 'AI Adattiva';
  
  @override
  String get description => 'AI1 analizza le tue scommesse passate e si adatta per confondere le tue previsioni.';
  
  @override
  AIDifficulty get difficulty => AIDifficulty.hard;

  @override
  int selectAI1Move(GuessTicTacToeGame game, List<int> playerBetHistory) {
    // Prima cerca vittorie immediate
    final winMove = _findWinningMove(game, GuessPlayer.ai1);
    if (winMove != -1) return winMove;
    
    // Poi cerca blocchi critici
    final blockMove = _findWinningMove(game, GuessPlayer.ai2);
    if (blockMove != -1) return blockMove;
    
    // Analizza le scommesse del giocatore per adattarsi
    if (playerBetHistory.isNotEmpty) {
      return _selectAdaptiveMove(game, playerBetHistory);
    } else {
      return _selectDefaultMove(game);
    }
  }

  int _selectAdaptiveMove(GuessTicTacToeGame game, List<int> playerBetHistory) {
    // Analizza i pattern delle scommesse del giocatore
    final recentBets = playerBetHistory.length >= 3 
        ? playerBetHistory.sublist(playerBetHistory.length - 3)
        : playerBetHistory;
    
    // Se il giocatore scommette spesso su angoli, evitali
    final cornerBets = recentBets.where((bet) => [0, 2, 6, 8].contains(bet)).length;
    final centerBets = recentBets.where((bet) => bet == 4).length;
    final edgeBets = recentBets.where((bet) => [1, 3, 5, 7].contains(bet)).length;
    
    final availableMoves = <int>[];
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == GuessPlayer.none) {
        availableMoves.add(i);
      }
    }
    
    // Evita le categorie su cui il giocatore scommette di più
    if (cornerBets > centerBets && cornerBets > edgeBets) {
      // Il giocatore scommette su angoli, evitali
      final nonCorners = availableMoves.where((move) => ![0, 2, 6, 8].contains(move)).toList();
      if (nonCorners.isNotEmpty) {
        return nonCorners[Random().nextInt(nonCorners.length)];
      }
    } else if (centerBets > edgeBets) {
      // Il giocatore scommette sul centro, evitalo
      final nonCenter = availableMoves.where((move) => move != 4).toList();
      if (nonCenter.isNotEmpty) {
        return nonCenter[Random().nextInt(nonCenter.length)];
      }
    }
    
    // Default: mossa casuale
    return availableMoves[Random().nextInt(availableMoves.length)];
  }

  int _selectDefaultMove(GuessTicTacToeGame game) {
    // Strategia standard per i primi turni
    if (game.board[4] == GuessPlayer.none) return 4;
    
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((i) => game.board[i] == GuessPlayer.none).toList();
    if (availableCorners.isNotEmpty) {
      return availableCorners[Random().nextInt(availableCorners.length)];
    }
    
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == GuessPlayer.none) {
        return i;
      }
    }
    
    return 0;
  }

  @override
  int selectAI2Move(GuessTicTacToeGame game, List<int> playerBetHistory) {
    return _standardAI2Move(game);
  }

  int _findWinningMove(GuessTicTacToeGame game, GuessPlayer player) {
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
        } else if (game.board[pos] == GuessPlayer.none) {
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

  int _standardAI2Move(GuessTicTacToeGame game) {
    final winMove = _findWinningMove(game, GuessPlayer.ai2);
    if (winMove != -1) return winMove;
    
    final blockMove = _findWinningMove(game, GuessPlayer.ai1);
    if (blockMove != -1) return blockMove;
    
    if (game.board[4] == GuessPlayer.none) return 4;
    
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((i) => game.board[i] == GuessPlayer.none).toList();
    if (availableCorners.isNotEmpty) {
      return availableCorners[Random().nextInt(availableCorners.length)];
    }
    
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == GuessPlayer.none) {
        return i;
      }
    }
    return 0;
  }
}

/// AI1 Caotica - Completamente imprevedibile
class ChaoticStrategy implements GuessAIStrategyImplementation {
  @override
  String get displayName => 'AI Caotica';
  
  @override
  String get description => 'AI1 totalmente imprevedibile che cambia strategia continuamente, quasi impossibile da indovinare.';
  
  @override
  AIDifficulty get difficulty => AIDifficulty.hard;

  @override
  int selectAI1Move(GuessTicTacToeGame game, List<int> playerBetHistory) {
    // Prima cerca vittorie immediate (anche il caos ha un minimo di logica)
    final winMove = _findWinningMove(game, GuessPlayer.ai1);
    if (winMove != -1) return winMove;
    
    // 50% chance di bloccare AI2, 50% di ignorare
    final random = Random();
    if (random.nextBool()) {
      final blockMove = _findWinningMove(game, GuessPlayer.ai2);
      if (blockMove != -1) return blockMove;
    }
    
    // Selezione completamente caotica
    return _selectChaoticMove(game);
  }

  int _selectChaoticMove(GuessTicTacToeGame game) {
    final availableMoves = <int>[];
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == GuessPlayer.none) {
        availableMoves.add(i);
      }
    }
    
    if (availableMoves.isEmpty) return 0;
    
    final random = Random();
    final choice = random.nextDouble();
    
    // Multiple personalità dell'AI caotica
    if (choice < 0.2) {
      // Personalità sequenziale momentanea
      return availableMoves.reduce((a, b) => a < b ? a : b);
    } else if (choice < 0.4) {
      // Personalità anti-sequenziale
      return availableMoves.reduce((a, b) => a > b ? a : b);
    } else if (choice < 0.6) {
      // Personalità centro-focale
      if (availableMoves.contains(4)) return 4;
      return availableMoves[random.nextInt(availableMoves.length)];
    } else if (choice < 0.8) {
      // Personalità angoli-focale
      final corners = [0, 2, 6, 8];
      final availableCorners = availableMoves.where((m) => corners.contains(m)).toList();
      if (availableCorners.isNotEmpty) {
        return availableCorners[random.nextInt(availableCorners.length)];
      }
      return availableMoves[random.nextInt(availableMoves.length)];
    } else {
      // Personalità totalmente casuale
      return availableMoves[random.nextInt(availableMoves.length)];
    }
  }

  @override
  int selectAI2Move(GuessTicTacToeGame game, List<int> playerBetHistory) {
    // AI2 anche lei un po' caotica per bilanciare
    final random = Random();
    if (random.nextDouble() < 0.8) {
      return _standardAI2Move(game);
    } else {
      // AI2 occasionalmente caotica
      final availableMoves = <int>[];
      for (int i = 0; i < 9; i++) {
        if (game.board[i] == GuessPlayer.none) {
          availableMoves.add(i);
        }
      }
      return availableMoves.isNotEmpty 
          ? availableMoves[random.nextInt(availableMoves.length)]
          : 0;
    }
  }

  int _findWinningMove(GuessTicTacToeGame game, GuessPlayer player) {
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
        } else if (game.board[pos] == GuessPlayer.none) {
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

  int _standardAI2Move(GuessTicTacToeGame game) {
    final winMove = _findWinningMove(game, GuessPlayer.ai2);
    if (winMove != -1) return winMove;
    
    final blockMove = _findWinningMove(game, GuessPlayer.ai1);
    if (blockMove != -1) return blockMove;
    
    if (game.board[4] == GuessPlayer.none) return 4;
    
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((i) => game.board[i] == GuessPlayer.none).toList();
    if (availableCorners.isNotEmpty) {
      return availableCorners[Random().nextInt(availableCorners.length)];
    }
    
    for (int i = 0; i < 9; i++) {
      if (game.board[i] == GuessPlayer.none) {
        return i;
      }
    }
    return 0;
  }
}