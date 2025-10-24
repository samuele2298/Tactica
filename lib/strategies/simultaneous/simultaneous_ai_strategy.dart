import 'dart:math';
import '../../models/simultaneous_game.dart';
import '../../models/enums.dart';

/// Classe base astratta per le strategie AI simultanee
abstract class SimultaneousAIStrategyImplementation {
  String get displayName;
  String get description;
  String get counterStrategy;
  AIDifficulty get difficulty;
  int selectMove(SimultaneousTicTacToeGame game, List<int> playerMoveHistory);

  /// Metodi helper comuni a tutte le strategie simultanee
  List<int> _getAvailableMoves(SimultaneousTicTacToeGame game) {
    final moves = <int>[];
    for (int i = 0; i < game.board.length; i++) {
      if (game.board[i] == SimultaneousPlayer.none) {
        moves.add(i);
      }
    }
    return moves;
  }

  bool _wouldWin(SimultaneousTicTacToeGame game, int move, SimultaneousPlayer player) {
    final tempBoard = List<SimultaneousPlayer>.from(game.board);
    tempBoard[move] = player;
    return _checkWinner(tempBoard) == player;
  }

  SimultaneousPlayer? _checkWinner(List<SimultaneousPlayer> board) {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Righe
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonne
      [0, 4, 8], [2, 4, 6] // Diagonali
    ];

    for (final pattern in winPatterns) {
      final [a, b, c] = pattern;
      if (board[a] != SimultaneousPlayer.none && 
          board[a] == board[b] && 
          board[b] == board[c]) {
        return board[a];
      }
    }
    return null;
  }
}

/// Enum per le strategie simultanee disponibili
enum SimultaneousAIStrategy {
  // Easy Strategies
  easy1, easy2, easy3,
  // Medium Strategies  
  medium1, medium2, medium3,
  // Hard Strategies
  hard1, hard2, hard3,
}

/// Factory per creare implementazioni di strategie AI simultanee
class SimultaneousAIStrategyFactory {
  static SimultaneousAIStrategyImplementation createStrategy(SimultaneousAIStrategy strategy) {
    switch (strategy) {
      // Easy Strategies
      case SimultaneousAIStrategy.easy1:
        return RandomizerStrategy();
      case SimultaneousAIStrategy.easy2:
        return CopyMoveStrategy();
      case SimultaneousAIStrategy.easy3:
        return AvoidLastStrategy();
      
      // Medium Strategies  
      case SimultaneousAIStrategy.medium1:
        return PatternHunterStrategy();
      case SimultaneousAIStrategy.medium2:
        return AntiPredictableStrategy();
      case SimultaneousAIStrategy.medium3:
        return SafePlayerStrategy();
      
      // Hard Strategies
      case SimultaneousAIStrategy.hard1:
        return ProbabilisticStrategy();
      case SimultaneousAIStrategy.hard2:
        return MetaGameStrategy();
      case SimultaneousAIStrategy.hard3:
        return GameTheoryOptimalStrategy();
    }
  }

  /// Ottieni tutte le strategie per difficoltà
  static List<SimultaneousAIStrategy> getStrategiesByDifficulty(AIDifficulty difficulty) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return [SimultaneousAIStrategy.easy1, SimultaneousAIStrategy.easy2, SimultaneousAIStrategy.easy3];
      case AIDifficulty.medium:
        return [SimultaneousAIStrategy.medium1, SimultaneousAIStrategy.medium2, SimultaneousAIStrategy.medium3];
      case AIDifficulty.hard:
        return [SimultaneousAIStrategy.hard1, SimultaneousAIStrategy.hard2, SimultaneousAIStrategy.hard3];
    }
  }

  /// Ottieni nome generico per strategia non sconfitta
  static String getGenericName(SimultaneousAIStrategy strategy) {
    switch (strategy) {
      case SimultaneousAIStrategy.easy1:
        return 'Strategia Semplice A';
      case SimultaneousAIStrategy.easy2:
        return 'Strategia Semplice B';
      case SimultaneousAIStrategy.easy3:
        return 'Strategia Semplice C';
      case SimultaneousAIStrategy.medium1:
        return 'Strategia Media A';
      case SimultaneousAIStrategy.medium2:
        return 'Strategia Media B';
      case SimultaneousAIStrategy.medium3:
        return 'Strategia Media C';
      case SimultaneousAIStrategy.hard1:
        return 'Strategia Difficile A';
      case SimultaneousAIStrategy.hard2:
        return 'Strategia Difficile B';
      case SimultaneousAIStrategy.hard3:
        return 'Strategia Difficile C';
    }
  }
}

