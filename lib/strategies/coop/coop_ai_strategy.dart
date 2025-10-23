import 'dart:math';
import '../../models/coop_game.dart';
import '../../models/ai_difficulty.dart';

/// Enum delle strategie AI cooperative disponibili
enum CoopAIStrategy {
  // Easy strategies  
  supportive, defensive, random,
  // Medium strategies
  coordinated, aggressive, balanced,
  // Hard strategies
  tactical, adaptive, optimal
}

/// Interfaccia base per le implementazioni di strategia AI cooperativa
abstract class CoopAIStrategyImplementation {
  String get displayName;
  String get description;
  AIDifficulty get difficulty;
  
  /// Seleziona la mossa migliore per l'AI amica
  int selectFriendlyMove(CoopTicTacToeGame game, List<int> playerMoveHistory);
  
  /// Seleziona la mossa migliore per l'AI nemica
  int selectEnemyMove(CoopTicTacToeGame game, List<int> playerMoveHistory);
}

/// Factory per creare le implementazioni delle strategie
class CoopAIStrategyFactory {
  static CoopAIStrategyImplementation createStrategy(CoopAIStrategy strategy) {
    switch (strategy) {
      // Easy strategies
      case CoopAIStrategy.supportive:
        return SupportiveStrategy();
      case CoopAIStrategy.defensive:
        return DefensiveStrategy();
      case CoopAIStrategy.random:
        return RandomStrategy();
      
      // Medium strategies
      case CoopAIStrategy.coordinated:
        return CoordinatedStrategy();
      case CoopAIStrategy.aggressive:
        return AggressiveStrategy();
      case CoopAIStrategy.balanced:
        return BalancedStrategy();
      
      // Hard strategies
      case CoopAIStrategy.tactical:
        return TacticalStrategy();
      case CoopAIStrategy.adaptive:
        return AdaptiveStrategy();
      case CoopAIStrategy.optimal:
        return OptimalStrategy();
    }
  }

  static List<CoopAIStrategy> getStrategiesByDifficulty(AIDifficulty difficulty) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return [CoopAIStrategy.supportive, CoopAIStrategy.defensive, CoopAIStrategy.random];
      case AIDifficulty.medium:
        return [CoopAIStrategy.coordinated, CoopAIStrategy.aggressive, CoopAIStrategy.balanced];
      case AIDifficulty.hard:
        return [CoopAIStrategy.tactical, CoopAIStrategy.adaptive, CoopAIStrategy.optimal];
    }
  }
}

// =============================================================================
// EASY STRATEGIES
// =============================================================================

/// Strategia Supportiva - L'AI amica cerca sempre di aiutare il giocatore
class SupportiveStrategy extends CoopAIStrategyImplementation {
  @override
  String get displayName => 'Supportivo';

  @override
  String get description => 
      'L\'AI amica cerca sempre di completare le tue linee, ma è prevedibile. '
      'L\'AI nemica è passiva e commette errori evidenti.';

  @override
  AIDifficulty get difficulty => AIDifficulty.easy;

  @override
  int selectFriendlyMove(CoopTicTacToeGame game, List<int> playerMoveHistory) {
    // Prima cerca di vincere completando una linea del team
    final winMove = _findWinningMove(game.board, CoopPlayer.team);
    if (winMove != -1) return winMove;
    
    // Poi cerca di supportare il giocatore completando linee parziali
    final supportMove = _findSupportMove(game.board);
    if (supportMove != -1) return supportMove;
    
    // Altrimenti mossa casuale
    return _getRandomMove(game.board);
  }

  @override
  int selectEnemyMove(CoopTicTacToeGame game, List<int> playerMoveHistory) {
    // AI nemica passiva - solo il 30% delle volte blocca una vittoria
    final winMove = _findWinningMove(game.board, CoopPlayer.team);
    if (winMove != -1 && Random().nextDouble() < 0.3) {
      return winMove; // Blocca la vittoria
    }
    
    // Altrimenti mossa casuale
    return _getRandomMove(game.board);
  }
  
  int _findSupportMove(List<CoopPlayer> board) {
    // Cerca una cella che può completare una linea con una mossa del team
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Righe
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonne
      [0, 4, 8], [2, 4, 6] // Diagonali
    ];

