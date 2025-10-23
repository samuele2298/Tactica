import '../strategies/simultaneous/simultaneous_ai_strategy.dart';
import '../models/ai_difficulty.dart';

/// Sistema di tracciamento progresso per le strategie AI simultanee
class SimultaneousStrategyProgress {
  final Map<String, int> _consecutiveWins = {};
  final Map<String, bool> _defeated = {};
  final List<int> _playerMoveHistory = [];
  
  int getConsecutiveWins(SimultaneousAIStrategy strategy) {
    return _consecutiveWins[strategy.name] ?? 0;
  }
  
  bool isDefeated(SimultaneousAIStrategy strategy) {
    return _defeated[strategy.name] ?? false;
  }
  
  void addWin(SimultaneousAIStrategy strategy) {
    _consecutiveWins[strategy.name] = (_consecutiveWins[strategy.name] ?? 0) + 1;
    if (_consecutiveWins[strategy.name]! >= 3) {
      _defeated[strategy.name] = true;
    }
  }
  
  void addLoss(SimultaneousAIStrategy strategy) {
    _consecutiveWins[strategy.name] = 0;
  }
  
  void addPlayerMove(int move) {
    _playerMoveHistory.add(move);
    
    // Mantieni solo gli ultimi 10 movimenti per evitare memoria eccessiva
    if (_playerMoveHistory.length > 10) {
      _playerMoveHistory.removeAt(0);
    }
  }
  
  List<int> getPlayerMoveHistory() {
    return List.from(_playerMoveHistory);
  }
  
  void reset() {
    _consecutiveWins.clear();
    _defeated.clear();
    _playerMoveHistory.clear();
  }
  
  void resetGameHistory() {
    // Reset solo della storia delle mosse, non dei progressi
    _playerMoveHistory.clear();
  }
  
  int getWinsNeeded(SimultaneousAIStrategy strategy) {
    if (isDefeated(strategy)) return 0;
    return 3 - getConsecutiveWins(strategy);
  }
  
  /// Ottieni la counter-strategy specifica per ogni strategia simultanea
  String getCounterStrategy(SimultaneousAIStrategy strategy) {
    final impl = SimultaneousAIStrategyFactory.createStrategy(strategy);
    return impl.counterStrategy;
  }

  /// Ottieni multiple counter-strategie dettagliate per strategie simultanee
  List<String> getMultipleCounterStrategies(SimultaneousAIStrategy strategy) {
    switch (strategy) {
      // Easy strategies
      case SimultaneousAIStrategy.easy1: // Randomizer
        return [
          'Controllo Centrale: Occupa sempre il centro per massimizzare le tue opzioni di vittoria.',
          'Pattern Sistematico: Usa una strategia fissa per compensare la sua casualità.',
        ];
      case SimultaneousAIStrategy.easy2: // CopyMove  
        return [
          'Variazione Immediata: Cambia pattern non appena inizia a copiarti per confonderla.',
          'Mosse Trappola: Fai mosse che sembrano buone da copiare ma portano a svantaggi.',
        ];
      case SimultaneousAIStrategy.easy3: // AvoidLast
        return [
          'Predizione Inversa: Anticipa dove non andrà e sfrutta quegli spazi.',
          'Controllo Stretto: Limita le sue opzioni fino a costringerla nella cella che evita.',
        ];

      // Medium strategies  
      case SimultaneousAIStrategy.medium1: // PatternHunter
        return [
          'Falsi Pattern: Crea pattern apparenti per poi romperli quando li individua.',
          'Caos Controllato: Usa sequenze pseudocasuali per impedire il riconoscimento pattern.',
        ];
      case SimultaneousAIStrategy.medium2: // AntiPredictable
        return [
          'Meta-Prevedibilità: Sii prevedibile a un livello più alto per confondere la sua anti-prevedibilità.',
          'Ritmo Variabile: Alterna fasi prevedibili e imprevedibili per romperle la logica.',
        ];
      case SimultaneousAIStrategy.medium3: // SafePlayer
        return [
          'Pressione Costante: Forza continuamente l\'attacco per costringerla fuori dalla sua zona sicura.',
          'Sacrificio Tattico: Accetta rischi calcolati per rompere il suo gioco difensivo.',
        ];

      // Hard strategies
      case SimultaneousAIStrategy.hard1: // Probabilistic
        return [
          'Sequenze Anomale: Usa pattern che violano le distribuzioni probabilistiche normali.',
          'Bias Indotto: Crea false correlazioni per ingannare i suoi calcoli probabilistici.',
        ];
      case SimultaneousAIStrategy.hard2: // MetaGame
        return [
          'Meta-Meta Gaming: Gioca considerando che lei sa che tu sai che lei sa.',
          'Rottura Ricorsiva: Interrompi i loop di ragionamento con mosse completamente irrazionali.',
        ];
      case SimultaneousAIStrategy.hard3: // GameTheoryOptimal
        return [
          'Deviazione Strategica: Usa deliberatamente strategie subottimali per confondere il GTO.',
          'Equilibrio Dinamico: Cambia il "gioco" stesso variando le priorità tra vincita e pareggio.',
        ];
        
      default: 
        return ['Strategia Adattiva: Combina tutti gli approcci simultanei per massima imprevedibilità.'];
    }
  }