// ==================== EASY STRATEGIES ====================

/// Easy 1: Randomizer - Completamente casuale
class RandomizerStrategy extends SimultaneousAIStrategyImplementation {
  @override
  String get displayName => 'Randomizer';
  
  @override
  String get description => 'Sceglie sempre mosse completamente casuali. Imprevedibile ma inefficace.';

  @override
  String get counterStrategy => 'Usa logica e controllo del centro. Il randomness non ha strategia, quindi qualsiasi approccio metodico funziona.';

  @override
  AIDifficulty get difficulty => AIDifficulty.easy;

  @override
  int selectMove(SimultaneousTicTacToeGame game, List<int> playerMoveHistory) {
    final availableMoves = _getAvailableMoves(game);
    if (availableMoves.isEmpty) return 0;
    
    final random = Random();
    return availableMoves[random.nextInt(availableMoves.length)];
  }
}

/// Easy 2: Copy Move - Copia le mosse del giocatore
class CopyMoveStrategy extends SimultaneousAIStrategyImplementation {
  @override
  String get displayName => 'Copy Move';
  
  @override
  String get description => 'Cerca di copiare o imitare le tue mosse precedenti. Molto prevedibile.';

  @override
  String get counterStrategy => 'Cambia continuamente strategia. Se noti che copia le tue mosse, alternale o fai finte.';

  @override
  AIDifficulty get difficulty => AIDifficulty.easy;

  @override
  int selectMove(SimultaneousTicTacToeGame game, List<int> playerMoveHistory) {
    final availableMoves = _getAvailableMoves(game);
    if (availableMoves.isEmpty) return 0;

    // Cerca di imitare l'ultima mossa del giocatore
    if (playerMoveHistory.isNotEmpty) {
      final lastPlayerMove = playerMoveHistory.last;
      
      // Prova posizioni simili (stessa riga/colonna)
      final similarMoves = _findSimilarPositions(lastPlayerMove, availableMoves);
      if (similarMoves.isNotEmpty) {
        return similarMoves[Random().nextInt(similarMoves.length)];
      }
    }

    // Fallback: casuale
    return availableMoves[Random().nextInt(availableMoves.length)];
  }

  List<int> _findSimilarPositions(int lastMove, List<int> available) {
    final similar = <int>[];
    final row = lastMove ~/ 3;
    final col = lastMove % 3;

    // Stessa riga o colonna
    for (int move in available) {
      final moveRow = move ~/ 3;
      final moveCol = move % 3;
      
      if (moveRow == row || moveCol == col) {
        similar.add(move);
      }
    }

    return similar;
  }
}

/// Easy 3: Avoid Last - Evita l'ultima mossa del giocatore
class AvoidLastStrategy extends SimultaneousAIStrategyImplementation {
  @override
  String get displayName => 'Avoid Last';
  
  @override
  String get description => 'Evita sempre l\'area dove hai giocato l\'ultima volta. Strategia difensiva primitiva.';

  @override
  String get counterStrategy => 'Gioca in aree che vuoi che eviti, poi cambia all\'ultimo. Sfrutta la sua prevedibilità.';

  @override
  AIDifficulty get difficulty => AIDifficulty.easy;

  @override
  int selectMove(SimultaneousTicTacToeGame game, List<int> playerMoveHistory) {
    final availableMoves = _getAvailableMoves(game);
    if (availableMoves.isEmpty) return 0;

    // Evita l'area dell'ultima mossa del giocatore
    if (playerMoveHistory.isNotEmpty) {
      final lastMove = playerMoveHistory.last;
      final avoidMoves = _getAreaAround(lastMove);
      
      final safeMoves = availableMoves.where((move) => !avoidMoves.contains(move)).toList();
      if (safeMoves.isNotEmpty) {
        return safeMoves[Random().nextInt(safeMoves.length)];
      }
    }

    return availableMoves[Random().nextInt(availableMoves.length)];
  }

  List<int> _getAreaAround(int position) {
    // Area di 3x3 attorno alla posizione (o quello che è possibile)
    final area = <int>[];
    final row = position ~/ 3;
    final col = position % 3;

    for (int r = -1; r <= 1; r++) {
      for (int c = -1; c <= 1; c++) {
        final newRow = row + r;
        final newCol = col + c;
        
        if (newRow >= 0 && newRow < 3 && newCol >= 0 && newCol < 3) {
          area.add(newRow * 3 + newCol);
        }
      }
    }
    
    return area;
  }
}

// ==================== MEDIUM STRATEGIES ====================