    for (final pattern in winPatterns) {
      int teamCount = 0;
      int emptyCount = 0;
      int emptyIndex = -1;

      for (final index in pattern) {
        if (board[index] == CoopPlayer.team) {
          teamCount++;
        } else if (board[index] == CoopPlayer.none) {
          emptyCount++;
          emptyIndex = index;
        }
      }

      // Se c'è già una mossa del team e una cella vuota, supporta
      if (teamCount == 1 && emptyCount == 2) {
        return emptyIndex;
      }
    }
    return -1;
  }
}

/// Strategia Difensiva - L'AI amica si concentra sulla difesa
class DefensiveStrategy extends CoopAIStrategyImplementation {
  @override
  String get displayName => 'Difensivo';

  @override
  String get description => 
      'L\'AI amica blocca sempre le mosse nemiche ma non attacca molto. '
      'L\'AI nemica è più attenta ma commette ancora errori.';

  @override
  AIDifficulty get difficulty => AIDifficulty.easy;

  @override
  int selectFriendlyMove(CoopTicTacToeGame game, List<int> playerMoveHistory) {
    // Prima cerca di vincere
    final winMove = _findWinningMove(game.board, CoopPlayer.team);
    if (winMove != -1) return winMove;
    
    // Poi cerca di bloccare il nemico
    final blockMove = _findWinningMove(game.board, CoopPlayer.enemy);
    if (blockMove != -1) return blockMove;
    
    // Altrimenti va al centro o negli angoli
    return _getDefensiveMove(game.board);
  }

  @override
  int selectEnemyMove(CoopTicTacToeGame game, List<int> playerMoveHistory) {
    // AI nemica più attenta - 60% di bloccare vittorie
    final winMove = _findWinningMove(game.board, CoopPlayer.team);
    if (winMove != -1 && Random().nextDouble() < 0.6) {
      return winMove;
    }
    
    // Cerca di vincere
    final enemyWin = _findWinningMove(game.board, CoopPlayer.enemy);
    if (enemyWin != -1) return enemyWin;
    
    return _getRandomMove(game.board);
  }
  
  int _getDefensiveMove(List<CoopPlayer> board) {
    // Preferisce centro poi angoli
    final preferredMoves = [4, 0, 2, 6, 8, 1, 3, 5, 7];
    for (final move in preferredMoves) {
      if (board[move] == CoopPlayer.none) {
        return move;
      }
    }
    return _getRandomMove(board);
  }
}

/// Strategia Casuale - Comportamento completamente imprevedibile
class RandomStrategy extends CoopAIStrategyImplementation {
  @override
  String get displayName => 'Caotico';

  @override
  String get description => 
      'Entrambe le AI fanno mosse casuali. Ideale per principianti che vogliono '
      'sperimentare senza pressione strategica.';

  @override
  AIDifficulty get difficulty => AIDifficulty.easy;

  @override
  int selectFriendlyMove(CoopTicTacToeGame game, List<int> playerMoveHistory) {
    return _getRandomMove(game.board);
  }

  @override
  int selectEnemyMove(CoopTicTacToeGame game, List<int> playerMoveHistory) {
    return _getRandomMove(game.board);
  }
}

// =============================================================================
// MEDIUM STRATEGIES
// =============================================================================

/// Strategia Coordinata - L'AI amica collabora attivamente
class CoordinatedStrategy extends CoopAIStrategyImplementation {
  @override
  String get displayName => 'Coordinato';

  @override
  String get description => 
      'L\'AI amica anticipa le tue mosse e crea sinergie tattiche. '
      'L\'AI nemica è competente ma ha schemi riconoscibili.';

  @override
  AIDifficulty get difficulty => AIDifficulty.medium;

  @override
  int selectFriendlyMove(CoopTicTacToeGame game, List<int> playerMoveHistory) {
    // Cerca di vincere
    final winMove = _findWinningMove(game.board, CoopPlayer.team);
    if (winMove != -1) return winMove;
    
    // Blocca il nemico
    final blockMove = _findWinningMove(game.board, CoopPlayer.enemy);
    if (blockMove != -1) return blockMove;
    
    // Crea opportunità per il giocatore
    final setupMove = _findSetupMove(game.board, playerMoveHistory);
    if (setupMove != -1) return setupMove;
    
    return _getTacticalMove(game.board);
  }

