import '../strategies/coop/coop_ai_strategy.dart';
import 'enums.dart';

/// Sistema di tracciamento progresso per le strategie AI cooperative
class CoopStrategyProgress {
  final Map<String, int> _consecutiveWins = {};
  final Map<String, bool> _defeated = {};
  final List<int> _playerMoveHistory = [];
  
  int getConsecutiveWins(CoopAIStrategy strategy) {
    return _consecutiveWins[strategy.name] ?? 0;
  }
  
  bool isDefeated(CoopAIStrategy strategy) {
    return _defeated[strategy.name] ?? false;
  }
  
  void addWin(CoopAIStrategy strategy) {
    final key = strategy.name;
    _consecutiveWins[key] = (_consecutiveWins[key] ?? 0) + 1;
    if (_consecutiveWins[key]! >= 3) {
      _defeated[key] = true;
    }
  }
  
  void addLoss(CoopAIStrategy strategy) {
    _consecutiveWins[strategy.name] = 0;
  }
  
  int getWinsNeeded(CoopAIStrategy strategy) {
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
  String getDisplayName(CoopAIStrategy strategy) {
    if (isDefeated(strategy)) {
      final impl = CoopAIStrategyFactory.createStrategy(strategy);
      return impl.displayName;
    }
    
    // Nomi generici basati sulla difficoltà
    final impl = CoopAIStrategyFactory.createStrategy(strategy);
    switch (impl.difficulty) {
      case AIDifficulty.easy:
        final easyNames = ['Assistente', 'Aiutante', 'Compagno'];
        final strategies = CoopAIStrategyFactory.getStrategiesByDifficulty(AIDifficulty.easy);
        final index = strategies.indexOf(strategy);
        return index >= 0 && index < easyNames.length 
            ? easyNames[index] 
            : 'Cooperativo Facile';
      case AIDifficulty.medium:
        final mediumNames = ['Alleato', 'Partner', 'Squadra'];
        final strategies = CoopAIStrategyFactory.getStrategiesByDifficulty(AIDifficulty.medium);
        final index = strategies.indexOf(strategy);
        return index >= 0 && index < mediumNames.length 
            ? mediumNames[index] 
            : 'Cooperativo Medio';
      case AIDifficulty.hard:
        final hardNames = ['Veterano', 'Specialista', 'Élite'];
        final strategies = CoopAIStrategyFactory.getStrategiesByDifficulty(AIDifficulty.hard);
        final index = strategies.indexOf(strategy);
        return index >= 0 && index < hardNames.length 
            ? hardNames[index] 
            : 'Cooperativo Difficile';
    }
  }
  
  /// Ottieni consigli sulla counter-strategy per una strategia sconfitta
  String getCounterStrategy(CoopAIStrategy strategy) {
    final impl = CoopAIStrategyFactory.createStrategy(strategy);
    
    switch (strategy) {
      // Easy strategies
      case CoopAIStrategy.supportive:
        return 'Coordinazione Prevedibile: L\'AI amica segue pattern fissi. '
            'Variazione: Cambia il tuo stile per confondere il supporto automatico.';
      case CoopAIStrategy.defensive:
        return 'Difesa Passiva: L\'AI amica si concentra solo sul blocco. '
            'Aggressività: Forza l\'attacco mentre lei difende per creare aperture.';
      case CoopAIStrategy.random:
        return 'Caos Totale: Nessuna strategia coerente da entrambe le parti. '
            'Controllo: Mantieni tu il controllo del gioco con mosse logiche.';
      
      // Medium strategies
      case CoopAIStrategy.coordinated:
        return 'Coordinazione Schematica: L\'AI usa pattern di supporto riconoscibili. '
            'Imprevedibilità: Rompi i suoi schemi con mosse inattese per confondere la coordinazione.';
      case CoopAIStrategy.aggressive:
        return 'Aggressività Cieca: L\'AI amica attacca ma lascia scoperte le difese. '
            'Contrattacco: Punisci gli errori difensivi mentre lei si concentra sull\'attacco.';
      case CoopAIStrategy.balanced:
        return 'Equilibrio Prevedibile: L\'AI bilancia perfettamente ma con schemi fissi. '
            'Asimmetria: Usa tattiche sbilanciate per rompere il suo equilibrio.';
      
      // Hard strategies
      case CoopAIStrategy.tactical:
        return 'Pianificazione Rigida: L\'AI usa tattiche avanzate ma calcolate. '
            'Spontaneità: Usa mosse spontanee per mandare in tilt i suoi calcoli avanzati.';
      case CoopAIStrategy.adaptive:
        return 'Adattamento Analitico: L\'AI si adatta al tuo stile ma ha bisogno di tempo. '
            'Metamorfosi: Cambia costantemente stile per impedire l\'adattamento completo.';
      case CoopAIStrategy.optimal:
        return 'Perfezione Matematica: L\'AI gioca in modo ottimale ma prevedibile. '
            'Sacrificio Tattico: Accetta perdite strategiche per confondere la logica ottimale.';
    }
  }

  /// Ottieni multiple counter-strategie dettagliate per strategie cooperative
  List<String> getMultipleCounterStrategies(CoopAIStrategy strategy) {
    switch (strategy) {
      // Easy strategies
      case CoopAIStrategy.supportive:
        return [
          'Variazione di Pattern: Cambia il tuo stile di gioco per confondere il supporto automatico dell\'AI amica.',
          'Creazione di Setup: Usa le sue mosse prevedibili per creare setup che l\'AI nemica non può anticipare.',
        ];
      case CoopAIStrategy.defensive:
        return [
          'Aggressività Coordinata: Forza l\'attacco per creare aperture mentre l\'AI amica si concentra sulla difesa.',
          'Doppia Minaccia: Crea situazioni dove sono necessari sia attacco che difesa per sfruttare la sua passività.',
        ];
      case CoopAIStrategy.random:
        return [
          'Leadership Strutturata: Prendi il controllo con mosse logiche per compensare il caos delle AI.',
          'Adattamento Rapido: Sfrutta velocemente le opportunità casuali create dal comportamento imprevedibile.',
        ];

      // Medium strategies  
      case CoopAIStrategy.coordinated:
        return [
          'Rottura dei Pattern: Usa mosse inattese per rompere la coordinazione schematica dell\'AI amica.',
          'Timing Irregolare: Varia il ritmo delle tue mosse per confondere la sincronizzazione.',
        ];
      case CoopAIStrategy.aggressive:
        return [
          'Gioco di Contrappeso: Bilancia la sua aggressività con difese tattiche per coprire le aperture.',
          'Sfruttamento Errori: Capitalizza sugli errori difensivi causati dalla sua focalizzazione sull\'attacco.',
        ];
      case CoopAIStrategy.balanced:
        return [
          'Asimmetria Tattica: Usa approcci completamente sbilanciati per rompere il suo equilibrio.',
          'Specializzazione Estrema: Concentrati solo su attacco o difesa per costringerla fuori dall\'equilibrio.',
        ];

      // Hard strategies
      case CoopAIStrategy.tactical:
        return [
          'Spontaneità Strategica: Usa mosse creative per superare i suoi calcoli tattici avanzati.',
          'Complessità Dinamica: Crea situazioni troppo complesse per la sua pianificazione a lungo termine.',
        ];
      case CoopAIStrategy.adaptive:
        return [
          'Metamorfosi Continua: Cambia stile così rapidamente da impedire il completamento dell\'adattamento.',
          'Falsi Segnali: Crea pattern apparenti per poi cambiarli quando inizia ad adattarsi.',
        ];
      case CoopAIStrategy.optimal:
        return [
          'Deviazione Calcolata: Accetta perdite tattiche per confondere la sua logica matematica ottimale.',
          'Innovazione Radicale: Usa approcci completamente nuovi che non sono nei suoi calcoli ottimali.',
        ];
        
      default: 
        return ['Strategia Ibrida: Combina tutti gli approcci cooperativi per massima flessibilità.'];
    }
  }
  
  /// Statistiche globali
  Map<String, dynamic> getStats() {
    final totalStrategies = CoopAIStrategy.values.length;
    final defeatedCount = _defeated.values.where((defeated) => defeated).length;
    final overallProgress = defeatedCount / totalStrategies;

    return {
      'totalStrategies': totalStrategies,
      'defeatedCount': defeatedCount,
      'overallProgress': overallProgress,
    };
  }
  
  /// Ottieni tutte le strategie
  static List<CoopAIStrategy> getAllStrategies() {
    return CoopAIStrategy.values;
  }

  /// Ottieni strategie per difficoltà
  static List<CoopAIStrategy> getStrategiesByDifficulty(AIDifficulty difficulty) {
    return CoopAIStrategyFactory.getStrategiesByDifficulty(difficulty);
  }

  /// Calcola progresso globale
  double getOverallProgress() {
    final stats = getStats();
    return stats['overallProgress'] as double;
  }
}