/// Medium 1: Pattern Hunter - Cerca pattern nelle mosse del giocatore
class PatternHunterStrategy extends SimultaneousAIStrategyImplementation {
  @override
  String get displayName => 'Pattern Hunter';
  
  @override
  String get description => 'Analizza i tuoi pattern di gioco e cerca di prevedere la tua prossima mossa.';

  @override
  String get counterStrategy => 'Rompi i pattern! Gioca casualmente per alcuni turni, poi crea falsi pattern per confonderlo.';

  @override
  AIDifficulty get difficulty => AIDifficulty.medium;

  @override
  int selectMove(SimultaneousTicTacToeGame game, List<int> playerMoveHistory) {
    final availableMoves = _getAvailableMoves(game);
    if (availableMoves.isEmpty) return 0;

    // Analizza pattern nelle ultime mosse
    final predictedMove = _predictNextMove(playerMoveHistory, availableMoves);
    
    // Se riesce a predire, cerca di vincere o evitare conflitto
    if (predictedMove != -1) {
      final winningMoves = _findWinningMoves(game, availableMoves);
      
      // Se può vincere, gioca per vincere evitando il conflitto
      if (winningMoves.isNotEmpty) {
        final safeWinning = winningMoves.where((move) => move != predictedMove).toList();
        if (safeWinning.isNotEmpty) {
          return safeWinning.first;
        }
      }

      // Altrimenti evita il conflitto e gioca strategicamente
      final safeMoves = availableMoves.where((move) => move != predictedMove).toList();
      if (safeMoves.isNotEmpty) {
        return _pickBestSafeMove(game, safeMoves);
      }
    }

    return _pickBestMove(game, availableMoves);
  }

  int _predictNextMove(List<int> history, List<int> available) {
    if (history.length < 2) return -1;

    // Pattern 1: Sequenza numerica
    if (history.length >= 2) {
      final diff = history.last - history[history.length - 2];
      final predicted = history.last + diff;
      if (predicted >= 0 && predicted < 9 && available.contains(predicted)) {
        return predicted;
      }
    }

    // Pattern 2: Preferenze posizionali
    final positionFreq = <int, int>{};
    for (int move in history) {
      positionFreq[move] = (positionFreq[move] ?? 0) + 1;
    }

    // Trova pattern di ripetizione
    if (history.length >= 3) {
      final recent = history.sublist(history.length - 3);
      final mostFrequent = recent.fold<Map<int, int>>(<int, int>{}, (map, move) {
        map[move] = (map[move] ?? 0) + 1;
        return map;
      });

      final maxCount = mostFrequent.values.fold(0, (a, b) => a > b ? a : b);
      if (maxCount > 1) {
        for (final entry in mostFrequent.entries) {
          if (entry.value == maxCount && available.contains(entry.key)) {
            return entry.key;
          }
        }
      }
    }

    return -1;
  }

  List<int> _findWinningMoves(SimultaneousTicTacToeGame game, List<int> available) {
    final winningMoves = <int>[];
    for (int move in available) {
      if (_wouldWin(game, move, SimultaneousPlayer.ai)) {
        winningMoves.add(move);
      }
    }
    return winningMoves;
  }

  int _pickBestSafeMove(SimultaneousTicTacToeGame game, List<int> moves) {
    // Priorità: centro > angoli > lati
    if (moves.contains(4)) return 4;
    
    final corners = [0, 2, 6, 8];
    for (int corner in corners) {
      if (moves.contains(corner)) return corner;
    }
    
    return moves.first;
  }

  int _pickBestMove(SimultaneousTicTacToeGame game, List<int> moves) {
    // Cerca mosse vincenti
    final winningMoves = _findWinningMoves(game, moves);
    if (winningMoves.isNotEmpty) return winningMoves.first;
    
    return _pickBestSafeMove(game, moves);
  }
}

/// Medium 2: Anti-Predictable - Usa counter-psicologia
class AntiPredictableStrategy extends SimultaneousAIStrategyImplementation {
  @override
  String get displayName => 'Anti-Predictable';
  
  @override
  String get description => 'Cerca di essere imprevedibile usando counter-psicologia e mosse inaspettate.';

  @override
  String get counterStrategy => 'Non cercare di predirlo! Concentrati sulla tua strategia e gioca le mosse ottimali indipendentemente.';

  @override
  AIDifficulty get difficulty => AIDifficulty.medium;

  final Random _random = Random();
  static int _turnCount = 0;