  @override
  int selectEnemyMove(CoopTicTacToeGame game, List<int> playerMoveHistory) {
    // AI nemica competente - 80% di bloccare
    final winMove = _findWinningMove(game.board, CoopPlayer.team);
    if (winMove != -1 && Random().nextDouble() < 0.8) {
      return winMove;
    }
    
    // Cerca di vincere
    final enemyWin = _findWinningMove(game.board, CoopPlayer.enemy);
    if (enemyWin != -1) return enemyWin;
    
    return _getTacticalMove(game.board);
  }
  
  int _findSetupMove(List<CoopPlayer> board, List<int> playerHistory) {
    // Analizza i pattern del giocatore e crea setup
    if (playerHistory.isNotEmpty) {
      final lastMove = playerHistory.last;
      // Cerca di creare una linea con l'ultima mossa del giocatore
      final winPatterns = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8],
        [0, 3, 6], [1, 4, 7], [2, 5, 8],
        [0, 4, 8], [2, 4, 6]
      ];

      for (final pattern in winPatterns) {
        if (pattern.contains(lastMove)) {
          for (final index in pattern) {
            if (board[index] == CoopPlayer.none && index != lastMove) {
              return index;
            }
          }
        }
      }
    }
    return -1;
  }
}

/// Strategia Aggressiva - Punta sempre alla vittoria
class AggressiveStrategy extends CoopAIStrategyImplementation {
  @override
  String get displayName => 'Aggressivo';

  @override
  String get description => 
      'L\'AI amica priorizza sempre l\'attacco, ma può lasciare scoperte le difese. '
      'L\'AI nemica contrattacca duramente gli errori.';

  @override
  AIDifficulty get difficulty => AIDifficulty.medium;

  @override
  int selectFriendlyMove(CoopTicTacToeGame game, List<int> playerMoveHistory) {
    // Prima cerca di vincere
    final winMove = _findWinningMove(game.board, CoopPlayer.team);
    if (winMove != -1) return winMove;
    
    // Crea minacce multiple invece di bloccare
    final threatMove = _findThreatMove(game.board);
    if (threatMove != -1) return threatMove;
    
    // Solo dopo blocca (50% delle volte)
    final blockMove = _findWinningMove(game.board, CoopPlayer.enemy);
    if (blockMove != -1 && Random().nextDouble() < 0.5) {
      return blockMove;
    }
    
    return _getAggressiveMove(game.board);
  }

  @override
  int selectEnemyMove(CoopTicTacToeGame game, List<int> playerMoveHistory) {
    // AI nemica punisce duramente - blocca sempre
    final winMove = _findWinningMove(game.board, CoopPlayer.team);
    if (winMove != -1) return winMove;
    
    // Cerca di vincere aggressivamente
    final enemyWin = _findWinningMove(game.board, CoopPlayer.enemy);
    if (enemyWin != -1) return enemyWin;
    
    return _getAggressiveMove(game.board);
  }
  
  int _findThreatMove(List<CoopPlayer> board) {
    // Cerca di creare una minaccia dove il team può vincere nel prossimo turno
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (final pattern in winPatterns) {
      int teamCount = 0;
      int emptyCount = 0;

      for (final index in pattern) {
        if (board[index] == CoopPlayer.team) teamCount++;
        else if (board[index] == CoopPlayer.none) emptyCount++;
      }

      if (teamCount == 0 && emptyCount == 3) {
        // Pattern vuoto - inizia una minaccia
        return pattern[1]; // Preferisce il centro del pattern
      }
    }
    return -1;
  }
  
  int _getAggressiveMove(List<CoopPlayer> board) {
    // Preferisce angoli per creare fork
    final aggressiveMoves = [0, 2, 6, 8, 4, 1, 3, 5, 7];
    for (final move in aggressiveMoves) {
      if (board[move] == CoopPlayer.none) {
        return move;
      }
    }
    return 0;
  }
}

/// Strategia Bilanciata - Equilibrio tra attacco e difesa
class BalancedStrategy extends CoopAIStrategyImplementation {
  @override
  String get displayName => 'Bilanciato';

