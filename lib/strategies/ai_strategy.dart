import 'dart:math';
import '../models/tic_tac_toe_game.dart';
import '../models/ai_difficulty.dart';

/// Classe base astratta per le implementazioni di strategia AI
abstract class AIStrategyImplementation {
  String get displayName;
  String get description;
  int findBestMove(TicTacToeGame game);

  /// Metodi helper comuni a tutte le strategie
  List<int> _getAvailableMoves(TicTacToeGame game) {
    final moves = <int>[];
    for (int i = 0; i < game.board.length; i++) {
      if (game.board[i] == Player.none) {
        moves.add(i);
      }
    }
    return moves;
  }

  bool _wouldWin(TicTacToeGame game, int move, Player player) {
    final tempBoard = List<Player>.from(game.board);
    tempBoard[move] = player;
    return _checkWinner(tempBoard) == player;
  }

  Player? _checkWinner(List<Player> board) {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Righe
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonne
      [0, 4, 8], [2, 4, 6] // Diagonali
    ];

    for (final pattern in winPatterns) {
      final [a, b, c] = pattern;
      if (board[a] != Player.none && board[a] == board[b] && board[b] == board[c]) {
        return board[a];
      }
    }
    return null;
  }

  TicTacToeGame _simulateMove(TicTacToeGame game, int index, Player player) {
    final newBoard = List<Player>.from(game.board);
    newBoard[index] = player;
    
    final winner = _checkWinner(newBoard);
    GameStatus newStatus;
    
    if (winner == Player.human) {
      newStatus = GameStatus.humanWon;
    } else if (winner == Player.ai) {
      newStatus = GameStatus.aiWon;
    } else if (newBoard.every((cell) => cell != Player.none)) {
      newStatus = GameStatus.tie;
    } else {
      newStatus = GameStatus.playing;
    }

    return TicTacToeGame(
      board: newBoard,
      currentPlayer: player == Player.human ? Player.ai : Player.human,
      status: newStatus,
      winningLine: _getWinningLine(newBoard),
      aiStrategy: game.aiStrategy,
    );
  }

  List<int>? _getWinningLine(List<Player> board) {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Righe
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonne
      [0, 4, 8], [2, 4, 6] // Diagonali
    ];

    for (final pattern in winPatterns) {
      final [a, b, c] = pattern;
      if (board[a] != Player.none && board[a] == board[b] && board[b] == board[c]) {
        return pattern;
      }
    }
    return null;
  }
}

/// Factory per creare implementazioni di strategie AI
class AIStrategyFactory {
  static AIStrategyImplementation createStrategy(AIStrategy strategy) {
    switch (strategy) {
      // Easy Strategies
      case AIStrategy.easy1:
        return CenterFirstStrategy();
      case AIStrategy.easy2:
        return CornersFirstStrategy();
      case AIStrategy.easy3:
        return SpiralStrategy();
      
      // Medium Strategies  
      case AIStrategy.medium1:
        return DefensiveStrategy();
      case AIStrategy.medium2:
        return OpportunistStrategy();
      case AIStrategy.medium3:
        return BalancedStrategy();
      
      // Hard Strategies
      case AIStrategy.hard1:
        return MinimaxPureStrategy();
      case AIStrategy.hard2:
        return AggressiveStrategy();
      case AIStrategy.hard3:
        return AdaptiveStrategy();
    }
  }
}

// ==================== EASY STRATEGIES ====================
/// Easy 1: Centro-Fisso - Parte sempre dal centro, poi angoli
class CenterFirstStrategy extends AIStrategyImplementation {
    @override
  String get displayName => 'Centro Prima';
  
  @override
  String get description => 'Parte sempre dal centro, poi va verso gli angoli in ordine fisso';

  // Pattern: centro → angoli in ordine → lati
  static const List<int> _preferredMoves = [4, 0, 2, 6, 8, 1, 3, 5, 7];