  @override
  int selectMove(SimultaneousTicTacToeGame game, List<int> playerMoveHistory) {
    final availableMoves = _getAvailableMoves(game);
    if (availableMoves.isEmpty) return 0;

    _turnCount++;

    // 30% delle volte fa la mossa "ovvia" per confondere
    if (_random.nextDouble() < 0.3) {
      return _pickObviousMove(game, availableMoves);
    }

    // 40% delle volte evita le mosse ovvie
    if (_random.nextDouble() < 0.4) {
      return _pickCounterIntuitiveMove(game, availableMoves);
    }

    // 30% delle volte gioca completamente a caso
    return availableMoves[_random.nextInt(availableMoves.length)];
  }

  int _pickObviousMove(SimultaneousTicTacToeGame game, List<int> moves) {
    // Mosse "ovvie": centro, poi angoli
    if (moves.contains(4)) return 4;
    
    final corners = [0, 2, 6, 8];
    for (int corner in corners) {
      if (moves.contains(corner)) return corner;
    }
    
    return moves.first;
  }

  int _pickCounterIntuitiveMove(SimultaneousTicTacToeGame game, List<int> moves) {
    // Evita centro e angoli, preferisce lati
    final sides = [1, 3, 5, 7];
    final availableSides = sides.where((side) => moves.contains(side)).toList();
    
    if (availableSides.isNotEmpty) {
      return availableSides[_random.nextInt(availableSides.length)];
    }
    
    // Se non ci sono lati, prende quello che c'è
    return moves[_random.nextInt(moves.length)];
  }
}

/// Medium 3: Safe Player - Gioca sicuro ed evita conflitti
class SafePlayerStrategy extends SimultaneousAIStrategyImplementation {
  @override
  String get displayName => 'Safe Player';
  
  @override
  String get description => 'Evita i conflitti e gioca le mosse più sicure. Conservativo ma efficace.';

  @override
  String get counterStrategy => 'Sii aggressivo! Forza i conflitti nelle aree che vuoi controllare, lui eviterà e tu potrai dominare.';

  @override
  AIDifficulty get difficulty => AIDifficulty.medium;

  @override
  int selectMove(SimultaneousTicTacToeGame game, List<int> playerMoveHistory) {
    final availableMoves = _getAvailableMoves(game);
    if (availableMoves.isEmpty) return 0;

    // Cerca mosse vincenti sicure
    final winningMoves = _findSafeWinningMoves(game, availableMoves, playerMoveHistory);
    if (winningMoves.isNotEmpty) {
      return winningMoves.first;
    }

    // Evita aree "pericolose" dove il giocatore potrebbe andare
    final predictedPlayerMove = _predictPlayerMove(playerMoveHistory, availableMoves);
    List<int> safeMoves = availableMoves;
    
    if (predictedPlayerMove != -1) {
      safeMoves = availableMoves.where((move) => move != predictedPlayerMove).toList();
    }

    if (safeMoves.isEmpty) safeMoves = availableMoves;

    // Gioca la posizione più sicura
    return _pickSafestMove(game, safeMoves);
  }

  List<int> _findSafeWinningMoves(SimultaneousTicTacToeGame game, List<int> available, List<int> playerHistory) {
    final winningMoves = <int>[];
    final predictedPlayerMove = _predictPlayerMove(playerHistory, available);
    
    for (int move in available) {
      if (_wouldWin(game, move, SimultaneousPlayer.ai) && move != predictedPlayerMove) {
        winningMoves.add(move);
      }
    }
    return winningMoves;
  }

  int _predictPlayerMove(List<int> history, List<int> available) {
    if (history.isEmpty) return -1;

    // Predizione semplice: probabile che continui pattern o vada al centro
    if (available.contains(4)) return 4; // Il centro è sempre attraente
    
    // Ultimo tipo di posizione giocata
    if (history.isNotEmpty) {
      final lastMove = history.last;
      final corners = [0, 2, 6, 8];
      final sides = [1, 3, 5, 7];
      
      if (corners.contains(lastMove)) {
        // Se ha giocato un angolo, probabile che continui con angoli
        final availableCorners = corners.where((c) => available.contains(c)).toList();
        if (availableCorners.isNotEmpty) {
          return availableCorners.first;
        }
      }
      
      if (sides.contains(lastMove)) {
        // Se ha giocato un lato, probabile che vada al centro o altri lati
        if (available.contains(4)) return 4;
        final availableSides = sides.where((s) => available.contains(s)).toList();
        if (availableSides.isNotEmpty) {
          return availableSides.first;
        }
      }
    }

    return -1;
  }