  /// Ottieni il nome da mostrare (generico o reale)
  String getDisplayName(SimultaneousAIStrategy strategy) {
    if (isDefeated(strategy)) {
      final impl = SimultaneousAIStrategyFactory.createStrategy(strategy);
      return impl.displayName;
    } else {
      return SimultaneousAIStrategyFactory.getGenericName(strategy);
    }
  }

  /// Ottieni la descrizione da mostrare (nascosta o reale)
  String getDescription(SimultaneousAIStrategy strategy) {
    if (isDefeated(strategy)) {
      final impl = SimultaneousAIStrategyFactory.createStrategy(strategy);
      return impl.description;
    } else {
      return 'Strategia non ancora sconfitta. Battila 3 volte per svelarne i segreti!';
    }
  }

  /// Ottieni tutte le strategie disponibili
  static List<SimultaneousAIStrategy> getAllStrategies() {
    return SimultaneousAIStrategy.values;
  }

  /// Ottieni strategie per difficoltà
  static List<SimultaneousAIStrategy> getStrategiesByDifficulty(AIDifficulty difficulty) {
    return SimultaneousAIStrategyFactory.getStrategiesByDifficulty(difficulty);
  }

  /// Calcola progresso globale
  double getOverallProgress() {
    final totalStrategies = SimultaneousAIStrategy.values.length;
    final defeatedCount = _defeated.values.where((defeated) => defeated).length;
    return defeatedCount / totalStrategies;
  }

  /// Ottieni statistiche per UI
  Map<String, dynamic> getStats() {
    final totalStrategies = SimultaneousAIStrategy.values.length;
    final defeatedCount = _defeated.values.where((defeated) => defeated).length;
    final totalWins = _consecutiveWins.values.fold(0, (sum, wins) => sum + wins);
    
    return {
      'totalStrategies': totalStrategies,
      'defeatedCount': defeatedCount,
      'totalWins': totalWins,
      'overallProgress': getOverallProgress(),
      'nextToDefeat': _getNextStrategyToDefeat(),
    };
  }

  SimultaneousAIStrategy? _getNextStrategyToDefeat() {
    // Trova la strategia più vicina ad essere sconfitta
    SimultaneousAIStrategy? nextStrategy;
    int maxWins = 0;
    
    for (final strategy in SimultaneousAIStrategy.values) {
      if (!isDefeated(strategy)) {
        final wins = getConsecutiveWins(strategy);
        if (wins > maxWins) {
          maxWins = wins;
          nextStrategy = strategy;
        }
      }
    }
    
    return nextStrategy;
  }

  /// Serializzazione per persistenza (opzionale)
  Map<String, dynamic> toJson() {
    return {
      'consecutiveWins': Map<String, int>.from(_consecutiveWins),
      'defeated': Map<String, bool>.from(_defeated),
      'playerMoveHistory': List<int>.from(_playerMoveHistory),
    };
  }

  /// Deserializzazione da persistenza (opzionale)
  static SimultaneousStrategyProgress fromJson(Map<String, dynamic> json) {
    final progress = SimultaneousStrategyProgress();
    
    if (json['consecutiveWins'] != null) {
      progress._consecutiveWins.addAll(
        Map<String, int>.from(json['consecutiveWins'])
      );
    }
    
    if (json['defeated'] != null) {
      progress._defeated.addAll(
        Map<String, bool>.from(json['defeated'])
      );
    }
    
    if (json['playerMoveHistory'] != null) {
      progress._playerMoveHistory.addAll(
        List<int>.from(json['playerMoveHistory'])
      );
    }
    
    return progress;
  }
}