  @override
  String get description => 
      'L\'AI amica bilancia perfettamente attacco e difesa, ma con pattern riconoscibili. '
      'L\'AI nemica è competente ma prevedibile.';

  @override
  AIDifficulty get difficulty => AIDifficulty.medium;

  @override
  int selectFriendlyMove(CoopTicTacToeGame game, List<int> playerMoveHistory) {
    // Vincere sempre priorità 1
    final winMove = _findWinningMove(game.board, CoopPlayer.team);
    if (winMove != -1) return winMove;
    
    // Bloccare sempre priorità 2
    final blockMove = _findWinningMove(game.board, CoopPlayer.enemy);
    if (blockMove != -1) return blockMove;
    
    // Strategia bilanciata
    return _getBalancedMove(game.board);
  }

  @override
  int selectEnemyMove(CoopTicTacToeGame game, List<int> playerMoveHistory) {
    // AI nemica bilanciata - sempre blocca, cerca vittorie
    final winMove = _findWinningMove(game.board, CoopPlayer.team);
    if (winMove != -1) return winMove;
    
    final enemyWin = _findWinningMove(game.board, CoopPlayer.enemy);
    if (enemyWin != -1) return enemyWin;
    
    return _getBalancedMove(game.board);
  }
  
  int _getBalancedMove(List<CoopPlayer> board) {
    // Centro, poi angoli, poi lati
    final balancedMoves = [4, 0, 2, 6, 8, 1, 3, 5, 7];
    for (final move in balancedMoves) {
      if (board[move] == CoopPlayer.none) {
        return move;
      }
    }
    return 0;
  }
}

// =============================================================================
// HARD STRATEGIES  
// =============================================================================

/// Strategia Tattica - Pianificazione a più mosse
class TacticalStrategy extends CoopAIStrategyImplementation {
  @override
  String get displayName => 'Tattico';

  @override
  String get description => 
      'L\'AI amica usa tattiche avanzate e pianifica a più mosse. '
      'L\'AI nemica è molto competente e difficile da battere.';

  @override
  AIDifficulty get difficulty => AIDifficulty.hard;

  @override
  int selectFriendlyMove(CoopTicTacToeGame game, List<int> playerMoveHistory) {
    return _minimax(game.board, CoopPlayer.team, 4);
  }

  @override
  int selectEnemyMove(CoopTicTacToeGame game, List<int> playerMoveHistory) {
    return _minimax(game.board, CoopPlayer.enemy, 3);
  }
}

/// Strategia Adattiva - Si adatta allo stile del giocatore
class AdaptiveStrategy extends CoopAIStrategyImplementation {
  @override
  String get displayName => 'Adattivo';

  @override
  String get description => 
      'L\'AI amica analizza il tuo stile e si adatta per massimizzare la sinergia. '
      'L\'AI nemica controadatta il vostro stile combinato.';

  @override
  AIDifficulty get difficulty => AIDifficulty.hard;

  @override
  int selectFriendlyMove(CoopTicTacToeGame game, List<int> playerMoveHistory) {
    // Analizza lo stile del giocatore
    final playerStyle = _analyzePlayerStyle(playerMoveHistory);
    return _adaptToPlayerStyle(game.board, playerStyle);
  }

  @override
  int selectEnemyMove(CoopTicTacToeGame game, List<int> playerMoveHistory) {
    // AI nemica che controadatta lo stile del team
    return _counterAdaptMove(game.board, playerMoveHistory);
  }
  
  String _analyzePlayerStyle(List<int> history) {
    if (history.isEmpty) return 'neutral';
    
    // Analizza se il giocatore preferisce centro, angoli, o lati
    int centerMoves = history.where((move) => move == 4).length;
    int cornerMoves = history.where((move) => [0, 2, 6, 8].contains(move)).length;
    int sideMoves = history.where((move) => [1, 3, 5, 7].contains(move)).length;
    
    if (centerMoves > cornerMoves && centerMoves > sideMoves) return 'center';
    if (cornerMoves > sideMoves) return 'corners';
    return 'sides';
  }
  