  int _pickSafestMove(SimultaneousTicTacToeGame game, List<int> moves) {
    // Ordine di sicurezza: centro > angoli > lati
    if (moves.contains(4)) return 4;
    
    final corners = [0, 2, 6, 8];
    for (int corner in corners) {
      if (moves.contains(corner)) return corner;
    }
    
    return moves.first;
  }
}

// ==================== HARD STRATEGIES ====================

/// Hard 1: Probabilistic - Usa calcoli probabilistici avanzati
class ProbabilisticStrategy extends SimultaneousAIStrategyImplementation {
  @override
  String get displayName => 'Probabilistic';
  
  @override
  String get description => 'Calcola probabilità e usa teoria dei giochi per predire le tue mosse.';

  @override
  String get counterStrategy => 'Randomizza completamente le tue mosse per rompere i suoi calcoli probabilistici. Non seguire alcun pattern.';

  @override
  AIDifficulty get difficulty => AIDifficulty.hard;

  static final Map<int, int> _positionFrequency = {};
  static final Map<String, int> _sequenceFrequency = {};

  @override
  int selectMove(SimultaneousTicTacToeGame game, List<int> playerMoveHistory) {
    final availableMoves = _getAvailableMoves(game);
    if (availableMoves.isEmpty) return 0;

    // Aggiorna statistiche
    _updateStatistics(playerMoveHistory);

    // Calcola probabilità per ogni mossa disponibile
    final moveProbabilities = <int, double>{};
    
    for (int move in availableMoves) {
      moveProbabilities[move] = _calculateMoveProbability(move, playerMoveHistory, game);
    }

    // Trova mosse vincenti con alta probabilità di successo
    final winningMoves = _findHighProbabilityWinningMoves(game, moveProbabilities);
    if (winningMoves.isNotEmpty) {
      return winningMoves.entries.first.key;
    }

    // Altrimenti, gioca la mossa con maggiore valore atteso
    return _selectOptimalMove(moveProbabilities, game);
  }

  void _updateStatistics(List<int> history) {
    for (int i = 0; i < history.length; i++) {
      final move = history[i];
      _positionFrequency[move] = (_positionFrequency[move] ?? 0) + 1;
      
      // Sequenze di 2 mosse
      if (i > 0) {
        final sequence = '${history[i-1]}-$move';
        _sequenceFrequency[sequence] = (_sequenceFrequency[sequence] ?? 0) + 1;
      }
    }
  }

  double _calculateMoveProbability(int move, List<int> history, SimultaneousTicTacToeGame game) {
    double probability = 0.1; // Base probability
    
    // Frequenza posizionale
    final totalMoves = history.length;
    if (totalMoves > 0) {
      final moveFreq = _positionFrequency[move] ?? 0;
      probability += (moveFreq / totalMoves) * 0.4;
    }

    // Pattern sequenziali
    if (history.isNotEmpty) {
      final lastMove = history.last;
      final sequence = '$lastMove-$move';
      final sequenceFreq = _sequenceFrequency[sequence] ?? 0;
      final lastMoveFreq = _positionFrequency[lastMove] ?? 1;
      probability += (sequenceFreq / lastMoveFreq) * 0.3;
    }

    // Bias posizionali (centro più probabile)
    if (move == 4) probability += 0.15;
    if ([0, 2, 6, 8].contains(move)) probability += 0.1;

    // Strategic value
    if (_wouldWin(game, move, SimultaneousPlayer.human)) {
      probability += 0.2; // Il giocatore probabilmente vuole vincere
    }

    return probability.clamp(0.0, 1.0);
  }

  Map<int, double> _findHighProbabilityWinningMoves(SimultaneousTicTacToeGame game, Map<int, double> probabilities) {
    final winningMoves = <int, double>{};
    
    for (final entry in probabilities.entries) {
      final move = entry.key;
      final playerProbability = entry.value;
      
      if (_wouldWin(game, move, SimultaneousPlayer.ai)) {
        // Calcola la probabilità che il giocatore NON giochi questa mossa
        final successProbability = 1.0 - playerProbability;
        if (successProbability > 0.6) { // Alta probabilità di successo
          winningMoves[move] = successProbability;
        }
      }
    }
    
    return winningMoves;
  }

