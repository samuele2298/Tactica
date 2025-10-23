import 'package:flutter/material.dart';
import '../models/ai_difficulty.dart';
import '../models/coop_strategy_progress.dart';
import '../strategies/coop/coop_ai_strategy.dart';
import '../widgets/base_strategy_drawer.dart';

/// Implementazione del drawer per la modalità Cooperative
class CoopStrategyDrawer extends StatelessWidget {
  final CoopAIStrategy currentStrategy;
  final CoopStrategyProgress progress;
  final Function(CoopAIStrategy) onStrategySelected;
  final VoidCallback? onClose;
  final Function(CoopAIStrategy)? onInfoPressed;

  const CoopStrategyDrawer({
    super.key,
    required this.currentStrategy,
    required this.progress,
    required this.onStrategySelected,
    this.onClose,
    this.onInfoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BaseStrategyDrawer<CoopStrategyAdapter>(
      currentStrategy: CoopStrategyAdapter(currentStrategy),
      progress: CoopProgressAdapter(progress),
      onStrategySelected: (adapter) => onStrategySelected(adapter.strategy),
      onClose: onClose,
      config: DrawerConfig.coop,
      strategies: CoopAIStrategy.values.map((s) => CoopStrategyAdapter(s)).toList(),
      onInfoPressed: onInfoPressed != null 
          ? (adapter) => onInfoPressed!(adapter.strategy)
          : null,
    );
  }
}

/// Adapter per CoopAIStrategy per implementare GenericStrategy
class CoopStrategyAdapter implements GenericStrategy {
  final CoopAIStrategy strategy;
  
  CoopStrategyAdapter(this.strategy);
  
  @override
  String get name => strategy.name;
  
  @override
  String get displayName {
    final impl = CoopAIStrategyFactory.createStrategy(strategy);
    return impl.displayName;
  }
  
  @override
  AIDifficulty get difficulty {
    final impl = CoopAIStrategyFactory.createStrategy(strategy);
    return impl.difficulty;
  }
}

/// Adapter per CoopStrategyProgress per implementare GenericProgress
class CoopProgressAdapter implements GenericProgress {
  final CoopStrategyProgress progress;
  
  CoopProgressAdapter(this.progress);
  
  @override
  int getConsecutiveWins(String strategyName) {
    final strategy = CoopAIStrategy.values.firstWhere((s) => s.name == strategyName);
    return progress.getConsecutiveWins(strategy);
  }
  
  @override
  int getWinsNeeded(String strategyName) {
    final strategy = CoopAIStrategy.values.firstWhere((s) => s.name == strategyName);
    return progress.getWinsNeeded(strategy);
  }
  
  @override
  bool isDefeated(String strategyName) {
    final strategy = CoopAIStrategy.values.firstWhere((s) => s.name == strategyName);
    return progress.isDefeated(strategy);
  }
  
  @override
  String getDisplayName(GenericStrategy strategy) {
    final coopStrategy = CoopAIStrategy.values.firstWhere((s) => s.name == strategy.name);
    return progress.getDisplayName(coopStrategy);
  }
  
  @override
  Map<String, dynamic> getStats() {
    return progress.getStats();
  }
}