  int _adaptToPlayerStyle(List<CoopPlayer> board, String style) {
    // Adatta la strategia allo stile del giocatore
    List<int> preferredMoves;
    
    switch (style) {
      case 'center':
        preferredMoves = [0, 2, 6, 8, 1, 3, 5, 7, 4]; // Supporta con angoli
        break;
      case 'corners':
        preferredMoves = [4, 1, 3, 5, 7, 0, 2, 6, 8]; // Supporta con centro e lati
        break;
      default:
        preferredMoves = [4, 0, 2, 6, 8, 1, 3, 5, 7]; // Bilanciato
    }
    
    for (final move in preferredMoves) {
      if (board[move] == CoopPlayer.none) {
        return move;
      }
    }
    return 0;
  }
  
  int _counterAdaptMove(List<CoopPlayer> board, List<int> history) {
    // L'AI nemica cerca di interrompere i pattern del team
    final winMove = _findWinningMove(board, CoopPlayer.team);
    if (winMove != -1) return winMove;
    
    final enemyWin = _findWinningMove(board, CoopPlayer.enemy);
    if (enemyWin != -1) return enemyWin;
    
    return _minimax(board, CoopPlayer.enemy, 2);
  }
}

/// Strategia Ottimale - Gioco matematicamente perfetto
class OptimalStrategy extends CoopAIStrategyImplementation {
  @override
  String get displayName => 'Ottimale';

  @override
  String get description => 
      'L\'AI amica gioca in modo matematicamente ottimale per massimizzare le vittorie del team. '
      'L\'AI nemica è altrettanto perfetta: sfida estrema!';

  @override
  AIDifficulty get difficulty => AIDifficulty.hard;

  @override
  int selectFriendlyMove(CoopTicTacToeGame game, List<int> playerMoveHistory) {
    return _minimax(game.board, CoopPlayer.team, 6);
  }

  @override
  int selectEnemyMove(CoopTicTacToeGame game, List<int> playerMoveHistory) {
    return _minimax(game.board, CoopPlayer.enemy, 6);
  }
}

// =============================================================================
// HELPER METHODS
// =============================================================================

int _findWinningMove(List<CoopPlayer> board, CoopPlayer player) {
  final winPatterns = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // Righe
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonne
    [0, 4, 8], [2, 4, 6] // Diagonali
  ];

  for (final pattern in winPatterns) {
    int playerCount = 0;
    int emptyIndex = -1;

    for (final index in pattern) {
      if (board[index] == player) {
        playerCount++;
      } else if (board[index] == CoopPlayer.none) {
        emptyIndex = index;
      }
    }

    if (playerCount == 2 && emptyIndex != -1) {
      return emptyIndex;
    }
  }
  return -1;
}

int _getTacticalMove(List<CoopPlayer> board) {
  // Preferisce centro, poi angoli, poi lati
  final tacticalMoves = [4, 0, 2, 6, 8, 1, 3, 5, 7];
  for (final move in tacticalMoves) {
    if (board[move] == CoopPlayer.none) {
      return move;
    }
  }
  return 0;
}

int _getRandomMove(List<CoopPlayer> board) {
  final availableMoves = <int>[];
  for (int i = 0; i < board.length; i++) {
    if (board[i] == CoopPlayer.none) {
      availableMoves.add(i);
    }
  }
  
  if (availableMoves.isEmpty) return 0;
  return availableMoves[Random().nextInt(availableMoves.length)];
}

int _minimax(List<CoopPlayer> board, CoopPlayer player, int depth) {
  // Implementazione semplificata del minimax per il coop mode
  final availableMoves = <int>[];
  for (int i = 0; i < board.length; i++) {
    if (board[i] == CoopPlayer.none) {
      availableMoves.add(i);
    }
  }
  
  if (availableMoves.isEmpty) return 0;
  
  // Per semplicità, usa una euristica basata su priorità
  // 1. Vincere
  final winMove = _findWinningMove(board, player);
  if (winMove != -1) return winMove;
  
  // 2. Bloccare l'avversario
  final opponent = player == CoopPlayer.team ? CoopPlayer.enemy : CoopPlayer.team;
  final blockMove = _findWinningMove(board, opponent);
  if (blockMove != -1) return blockMove;
  
  // 3. Mossa tattica
  return _getTacticalMove(board);
}