  int _selectOptimalMove(Map<int, double> probabilities, SimultaneousTicTacToeGame game) {
    // Calcola valore atteso per ogni mossa
    final expectedValues = <int, double>{};
    
    for (final entry in probabilities.entries) {
      final move = entry.key;
      final conflictProbability = entry.value;
      
      // Valore base della posizione
      double positionValue = _calculatePositionValue(move, game);
      
      // Penalità per conflitto
      final expectedValue = positionValue * (1.0 - conflictProbability);
      expectedValues[move] = expectedValue;
    }
    
    // Ritorna la mossa con valore atteso più alto
    return expectedValues.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  double _calculatePositionValue(int move, SimultaneousTicTacToeGame game) {
    double value = 1.0;
    
    // Centro vale di più
    if (move == 4) value += 1.5;
    
    // Angoli valgono più dei lati
    if ([0, 2, 6, 8].contains(move)) value += 1.0;
    
    // Calcola quante linee questa mossa può aiutare a controllare
    value += _countControlledLines(move, game) * 0.5;
    
    return value;
  }

  int _countControlledLines(int move, SimultaneousTicTacToeGame game) {
    final tempBoard = List<SimultaneousPlayer>.from(game.board);
    tempBoard[move] = SimultaneousPlayer.ai;
    
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
        if (tempBoard[pos] == SimultaneousPlayer.ai) hasAI = true;
        if (tempBoard[pos] == SimultaneousPlayer.human) hasHuman = true;
      }
      
      if (hasAI && !hasHuman) controlledLines++;
    }
    
    return controlledLines;
  }
}

/// Hard 2: Meta Game - Gioca meta-gioco psicologico
class MetaGameStrategy extends SimultaneousAIStrategyImplementation {
  @override
  String get displayName => 'Meta Game';
  
  @override
  String get description => 'Master del meta-gioco: crea pattern falsi, poi li rompe per manipolare le tue aspettative.';

  @override
  String get counterStrategy => 'Ignora completamente i suoi pattern! Non cercare di predirlo, gioca la tua strategia indipendentemente da quello che fa.';

  @override
  AIDifficulty get difficulty => AIDifficulty.hard;

  static final List<int> _gameHistory = [];
  static int _phaseCounter = 0;
  static String _currentPhase = 'establishing';

  @override
  int selectMove(SimultaneousTicTacToeGame game, List<int> playerMoveHistory) {
    final availableMoves = _getAvailableMoves(game);
    if (availableMoves.isEmpty) return 0;

    _phaseCounter++;
    _gameHistory.addAll(playerMoveHistory);

    // Meta-game phases: establishing → exploitation → chaos → adaptation
    switch (_currentPhase) {
      case 'establishing':
        return _establishingPhase(game, availableMoves, playerMoveHistory);
      case 'exploitation':
        return _exploitationPhase(game, availableMoves, playerMoveHistory);
      case 'chaos':
        return _chaosPhase(game, availableMoves);
      case 'adaptation':
        return _adaptationPhase(game, availableMoves, playerMoveHistory);
      default:
        return availableMoves[Random().nextInt(availableMoves.length)];
    }
  }

  int _establishingPhase(SimultaneousTicTacToeGame game, List<int> moves, List<int> history) {
    // Fase 1-3: Stabilisce pattern falsi predicibili
    if (_phaseCounter > 3) {
      _currentPhase = 'exploitation';
    }

    // Pattern falso: preferenza per angoli in senso orario
    final cornerSequence = [0, 2, 8, 6];
    for (int corner in cornerSequence) {
      if (moves.contains(corner)) {
        return corner;
      }
    }

    // Se non ci sono angoli, centro
    if (moves.contains(4)) return 4;
    return moves.first;
  }

  int _exploitationPhase(SimultaneousTicTacToeGame game, List<int> moves, List<int> history) {
    // Fase 4-6: Sfrutta il fatto che il giocatore si aspetta il pattern
    if (_phaseCounter > 6) {
      _currentPhase = 'chaos';
    }

    // Rompe il pattern: fa l'opposto di quello che si aspetterebbe
    final playerExpectedMove = _predictPlayerExpectation(history, moves);
    
    // Cerca mosse vincenti che NON sono quelle attese
    final winningMoves = <int>[];
    for (int move in moves) {
      if (_wouldWin(game, move, SimultaneousPlayer.ai) && move != playerExpectedMove) {
        winningMoves.add(move);
      }
    }
    
    if (winningMoves.isNotEmpty) return winningMoves.first;

    // Evita la mossa che il giocatore si aspetta
    final surpriseMoves = moves.where((m) => m != playerExpectedMove).toList();
    if (surpriseMoves.isNotEmpty) {
      // Preferisce lati invece di angoli (opposto del pattern)
      final sides = [1, 3, 5, 7];
      for (int side in sides) {
        if (surpriseMoves.contains(side)) return side;
      }
      return surpriseMoves.first;
    }

    return moves.first;
  }

