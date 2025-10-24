import 'enums.dart';

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