  @override
  int findBestMove(TicTacToeGame game) {
    final availableMoves = _getAvailableMoves(game);
    
    for (int move in _preferredMoves) {
      if (availableMoves.contains(move)) {
        return move;
      }
    }
    return availableMoves.first;
  }
}

/// Easy 2: Strategia basata sugli angoli
class CornersFirstStrategy extends AIStrategyImplementation {
  @override
  String get displayName => 'Angoli Prima';
  
  @override
  String get description => 'Preferisce sempre angoli, poi centro, poi lati';

  // Pattern: angoli in ordine → centro → lati
  static const List<int> _preferredMoves = [0, 2, 6, 8, 4, 1, 3, 5, 7];

  @override
  int findBestMove(TicTacToeGame game) {
    final availableMoves = _getAvailableMoves(game);
    
    for (int move in _preferredMoves) {
      if (availableMoves.contains(move)) {
        return move;
      }
    }
    return availableMoves.first;
  }
}

/// Easy 3: Strategia a spirale prevedibile
class SpiralStrategy extends AIStrategyImplementation {
  @override
  String get displayName => 'Spirale';
  
  @override
  String get description => 'Segue un movimento a spirale: centro → angoli → lati';

  // Pattern spirale: dall'alto-sinistra in senso orario verso il centro
  static const List<int> _spiralMoves = [0, 1, 2, 5, 8, 7, 6, 3, 4];

  @override
  int findBestMove(TicTacToeGame game) {
    final availableMoves = _getAvailableMoves(game);
    
    for (int move in _spiralMoves) {
      if (availableMoves.contains(move)) {
        return move;
      }
    }
    return availableMoves.first;
  }
}

// ==================== MEDIUM STRATEGIES ====================
/// Medium 1: Difensore - Eccelle nel difendere ma attacca poco
class DefensiveStrategy extends AIStrategyImplementation {
  @override
  String get displayName => 'Difensore';
  
  @override
  String get description => 'Priorità assoluta alla difesa, attacca solo quando sicuro';

  @override
  int findBestMove(TicTacToeGame game) {
    final availableMoves = _getAvailableMoves(game);
    final random = Random();

    // 1. Blocca SEMPRE l'avversario se sta per vincere (100%)
    for (int move in availableMoves) {
      if (_wouldWin(game, move, Player.human)) {
        return move;
      }
    }

    // 2. Vince solo se è sicuro al 100%
    for (int move in availableMoves) {
      if (_wouldWin(game, move, Player.ai)) {
        return move;
      }
    }

    // 3. Strategia difensiva: preferisce centro e angoli per controllare
    if (availableMoves.contains(4)) return 4;
    
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((c) => availableMoves.contains(c)).toList();
    if (availableCorners.isNotEmpty) {
      return availableCorners[random.nextInt(availableCorners.length)];
    }

    return availableMoves[random.nextInt(availableMoves.length)];
  }
}

/// Medium 2: Opportunista - Cerca sempre l'attacco ma trascura la difesa
class OpportunistStrategy extends AIStrategyImplementation {
  @override
  String get displayName => 'Opportunista';
  
  @override
  String get description => 'Aggressivo nell\'attacco, a volte trascura la difesa';

  @override
  int findBestMove(TicTacToeGame game) {
    final availableMoves = _getAvailableMoves(game);
    final random = Random();

    // 1. SEMPRE cerca di vincere per primo
    for (int move in availableMoves) {
      if (_wouldWin(game, move, Player.ai)) {
        return move;
      }
    }

    // 2. A volte ignora la difesa (30% probabilità di non bloccare!)
    if (random.nextDouble() > 0.3) {
      for (int move in availableMoves) {
        if (_wouldWin(game, move, Player.human)) {
          return move;
        }
      }
    }

    // 3. Strategia aggressiva: cerca posizioni di attacco
    // Preferisce creare doppie minacce
    final attackMoves = _findAttackingMoves(game, availableMoves);
    if (attackMoves.isNotEmpty) {
      return attackMoves[random.nextInt(attackMoves.length)];
    }

    // 4. Default: centro o angoli
    if (availableMoves.contains(4)) return 4;
    
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((c) => availableMoves.contains(c)).toList();
    if (availableCorners.isNotEmpty) {
      return availableCorners[random.nextInt(availableCorners.length)];
    }

    return availableMoves[random.nextInt(availableMoves.length)];
  }

