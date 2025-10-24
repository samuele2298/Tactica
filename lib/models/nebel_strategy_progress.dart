import '../strategies/nebel/nebel_ai_strategy.dart';
import 'enums.dart';

/// Sistema di tracciamento progresso per le strategie AI Nebel (fog of war)
class NebelStrategyProgress {
  final Map<String, int> _consecutiveWins = {};
  final Map<String, bool> _defeated = {};
  final List<int> _playerMoveHistory = [];
  
  int getConsecutiveWins(NebelAIStrategy strategy) {
    return _consecutiveWins[strategy.name] ?? 0;
  }
  
  bool isDefeated(NebelAIStrategy strategy) {
    return _defeated[strategy.name] ?? false;
  }
  
  void addWin(NebelAIStrategy strategy) {
    final key = strategy.name;
    _consecutiveWins[key] = (_consecutiveWins[key] ?? 0) + 1;
    if (_consecutiveWins[key]! >= 3) {
      _defeated[key] = true;
    }
  }
  
  void addLoss(NebelAIStrategy strategy) {
    _consecutiveWins[strategy.name] = 0;
  }
  
  int getWinsNeeded(NebelAIStrategy strategy) {
    if (isDefeated(strategy)) return 0;
    return 3 - getConsecutiveWins(strategy);
  }
  
  void addPlayerMove(int move) {
    _playerMoveHistory.add(move);
    // Mantieni solo le ultime 10 mosse per l'analisi
    if (_playerMoveHistory.length > 10) {
      _playerMoveHistory.removeAt(0);
    }
  }
  
  List<int> getPlayerMoveHistory() => List.from(_playerMoveHistory);
  
  void reset() {
    _consecutiveWins.clear();
    _defeated.clear();
    _playerMoveHistory.clear();
  }
  
  /// Nome da mostrare: generico se non sconfitta, reale se sconfitta
  String getDisplayName(NebelAIStrategy strategy) {
    if (isDefeated(strategy)) {
      final impl = NebelAIStrategyFactory.createStrategy(strategy);
      return impl.displayName;
    }
    
    // Nomi generici per difficoltà
    final impl = NebelAIStrategyFactory.createStrategy(strategy);
    switch (impl.difficulty) {
      case AIDifficulty.easy:
        final easyStrategies = [NebelAIStrategy.cautious, NebelAIStrategy.random, NebelAIStrategy.conservative];
        final index = easyStrategies.indexOf(strategy);
        return 'Strategia Facile ${String.fromCharCode(65 + index)}'; // A, B, C
      case AIDifficulty.medium:
        final mediumStrategies = [NebelAIStrategy.probing, NebelAIStrategy.adaptive, NebelAIStrategy.balanced];
        final index = mediumStrategies.indexOf(strategy);
        return 'Strategia Media ${String.fromCharCode(65 + index)}'; // A, B, C
      case AIDifficulty.hard:
        final hardStrategies = [NebelAIStrategy.probabilistic, NebelAIStrategy.analytical, NebelAIStrategy.optimal];
        final index = hardStrategies.indexOf(strategy);
        return 'Strategia Difficile ${String.fromCharCode(65 + index)}'; // A, B, C
    }
  }
  
  /// Ottieni counter-strategies multiple per strategie sconfitte
  List<String> getMultipleCounterStrategies(NebelAIStrategy strategy) {
    if (!isDefeated(strategy)) return [];
    
    switch (strategy) {
      // Easy strategies
      case NebelAIStrategy.cautious:
        return [
          "Sfrutta Aggressività: L'AI cauta evita le celle nascoste. Sonda tu per primo le posizioni strategiche per ottenere informazioni vantaggiose.",
          "Controllo Centro: Occupi il centro rapidamente dato che l'AI preferisce celle sicure. Forza l'AI a giocare in posizioni subottimali."
        ];
      case NebelAIStrategy.random:
        return [
          "Gioco Strutturato: Mantieni un approccio sistematico alle tue mosse. L'AI casuale non ha strategia, quindi una buona tattica vince facilmente.",
          "Controllo Posizioni Chiave: Prioritizza centro e angoli. Senza strategia dell'AI, il controllo posizionale garantisce la vittoria."
        ];
      case NebelAIStrategy.conservative:
        return [
          "Attacco Coordinato: L'AI difende sempre per prima. Crea multiple minacce simultanee che non può bloccare tutte insieme.",
          "Sfrutta Passività: L'AI conservativa reagisce invece di agire. Prendi l'iniziativa e costringila a seguire la tua strategia."
        ];
        
      // Medium strategies
      case NebelAIStrategy.probing:
        return [
          "Informazione Selettiva: L'AI sonda per informazioni. Controlla quando rivelare informazioni e quando tenerle nascoste per ingannarla.",
          "Diversione Tattica: Crea false opportunità nelle celle nascoste. L'AI sprecherà mosse sondando posizioni non critiche che hai preparato."
        ];
      case NebelAIStrategy.adaptive:
        return [
          "Cambia Pattern: L'AI si adatta ai tuoi schemi. Varia costantemente il tuo stile di gioco per confondere la sua analisi adattiva.",
          "Pattern Ingannevoli: Stabilisci false preferenze iniziali, poi cambia strategia completamente quando l'AI si è adattata."
        ];
      case NebelAIStrategy.balanced:
        return [
          "Specializzazione Estrema: L'AI bilancia tutto. Specializzati in un aspetto (attacco puro o difesa ferrea) per superare il suo equilibrio.",
          "Timing Critico: L'AI distribuisce le priorità equamente. Concentra le tue mosse in momenti chiave per sopraffarla quando è meno preparata."
        ];
        
      // Hard strategies  
      case NebelAIStrategy.probabilistic:
        return [
          "Chaos Controllato: L'AI calcola probabilità. Introduci elementi apparentemente casuali ma strategicamente mirati per confondere i suoi calcoli.",
          "Anti-Matematica: Gioca mosse 'subottimali' che creano situazioni che i calcoli probabilistici non prevedono bene."
        ];
      case NebelAIStrategy.analytical:
        return [
          "Sovraccarico Computazionale: L'AI analizza tutto profondamente. Crea situazioni complesse con molte variabili per rallentare la sua analisi.",
          "Intuizione vs Logica: Usa mosse intuitive che sembrano illogiche ma hanno senso strategico a lungo termine."
        ];
      case NebelAIStrategy.optimal:
        return [
          "Meta-Strategia: L'AI gioca perfettamente nelle regole standard. Sfrutta elementi umani come bluff psicologico e letture comportamentali.",
          "Errori Forzati: L'AI ottimale assume che tu giochi ottimale. Fai mosse 'sbagliate' che costringono l'AI in posizioni dove la sua ottimalità si rivolta contro."
        ];
    }
  }
}