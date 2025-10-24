import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/simultaneous_strategy_progress.dart';
import '../strategies/simultaneous/simultaneous_ai_strategy.dart';
import '../widgets/base_strategy_drawer.dart';

/// Implementazione del drawer per la modalità Simultaneous
class SimultaneousStrategyDrawer extends StatelessWidget {
  final SimultaneousAIStrategy currentStrategy;
  final SimultaneousStrategyProgress progress;
  final Function(SimultaneousAIStrategy) onStrategySelected;
  final VoidCallback? onClose;
  final Function(SimultaneousAIStrategy)? onInfoPressed;

  const SimultaneousStrategyDrawer({
    Key? key,
    required this.currentStrategy,
    required this.progress,
    required this.onStrategySelected,
    this.onClose,
    this.onInfoPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseStrategyDrawer<SimultaneousStrategyAdapter>(
      currentStrategy: SimultaneousStrategyAdapter(currentStrategy),
      progress: SimultaneousProgressAdapter(progress),
      onStrategySelected: (adapter) => onStrategySelected(adapter.strategy),
      onClose: onClose,
      config: DrawerConfig.simultaneous,
      strategies: SimultaneousAIStrategy.values.map((s) => SimultaneousStrategyAdapter(s)).toList(),
      onInfoPressed: onInfoPressed != null 
          ? (adapter) => onInfoPressed!(adapter.strategy)
          : null,
    );
  }
}

/// Adapter per SimultaneousAIStrategy per implementare GenericStrategy
class SimultaneousStrategyAdapter implements GenericStrategy {
  final SimultaneousAIStrategy strategy;
  
  SimultaneousStrategyAdapter(this.strategy);
  
  @override
  String get name => strategy.name;
  
  @override
  String get displayName {
    final impl = SimultaneousAIStrategyFactory.createStrategy(strategy);
    return impl.displayName;
  }
  
  @override
  AIDifficulty get difficulty {
    final impl = SimultaneousAIStrategyFactory.createStrategy(strategy);
    return impl.difficulty;
  }
}

/// Adapter per SimultaneousStrategyProgress per implementare GenericProgress
class SimultaneousProgressAdapter implements GenericProgress {
  final SimultaneousStrategyProgress progress;
  
  SimultaneousProgressAdapter(this.progress);
  
  @override
  int getConsecutiveWins(String strategyName) {
    final strategy = SimultaneousAIStrategy.values.firstWhere((s) => s.name == strategyName);
    return progress.getConsecutiveWins(strategy);
  }
  
  @override
  int getWinsNeeded(String strategyName) {
    final strategy = SimultaneousAIStrategy.values.firstWhere((s) => s.name == strategyName);
    return progress.getWinsNeeded(strategy);
  }
  
  @override
  bool isDefeated(String strategyName) {
    final strategy = SimultaneousAIStrategy.values.firstWhere((s) => s.name == strategyName);
    return progress.isDefeated(strategy);
  }
  
  @override
  String getDisplayName(GenericStrategy strategy) {
    final simStrategy = SimultaneousAIStrategy.values.firstWhere((s) => s.name == strategy.name);
    return progress.getDisplayName(simStrategy);
  }
  
  @override
  Map<String, dynamic> getStats() {
    return progress.getStats();
  }
}