  List<int> _findAttackingMoves(TicTacToeGame game, List<int> availableMoves) {
    final attackMoves = <int>[];
    for (int move in availableMoves) {
      if (_createsMultipleThreats(game, move)) {
        attackMoves.add(move);
      }
    }
    return attackMoves;
  }

  bool _createsMultipleThreats(TicTacToeGame game, int move) {
    final tempBoard = List<Player>.from(game.board);
    tempBoard[move] = Player.ai;
    
    int threatCount = 0;
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (final pattern in winPatterns) {
      int aiCount = 0;
      int emptyCount = 0;
      for (int pos in pattern) {
        if (tempBoard[pos] == Player.ai) aiCount++;
        if (tempBoard[pos] == Player.none) emptyCount++;
      }
      if (aiCount == 2 && emptyCount == 1) threatCount++;
    }
    
    return threatCount >= 2;
  }
}

/// Medium 3: Bilanciato - Equilibrato ma con pattern riconoscibili
class BalancedStrategy extends AIStrategyImplementation {
  @override
  String get displayName => 'Bilanciato';
  
  @override
  String get description => 'Equilibra attacco e difesa ma segue pattern prevedibili';

  @override
  int findBestMove(TicTacToeGame game) {
    final availableMoves = _getAvailableMoves(game);
    final random = Random();

    // 1. Vince se può (90%)
    if (random.nextDouble() < 0.9) {
      for (int move in availableMoves) {
        if (_wouldWin(game, move, Player.ai)) {
          return move;
        }
      }
    }

    // 2. Difende se necessario (85%)
    if (random.nextDouble() < 0.85) {
      for (int move in availableMoves) {
        if (_wouldWin(game, move, Player.human)) {
          return move;
        }
      }
    }

    // 3. Pattern riconoscibile: sempre centro → angoli opposti → lati
    if (availableMoves.contains(4)) return 4;
    
    // Pattern angoli opposti prevedibile
    final cornerPairs = [[0, 8], [2, 6]];
    for (final pair in cornerPairs) {
      if (availableMoves.contains(pair[0]) && game.board[pair[1]] == Player.ai) {
        return pair[0];
      }
      if (availableMoves.contains(pair[1]) && game.board[pair[0]] == Player.ai) {
        return pair[1];
      }
    }

    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((c) => availableMoves.contains(c)).toList();
    if (availableCorners.isNotEmpty) {
      return availableCorners[0]; // Sempre il primo disponibile (prevedibile!)
    }

    return availableMoves[0]; // Sempre la prima mossa disponibile
  }
}

// ==================== HARD STRATEGIES ====================
/// Hard 1: Minimax Puro - Matematicamente perfetto
class MinimaxPureStrategy extends AIStrategyImplementation {
  @override
  String get displayName => 'Minimax Puro';
  
  @override
  String get description => 'Algoritmo minimax perfetto - cerca sempre il pareggio ottimale';

