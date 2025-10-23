import 'ai_difficulty.dart';

class StrategyProgress {
  final Map<String, int> _consecutiveWins = {};
  final Map<String, bool> _defeated = {};
  
  int getConsecutiveWins(String strategyId) {
    return _consecutiveWins[strategyId] ?? 0;
  }
  
  bool isDefeated(String strategyId) {
    return _defeated[strategyId] ?? false;
  }
  
  void addWin(String strategyId) {
    _consecutiveWins[strategyId] = (_consecutiveWins[strategyId] ?? 0) + 1;
    if (_consecutiveWins[strategyId]! >= 3) {
      _defeated[strategyId] = true;
    }
  }
  
  void addLoss(String strategyId) {
    _consecutiveWins[strategyId] = 0;
  }
  
  void reset() {
    _consecutiveWins.clear();
    _defeated.clear();
  }
  
  int getWinsNeeded(String strategyId) {
    if (isDefeated(strategyId)) return 0;
    return 3 - getConsecutiveWins(strategyId);
  }
  
  // Ottieni la strategia counter che l'utente ha usato
  String getCounterStrategy(String aiStrategyId) {
    // Logica semplificata per determinare la counter-strategy
    switch (aiStrategyId) {
      case 'easy1': return 'Blocco Centrale';
      case 'easy2': return 'Controllo Angoli';
      case 'easy3': return 'Strategia Anti-Spirale';
      case 'medium1': return 'Attacco Aggressivo';
      case 'medium2': return 'Contromosse Rapide';
      case 'medium3': return 'Equilibrio Tattico';
      case 'hard1': return 'Imprevedibilità';
      case 'hard2': return 'Controllo Difensivo';
      case 'hard3': return 'Adattamento Dinamico';
      default: return 'Strategia Mista';
    }
  }

  // Ottieni multiple counter-strategie dettagliate
  List<String> getMultipleCounterStrategies(String aiStrategyId) {
    switch (aiStrategyId) {
      // Easy strategies
      case 'easy1': // Centro-Fisso
        return [
          'Controllo Angoli: Occupa gli angoli prima che l\'AI li raggiunga, limitando le sue opzioni centrali.',
          'Blocco Perimetrale: Usa i lati della griglia per interrompere i suoi pattern fissi verso gli angoli.',
        ];
      case 'easy2': // Angoli-Fisso  
        return [
          'Dominio Centrale: Conquista il centro quando lei va agli angoli per controllare più linee di vittoria.',
          'Blocco Incrociato: Usa i lati per creare barriere tra gli angoli che vuole collegare.',
        ];
      case 'easy3': // Spirale
        return [
          'Rottura Centrale: Interrompi la spirale occupando il centro non appena possibile.',
          'Controspiral: Segui una spirale inversa per confondere il suo pattern prevedibile.',
        ];
      
      // Medium strategies  
      case 'medium1': // Difensore
        return [
          'Minacce Multiple: Crea due minacce contemporaneamente, non può difendere entrambe.',
          'Attacco Forzato: Usa sacrifici tattici per costringerla a giocare in attacco invece che difesa.',
        ];
      case 'medium2': // Opportunista
        return [
          'Gioco Paziente: Mantieni difese solide e lascia che commetta errori cercando sempre l\'attacco.',
          'Contrattacco Rapido: Quando attacca aggressivamente, punisci subito le aperture che lascia.',
        ];
      case 'medium3': // Bilanciato
        return [
          'Asimmetria Tattica: Usa uno stile completamente sbilanciato per rompere il suo equilibrio.',
          'Variazione Costante: Cambia approccio ogni mossa per impedirle di adattarsi.',
        ];
      
      // Hard strategies
      case 'hard1': // Minimax Puro
        return [
          'Sacrificio Strategico: Accetta perdite minori per confondere i suoi calcoli ottimali.',
          'Gioco Creativo: Usa mosse "subottimali" che portano a posizioni che non può calcolare perfettamente.',
        ];
      case 'hard2': // Aggressivo
        return [
          'Controllo Difensivo: Mantieni difese impenetrabili e aspetta i suoi errori forzati.',
          'Gioco Posizionale: Controlla spazi chiave invece di cercare vittorie immediate.',
        ];
      case 'hard3': // Adattivo
        return [
          'Metamorfosi Continua: Cambia stile di gioco ogni turno per impedire l\'adattamento completo.',
          'Pattern Falsi: Crea pattern apparenti per poi cambiarli quando inizia ad adattarsi.',
        ];
        
      default: 
        return ['Strategia Mista: Combina elementi di tutte le altre strategie per confondere l\'AI.'];
    }
  }

  // Ottieni nome generico per strategia non sconfitta
  String getGenericName(dynamic strategy) {
    if (strategy is AIStrategy) {
      switch (strategy.difficulty) {
        case AIDifficulty.easy:
          final easyStrategies = ['Apprendista', 'Principiante', 'Novizio'];
          final index = AIDifficulty.easy.strategies.indexOf(strategy);
          return index >= 0 && index < easyStrategies.length 
              ? easyStrategies[index] 
              : 'IA Facile';
        case AIDifficulty.medium:
          final mediumStrategies = ['Sfidante', 'Competitore', 'Tattico'];
          final index = AIDifficulty.medium.strategies.indexOf(strategy);
          return index >= 0 && index < mediumStrategies.length 
              ? mediumStrategies[index] 
              : 'IA Media';
        case AIDifficulty.hard:
          final hardStrategies = ['Esperto', 'Maestro', 'Veterano'];
          final index = AIDifficulty.hard.strategies.indexOf(strategy);
          return index >= 0 && index < hardStrategies.length 
              ? hardStrategies[index] 
              : 'IA Difficile';
      }
    }
    return 'IA Sconosciuta';
  }

  // Ottieni statistiche globali
  Map<String, dynamic> getStats() {
    final totalStrategies = 9; // 3 per ogni difficoltà
    final defeatedCount = _defeated.values.where((defeated) => defeated).length;
    final overallProgress = defeatedCount / totalStrategies;

    return {
      'totalStrategies': totalStrategies,
      'defeatedCount': defeatedCount,
      'overallProgress': overallProgress,
    };
  }
}