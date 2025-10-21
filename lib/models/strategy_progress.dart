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
}