  @override
  int findBestMove(TicTacToeGame game) {
    final availableMoves = _getAvailableMoves(game);
    
    int bestMove = availableMoves.first;
    int bestScore = -1000;

    for (int move in availableMoves) {
      final newGame = _simulateMove(game, move, Player.ai);
      int score = _minimax(newGame, 0, false);
      
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    return bestMove;
  }

  int _minimax(TicTacToeGame game, int depth, bool isMaximizing) {
    if (game.status == GameStatus.aiWon) return 1;
    if (game.status == GameStatus.humanWon) return -1;
    if (game.status == GameStatus.tie) return 0;

    final availableMoves = _getAvailableMoves(game);
    
    if (isMaximizing) {
      int maxScore = -1000;
      for (int move in availableMoves) {
        final newGame = _simulateMove(game, move, Player.ai);
        int score = _minimax(newGame, depth + 1, false);
        maxScore = max(maxScore, score);
      }
      return maxScore;
    } else {
      int minScore = 1000;
      for (int move in availableMoves) {
        final newGame = _simulateMove(game, move, Player.human);
        int score = _minimax(newGame, depth + 1, true);
        minScore = min(minScore, score);
      }
      return minScore;
    }
  }
}

/// Hard 2: Aggressivo - Prende rischi per forzare la vittoria  
class AggressiveStrategy extends AIStrategyImplementation {
  @override
  String get displayName => 'Aggressivo';
  
  @override
  String get description => 'Prende rischi calcolati per forzare errori e vincere';

  @override
  int findBestMove(TicTacToeGame game) {
    final availableMoves = _getAvailableMoves(game);
    final random = Random();

    // 1. Vince immediatamente se possibile
    for (int move in availableMoves) {
      if (_wouldWin(game, move, Player.ai)) {
        return move;
      }
    }

    // 2. Blocca solo se assolutamente necessario
    for (int move in availableMoves) {
      if (_wouldWin(game, move, Player.human)) {
        return move;
      }
    }

    // 3. STRATEGIA AGGRESSIVA: Cerca mosse che forzano l'avversario in difficoltà
    final riskMoves = _findRiskyMoves(game, availableMoves);
    if (riskMoves.isNotEmpty) {
      return riskMoves[random.nextInt(riskMoves.length)];
    }

    // 4. Crea trappole e fork (doppie minacce)
    final forkMoves = _findForkMoves(game, availableMoves);
    if (forkMoves.isNotEmpty) {
      return forkMoves[0]; // Prende la prima trappola disponibile
    }

    // 5. Minimax come fallback
    return _minimaxMove(game, availableMoves);
  }

  List<int> _findRiskyMoves(TicTacToeGame game, List<int> availableMoves) {
    // Mosse che creano pressione anche se non ottimali
    final riskyMoves = <int>[];
    
    for (int move in availableMoves) {
      if (_createsPressure(game, move)) {
        riskyMoves.add(move);
      }
    }
    return riskyMoves;
  }

  List<int> _findForkMoves(TicTacToeGame game, List<int> availableMoves) {
    final forkMoves = <int>[];
    
    for (int move in availableMoves) {
      if (_createsMultipleThreats(game, move)) {
        forkMoves.add(move);
      }
    }
    return forkMoves;
  }

  bool _createsMultipleThreats(TicTacToeGame game, int move) {
    final tempBoard = List<Player>.from(game.board);
    tempBoard[move] = Player.ai;
    
    int threats = 0;
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (final pattern in winPatterns) {
      int aiCount = 0;
      int emptyCount = 0;
      
      for (int pos in pattern) {
        if (tempBoard[pos] == Player.ai) aiCount++;
        if (tempBoard[pos] == Player.none) emptyCount++;
      }
      
      if (aiCount == 2 && emptyCount == 1) threats++;
    }
    
    return threats >= 2;
  }

  bool _createsPressure(TicTacToeGame game, int move) {
    final tempBoard = List<Player>.from(game.board);
    tempBoard[move] = Player.ai;
    
    // Conta quante linee l'AI controlla dopo questa mossa
    int controlledLines = 0;
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8], 
      [0, 4, 8], [2, 4, 6]
    ];

    for (final pattern in winPatterns) {
      bool hasAI = false;
      bool hasHuman = false;
      
      for (int pos in pattern) {
        if (tempBoard[pos] == Player.ai) hasAI = true;
        if (tempBoard[pos] == Player.human) hasHuman = true;
      }
      
      if (hasAI && !hasHuman) controlledLines++;
    }
    