  int _chaosPhase(SimultaneousTicTacToeGame game, List<int> moves) {
    // Fase 7-9: Caos completo per resettare le aspettative
    if (_phaseCounter > 9) {
      _currentPhase = 'adaptation';
    }

    // Completamente casuale per confondere
    return moves[Random().nextInt(moves.length)];
  }

  int _adaptationPhase(SimultaneousTicTacToeGame game, List<int> moves, List<int> history) {
    // Fase 10+: Si adatta al nuovo comportamento del giocatore
    if (_phaseCounter > 15) {
      // Reset del ciclo
      _phaseCounter = 0;
      _currentPhase = 'establishing';
    }

    // Analizza come è cambiato il comportamento del giocatore
    final recentBehavior = _analyzeRecentBehavior(history);
    return _counterNewBehavior(game, moves, recentBehavior);
  }

  int _predictPlayerExpectation(List<int> history, List<int> moves) {
    // Basato sul pattern stabilito, il giocatore si aspetta il prossimo angolo in sequenza
    if (history.isEmpty) return moves.contains(0) ? 0 : moves.first;
    
    // Il giocatore ha imparato il pattern angoli, quindi si aspetta che continui
    final corners = [0, 2, 8, 6, 0]; // Ciclo
    final lastAICorners = [0, 2]; // Quello che l'AI ha fatto nelle prime fasi
    
    if (lastAICorners.length < corners.length - 1) {
      final nextCorner = corners[lastAICorners.length];
      if (moves.contains(nextCorner)) return nextCorner;
    }

    return moves.contains(4) ? 4 : moves.first;
  }

  String _analyzeRecentBehavior(List<int> history) {
    if (history.length < 3) return 'insufficient_data';
    
    final recent = history.sublist(history.length - 3);
    final corners = recent.where((m) => [0, 2, 6, 8].contains(m)).length;
    final center = recent.where((m) => m == 4).length;
    final sides = recent.where((m) => [1, 3, 5, 7].contains(m)).length;

    if (corners >= 2) return 'corner_focused';
    if (center >= 1) return 'center_focused';
    if (sides >= 2) return 'side_focused';
    return 'random_behavior';
  }

  int _counterNewBehavior(SimultaneousTicTacToeGame game, List<int> moves, String behavior) {
    switch (behavior) {
      case 'corner_focused':
        // Se ora preferisce angoli, prendi il centro
        if (moves.contains(4)) return 4;
        break;
      case 'center_focused':
        // Se ora preferisce centro, prendi angoli
        final corners = [0, 2, 6, 8];
        for (int corner in corners) {
          if (moves.contains(corner)) return corner;
        }
        break;
      case 'side_focused':
        // Se ora preferisce lati, sii aggressivo con angoli e centro
        if (moves.contains(4)) return 4;
        final corners = [0, 2, 6, 8];
        for (int corner in corners) {
          if (moves.contains(corner)) return corner;
        }
        break;
    }

    return moves[Random().nextInt(moves.length)];
  }
}

/// Hard 3: Game Theory Optimal - Teoricamente ottimale
class GameTheoryOptimalStrategy extends SimultaneousAIStrategyImplementation {
  @override
  String get displayName => 'Game Theory Optimal';
  
  @override
  String get description => 'Strategia teoricamente ottimale basata su equilibri di Nash e teoria dei giochi.';

  @override
  String get counterStrategy => 'Non esiste una counter-strategia perfetta! L\'unico modo è giocare anche tu in modo ottimale e sperare nei pareggi.';

  @override
  AIDifficulty get difficulty => AIDifficulty.hard;

  static final Map<String, double> _moveUtilities = {};

  @override
  int selectMove(SimultaneousTicTacToeGame game, List<int> playerMoveHistory) {
    final availableMoves = _getAvailableMoves(game);
    if (availableMoves.isEmpty) return 0;

    // Calcola utilità Nash per ogni mossa
    final utilities = <int, double>{};
    
    for (int move in availableMoves) {
      utilities[move] = _calculateNashUtility(move, game, playerMoveHistory, availableMoves);
    }

    // Trova l'equilibrio di Nash mixed strategy
    final nashMove = _findNashEquilibrium(utilities, game);
    return nashMove;
  }

  double _calculateNashUtility(int move, SimultaneousTicTacToeGame game, List<int> history, List<int> allMoves) {
    double utility = 0.0;

    // Matrice di payoff per ogni possibile mossa dell'avversario
    for (int opponentMove in allMoves) {
      final probability = _estimateOpponentProbability(opponentMove, history, allMoves);
      final payoff = _calculatePayoff(move, opponentMove, game);
      utility += probability * payoff;
    }

    return utility;
  }

