import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../providers/my_progress.dart';

/// JSON-like config per tutte le modalità
const Map<String, Map<String, dynamic>> strategyDrawerConfig = {
  'classic': {
    'title': 'Modalità Classica',
    'icon': Icons.psychology,
    'gradientColors': [Color(0xFF1976D2), Color(0xFF7B1FA2)],
    'accentColor': Color(0xFF1976D2),
  },
  'simultaneous': {
    'title': 'Modalità Simultanea',
    'icon': Icons.flash_on,
    'gradientColors': [Color(0xFFFF9800), Color(0xFFFF5722)],
    'accentColor': Color(0xFFFF9800),
  },
  'coop': {
    'title': 'Modalità Cooperativa',
    'icon': Icons.group,
    'gradientColors': [Color(0xFF4CAF50), Color(0xFF8BC34A)],
    'accentColor': Color(0xFF4CAF50),
  },
  'nebel': {
    'title': 'Modalità Nascosta',
    'icon': Icons.visibility_off,
    'gradientColors': [Color(0xFF7B1FA2), Color(0xFF4A148C)],
    'accentColor': Color(0xFF7B1FA2),
  },
  'guess': {
    'title': 'Modalità Indovina',
    'icon': Icons.casino,
    'gradientColors': [Color(0xFFFF9800), Color(0xFFE65100)],
    'accentColor': Color(0xFFFF9800),
  },
};


class StrategyDrawer extends ConsumerWidget {
  final String gameMode;
  final AIStrategy currentStrategy;
  final Function(AIStrategy) onStrategySelected;
  final VoidCallback? onClose;
  final Function(AIStrategy)? onInfoPressed;

  const StrategyDrawer({
    super.key,
    required this.gameMode,
    required this.currentStrategy,
    required this.onStrategySelected,
    this.onClose,
    this.onInfoPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = strategyDrawerConfig[gameMode]!;

    // Filtra strategie per modalità
    final strategies = AIStrategy.values.where((s) => s.mode.name == gameMode).toList();

    // Raggruppa strategie per difficoltà
    final easyStrategies = strategies.where((s) => s.difficulty == AIDifficulty.easy).toList();
    final mediumStrategies = strategies.where((s) => s.difficulty == AIDifficulty.medium).toList();
    final hardStrategies = strategies.where((s) => s.difficulty == AIDifficulty.hard).toList();

    final progressNotifier = ref.watch(globalProgressProvider.notifier);

    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: List<Color>.from(config['gradientColors']),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(config['icon'], color: Colors.white, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Batti le strategie per avanzare',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Lista strategie divise per difficoltà
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDifficultySection(
                  context,
                  title: 'Easy',
                  strategies: easyStrategies,
                  config: config,
                  progressNotifier: progressNotifier,
                  onStrategySelected: onStrategySelected,
                  onInfoPressed: onInfoPressed,
                ),
                _buildDifficultySection(
                  context,
                  title: 'Medium',
                  strategies: mediumStrategies,
                  config: config,
                  progressNotifier: progressNotifier,
                  onStrategySelected: onStrategySelected,
                  onInfoPressed: onInfoPressed,
                  requiredWins: 3, // Devi vincere 3 su Easy per sbloccare
                ),
                _buildDifficultySection(
                  context,
                  title: 'Hard',
                  strategies: hardStrategies,
                  config: config,
                  progressNotifier: progressNotifier,
                  onStrategySelected: onStrategySelected,
                  onInfoPressed: onInfoPressed,
                  requiredWins: 3, // Devi vincere 3 su Medium per sbloccare
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySection(
    BuildContext context, {
    required String title,
    required List<AIStrategy> strategies,
    required Map<String, dynamic> config,
    required dynamic progressNotifier,
    Function(AIStrategy)? onStrategySelected,
    Function(AIStrategy)? onInfoPressed,
    int requiredWins = 0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: config['accentColor'],
          ),
        ),
        const SizedBox(height: 8),
        ...strategies.map((strategy) {
          final progress = progressNotifier.getProgress(strategy);
          final consecutiveWins = progress.consecutiveWins;
          final isDefeated = progress.isDefeated;

          // Blocca Medium/Hard se non hai completato la difficoltà precedente
          final isLocked = consecutiveWins < requiredWins;

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            color: isLocked ? Colors.grey.shade200 : Colors.white,
            child: ListTile(
              enabled: !isLocked,
              title: Text(strategy.displayName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: (consecutiveWins / 3).clamp(0.0, 1.0),
                    color: config['accentColor'],
                    backgroundColor: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strategy.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isLocked ? Colors.grey : Colors.black87,
                    ),
                  ),
                ],
              ),
              trailing: isDefeated
                  ? IconButton(
                      icon: Icon(Icons.info_outline, color: config['accentColor']),
                      onPressed: () => onInfoPressed?.call(strategy),
                    )
                  : null,
              onTap: isLocked ? null : () => onStrategySelected?.call(strategy),
            ),
          );
        }).toList(),
        const SizedBox(height: 12),
      ],
    );
  }
}