    return controlledLines >= 2;
  }

  int _minimaxMove(TicTacToeGame game, List<int> availableMoves) {
    int bestMove = availableMoves.first;
    int bestScore = -1000;

    for (int move in availableMoves) {
      final newGame = _simulateMove(game, move, Player.ai);
      int score = _quickMinimax(newGame, 2, false); // Profondità limitata per velocità
      
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    return bestMove;
  }

  int _quickMinimax(TicTacToeGame game, int depth, bool isMaximizing) {
    if (depth == 0 || game.status != GameStatus.playing) {
      return _evaluatePosition(game);
    }

    final availableMoves = _getAvailableMoves(game);
    
    if (isMaximizing) {
      int maxScore = -1000;
      for (int move in availableMoves) {
        final newGame = _simulateMove(game, move, Player.ai);
        int score = _quickMinimax(newGame, depth - 1, false);
        maxScore = max(maxScore, score);
      }
      return maxScore;
    } else {
      int minScore = 1000;
      for (int move in availableMoves) {
        final newGame = _simulateMove(game, move, Player.human);
        int score = _quickMinimax(newGame, depth - 1, true);
        minScore = min(minScore, score);
      }
      return minScore;
    }
  }

  int _evaluatePosition(TicTacToeGame game) {
    if (game.status == GameStatus.aiWon) return 100;
    if (game.status == GameStatus.humanWon) return -100;
    if (game.status == GameStatus.tie) return 0;
    
    // Valuta posizione basata su controllo linee
    return _evaluateControl(game.board);
  }

  int _evaluateControl(List<Player> board) {
    int score = 0;
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (final pattern in winPatterns) {
      int aiCount = 0, humanCount = 0;
      for (int pos in pattern) {
        if (board[pos] == Player.ai) aiCount++;
        if (board[pos] == Player.human) humanCount++;
      }
      
      if (humanCount == 0) score += aiCount * aiCount;
      if (aiCount == 0) score -= humanCount * humanCount;
    }
    
    return score;
  }
}

/// Hard 3: Adattivo - Si adatta al stile di gioco dell'avversario
class AdaptiveStrategy extends AIStrategyImplementation {
  @override
  String get displayName => 'Adattivo';
  
  @override
  String get description => 'Analizza il tuo stile e si adatta per contrastarti';

  static final Map<String, int> _playerPatterns = {};
  static int _gamesPlayed = 0;

  @override
  int findBestMove(TicTacToeGame game) {
    final availableMoves = _getAvailableMoves(game);
    
    // 1. Sempre vince se può
    for (int move in availableMoves) {
      if (_wouldWin(game, move, Player.ai)) {
        return move;
      }
    }

    // 2. Sempre blocca
    for (int move in availableMoves) {
      if (_wouldWin(game, move, Player.human)) {
        return move;
      }
    }

    // 3. ADATTAMENTO: Analizza i pattern del giocatore
    _analyzePlayerBehavior(game);
    
    // 4. Sceglie la strategia basata sui pattern rilevati
    return _adaptiveMove(game, availableMoves);
  }

  void _analyzePlayerBehavior(TicTacToeGame game) {
    _gamesPlayed++;
    
    // Analizza le prime mosse del giocatore
    final firstMove = _findPlayerFirstMove(game.board);
    if (firstMove != -1) {
      final pattern = 'first_move_$firstMove';
      _playerPatterns[pattern] = (_playerPatterns[pattern] ?? 0) + 1;
    }

    // Analizza preferenze per angoli vs centro vs lati
    _analyzePositionPreferences(game.board);
  }

  int _findPlayerFirstMove(List<Player> board) {
    int humanMoves = 0;
    for (int i = 0; i < board.length; i++) {
      if (board[i] == Player.human) {
        humanMoves++;
        if (humanMoves == 1) return i; // Prima mossa trovata
      }
    }
    return -1;
  }