  double _estimateOpponentProbability(int move, List<int> history, List<int> available) {
    // Distribuzione di probabilità basata su comportamento osservato
    if (history.isEmpty) {
      // Distribuzione uniforme iniziale con bias verso posizioni forti
      if (move == 4) return 0.2; // Centro più probabile
      if ([0, 2, 6, 8].contains(move)) return 0.15; // Angoli
      return 0.1; // Lati
    }

    // Stima bayesiana basata sulla storia
    double baseProbability = 1.0 / available.length;
    
    // Aggiusta in base alla frequenza passata
    final moveCount = history.where((m) => m == move).length;
    final totalMoves = history.length;
    
    if (totalMoves > 0) {
      final observedFrequency = moveCount / totalMoves;
      baseProbability = (baseProbability + observedFrequency) / 2.0;
    }

    // Bias strategico
    if (move == 4) baseProbability *= 1.3;
    if ([0, 2, 6, 8].contains(move)) baseProbability *= 1.1;

    return baseProbability;
  }

  double _calculatePayoff(int myMove, int opponentMove, SimultaneousTicTacToeGame game) {
    // Simula l'outcome di entrambe le mosse
    final tempBoard = List<SimultaneousPlayer>.from(game.board);
    
    if (myMove == opponentMove) {
      // Conflitto: nessuno ottiene la cella
      return _evaluateBoardPosition(tempBoard);
    } else {
      // Entrambe le mosse si applicano
      tempBoard[myMove] = SimultaneousPlayer.ai;
      tempBoard[opponentMove] = SimultaneousPlayer.human;
      
      // Controlla se AI vince
      if (_checkWinner(tempBoard) == SimultaneousPlayer.ai) {
        return 100.0;
      }
      
      // Controlla se il giocatore vince
      if (_checkWinner(tempBoard) == SimultaneousPlayer.human) {
        return -100.0;
      }
      
      // Valuta la posizione risultante
      return _evaluateBoardPosition(tempBoard);
    }
  }

  double _evaluateBoardPosition(List<SimultaneousPlayer> board) {
    double score = 0.0;

    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (final pattern in winPatterns) {
      int aiCount = 0;
      int humanCount = 0;
      int emptyCount = 0;

      for (int pos in pattern) {
        switch (board[pos]) {
          case SimultaneousPlayer.ai:
            aiCount++;
            break;
          case SimultaneousPlayer.human:
            humanCount++;
            break;
          case SimultaneousPlayer.none:
            emptyCount++;
            break;
        }
      }

      // Punteggio per linee controllate
      if (humanCount == 0) {
        score += aiCount * aiCount * 2.0;
      } else if (aiCount == 0) {
        score -= humanCount * humanCount * 2.0;
      }

      // Bonus per minacce immediate
      if (aiCount == 2 && emptyCount == 1) {
        score += 10.0;
      } else if (humanCount == 2 && emptyCount == 1) {
        score -= 15.0; // Minacce dell'avversario pesano di più
      }
    }

    // Controllo del centro
    if (board[4] == SimultaneousPlayer.ai) {
      score += 3.0;
    } else if (board[4] == SimultaneousPlayer.human) {
      score -= 3.0;
    }

    return score;
  }

  int _findNashEquilibrium(Map<int, double> utilities, SimultaneousTicTacToeGame game) {
    // Implementa mixed strategy Nash equilibrium
    
    // Se c'è una strategia dominante (utilità molto alta), usala
    final maxUtility = utilities.values.reduce((a, b) => a > b ? a : b);
    final dominantMoves = utilities.entries.where((e) => e.value >= maxUtility * 0.95).toList();
    
    if (dominantMoves.length == 1) {
      return dominantMoves.first.key;
    }

    // Altrimenti, usa strategia mista pesata sulle utilità
    final totalUtility = utilities.values.fold(0.0, (sum, u) => sum + (u > 0 ? u : 0));
    
    if (totalUtility > 0) {
      double random = Random().nextDouble() * totalUtility;
      double cumulative = 0.0;
      
      for (final entry in utilities.entries) {
        if (entry.value > 0) {
          cumulative += entry.value;
          if (random <= cumulative) {
            return entry.key;
          }
        }
      }
    }

    // Fallback: strategia uniforme sui move migliori
    final sortedMoves = utilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topMoves = sortedMoves.take(3).map((e) => e.key).toList();
    return topMoves[Random().nextInt(topMoves.length)];
  }
}