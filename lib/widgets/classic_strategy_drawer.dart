import 'package:flutter/material.dart';
import '../models/ai_difficulty.dart';
import '../models/strategy_progress.dart';
import '../widgets/base_strategy_drawer.dart';

/// Implementazione del drawer per la modalità Classic
class ClassicStrategyDrawer extends StatelessWidget {
  final AIStrategy currentStrategy;
  final StrategyProgress progress;
  final Function(AIStrategy) onStrategySelected;
  final VoidCallback? onClose;
  final Function(AIStrategy)? onInfoPressed;

  const ClassicStrategyDrawer({
    Key? key,
    required this.currentStrategy,
    required this.progress,
    required this.onStrategySelected,
    this.onClose,
    this.onInfoPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseStrategyDrawer<ClassicStrategyAdapter>(
      currentStrategy: ClassicStrategyAdapter(currentStrategy),
      progress: ClassicProgressAdapter(progress),
      onStrategySelected: (adapter) => onStrategySelected(adapter.strategy),
      onClose: onClose,
      config: DrawerConfig.classic,
      strategies: AIStrategy.values.map((s) => ClassicStrategyAdapter(s)).toList(),
      onInfoPressed: onInfoPressed != null 
          ? (adapter) => onInfoPressed!(adapter.strategy)
          : null,
    );
  }
}

/// Adapter per AIStrategy per implementare GenericStrategy
class ClassicStrategyAdapter implements GenericStrategy {
  final AIStrategy strategy;
  
  ClassicStrategyAdapter(this.strategy);
  
  @override
  String get name => strategy.name;
  
  @override
  String get displayName => strategy.displayName;
  
  @override
  AIDifficulty get difficulty => strategy.difficulty;
}

/// Adapter per StrategyProgress per implementare GenericProgress
class ClassicProgressAdapter implements GenericProgress {
  final StrategyProgress progress;
  
  ClassicProgressAdapter(this.progress);
  
  @override
  int getConsecutiveWins(String strategyName) {
    final strategy = AIStrategy.values.firstWhere((s) => s.name == strategyName);
    return progress.getConsecutiveWins(strategy.name);
  }
  
  @override
  int getWinsNeeded(String strategyName) {
    final strategy = AIStrategy.values.firstWhere((s) => s.name == strategyName);
    return progress.getWinsNeeded(strategy.name);
  }
  
  @override
  bool isDefeated(String strategyName) {
    final strategy = AIStrategy.values.firstWhere((s) => s.name == strategyName);
    return progress.isDefeated(strategy.name);
  }
  
  @override
  String getDisplayName(GenericStrategy strategy) {
    final aiStrategy = AIStrategy.values.firstWhere((s) => s.name == strategy.name);
    return progress.isDefeated(aiStrategy.name) 
        ? aiStrategy.displayName 
        : progress.getGenericName(aiStrategy);
  }
  
  @override
  Map<String, dynamic> getStats() {
    return progress.getStats();
  }
}