  void _analyzePositionPreferences(List<Player> board) {
    int corners = 0, center = 0, edges = 0;
    
    for (int i = 0; i < board.length; i++) {
      if (board[i] == Player.human) {
        if ([0, 2, 6, 8].contains(i)) {
          corners++;
          _playerPatterns['prefers_corners'] = (_playerPatterns['prefers_corners'] ?? 0) + 1;
        } else if (i == 4) {
          center++;
          _playerPatterns['prefers_center'] = (_playerPatterns['prefers_center'] ?? 0) + 1;
        } else {
          edges++;
          _playerPatterns['prefers_edges'] = (_playerPatterns['prefers_edges'] ?? 0) + 1;
        }
      }
    }
  }

  int _adaptiveMove(TicTacToeGame game, List<int> availableMoves) {
    // Strategia basata sui pattern rilevati
    final cornersCount = _playerPatterns['prefers_corners'] ?? 0;
    final centerCount = _playerPatterns['prefers_center'] ?? 0;
    final edgesCount = _playerPatterns['prefers_edges'] ?? 0;

    // Se il giocatore preferisce gli angoli, controlla il centro
    if (cornersCount > centerCount && cornersCount > edgesCount) {
      if (availableMoves.contains(4)) return 4;
    }
    
    // Se il giocatore preferisce il centro, prende angoli opposti
    if (centerCount > cornersCount && centerCount > edgesCount) {
      final corners = [0, 2, 6, 8];
      for (int corner in corners) {
        if (availableMoves.contains(corner)) return corner;
      }
    }

    // Se il giocatore preferisce i lati, usa strategia aggressiva
    if (edgesCount > cornersCount && edgesCount > centerCount) {
      return _aggressiveCounterMove(game, availableMoves);
    }

    // Fallback: minimax semplice
    return _simpleMinimax(game, availableMoves);
  }

  int _aggressiveCounterMove(TicTacToeGame game, List<int> availableMoves) {
    // Contro giocatori che preferiscono i lati, sii aggressivo con angoli
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((c) => availableMoves.contains(c)).toList();
    
    if (availableCorners.isNotEmpty) {
      return availableCorners[0];
    }
    
    if (availableMoves.contains(4)) return 4;
    return availableMoves[0];
  }

  int _simpleMinimax(TicTacToeGame game, List<int> availableMoves) {
    int bestMove = availableMoves.first;
    int bestScore = -1000;

    for (int move in availableMoves) {
      final newGame = _simulateMove(game, move, Player.ai);
      int score = _evaluateMoveValue(newGame);
      
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    return bestMove;
  }

  int _evaluateMoveValue(TicTacToeGame game) {
    if (game.status == GameStatus.aiWon) return 10;
    if (game.status == GameStatus.humanWon) return -10;
    if (game.status == GameStatus.tie) return 0;
    
    // Valutazione semplice basata su posizioni strategiche
    int score = 0;
    if (game.board[4] == Player.ai) score += 3; // Centro vale di più
    
    final corners = [0, 2, 6, 8];
    for (int corner in corners) {
      if (game.board[corner] == Player.ai) score += 2;
    }
    
    return score;
  }
}

/// Funzioni helper condivise
List<int> _getAvailableMoves(TicTacToeGame game) {
  final availableMoves = <int>[];
  for (int i = 0; i < game.board.length; i++) {
    if (game.board[i] == Player.none) {
      availableMoves.add(i);
    }
  }
  return availableMoves;
}

bool _wouldWin(TicTacToeGame game, int index, Player player) {
  final tempBoard = List<Player>.from(game.board);
  tempBoard[index] = player;
  return _checkWinnerHelper(tempBoard) == player;
}

Player? _checkWinnerHelper(List<Player> board) {
  const winPatterns = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // Righe
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonne
    [0, 4, 8], [2, 4, 6] // Diagonali
  ];

  for (final pattern in winPatterns) {
    final [a, b, c] = pattern;
    if (board[a] != Player.none && board[a] == board[b] && board[b] == board[c]) {
      return board[a];
    }
  }
  return null;
}