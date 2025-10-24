import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/nebel_strategy_progress.dart';
import '../strategies/nebel/nebel_ai_strategy.dart';
import '../widgets/base_strategy_drawer.dart';

/// Implementazione del drawer per la modalità Nebel (fog of war)
class NebelStrategyDrawer extends StatelessWidget {
  final NebelAIStrategy currentStrategy;
  final NebelStrategyProgress progress;
  final Function(NebelAIStrategy) onStrategySelected;
  final VoidCallback? onClose;
  final Function(NebelAIStrategy)? onInfoPressed;

  const NebelStrategyDrawer({
    Key? key,
    required this.currentStrategy,
    required this.progress,
    required this.onStrategySelected,
    this.onClose,
    this.onInfoPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseStrategyDrawer<NebelStrategyAdapter>(
      currentStrategy: NebelStrategyAdapter(currentStrategy),
      progress: NebelProgressAdapter(progress),
      onStrategySelected: (adapter) => onStrategySelected(adapter.strategy),
      onClose: onClose,
      config: DrawerConfig.nebel,
      strategies: NebelAIStrategy.values.map((s) => NebelStrategyAdapter(s)).toList(),
      onInfoPressed: onInfoPressed != null 
          ? (adapter) => onInfoPressed!(adapter.strategy)
          : null,
    );
  }
}

/// Adapter per NebelAIStrategy per implementare GenericStrategy
class NebelStrategyAdapter implements GenericStrategy {
  final NebelAIStrategy strategy;
  
  NebelStrategyAdapter(this.strategy);
  
  @override
  String get name => strategy.name;
  
  @override
  String get displayName {
    final impl = NebelAIStrategyFactory.createStrategy(strategy);
    return impl.displayName;
  }
  
  @override
  AIDifficulty get difficulty {
    final impl = NebelAIStrategyFactory.createStrategy(strategy);
    return impl.difficulty;
  }
}

/// Adapter per NebelStrategyProgress per implementare GenericProgress
class NebelProgressAdapter implements GenericProgress {
  final NebelStrategyProgress progress;
  
  NebelProgressAdapter(this.progress);
  
  @override
  int getConsecutiveWins(String strategyName) {
    final strategy = NebelAIStrategy.values.firstWhere((s) => s.name == strategyName);
    return progress.getConsecutiveWins(strategy);
  }
  
  @override
  int getWinsNeeded(String strategyName) {
    final strategy = NebelAIStrategy.values.firstWhere((s) => s.name == strategyName);
    return progress.getWinsNeeded(strategy);
  }
  
  @override
  bool isDefeated(String strategyName) {
    final strategy = NebelAIStrategy.values.firstWhere((s) => s.name == strategyName);
    return progress.isDefeated(strategy);
  }
  
  @override
  String getDisplayName(GenericStrategy strategy) {
    if (strategy is NebelStrategyAdapter) {
      return progress.getDisplayName(strategy.strategy);
    }
    return strategy.displayName;
  }
  
  @override
  Map<String, dynamic> getStats() {
    final stats = <String, dynamic>{};
    for (final strategy in NebelAIStrategy.values) {
      stats[strategy.name] = {
        'wins': progress.getConsecutiveWins(strategy),
        'defeated': progress.isDefeated(strategy),
      };
    }
    return stats;
  }
}

