import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/guess_strategy_progress.dart';
import '../../strategies/guess/guess_ai_strategy.dart';
import '../../providers/guess_provider.dart';
import '../../models/ai_difficulty.dart';

/// Drawer delle strategie per Guess mode
class GuessStrategyDrawer extends ConsumerWidget {
  final Function(GuessAIStrategy)? onStrategySelected;
  final Function(GuessAIStrategy)? onInfoPressed;

  const GuessStrategyDrawer({
    super.key,
    this.onStrategySelected,
    this.onInfoPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStrategy = ref.watch(guessNotifierProvider.select((state) => state.currentStrategy));
    final strategyProgress = ref.watch(guessNotifierProvider.select((state) => state.strategyProgress));

    return Drawer(
      child: Column(
        children: [
          // Header del drawer - altezza fissa
          SizedBox(
            height: 120,
            child: _buildHeader(),
          ),
          
          // Lista delle strategie - occupa lo spazio rimanente
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDifficultySection('Facile', AIDifficulty.easy, Colors.green, currentStrategy, ref),
                const SizedBox(height: 16),
                _buildDifficultySection('Medio', AIDifficulty.medium, Colors.orange, currentStrategy, ref),
                const SizedBox(height: 16),
                _buildDifficultySection('Difficile', AIDifficulty.hard, Colors.red, currentStrategy, ref),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade700,
            Colors.orange.shade900,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(
                Icons.casino,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Strategie Guess',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultySection(String title, AIDifficulty difficulty, Color color, 
                                 GuessAIStrategy currentStrategy, WidgetRef ref) {
    final strategiesForDifficulty = GuessAIStrategy.values.where((s) {
      final impl = GuessAIStrategyFactory.createStrategy(s);
      return impl.difficulty == difficulty;
    }).toList();
    
    if (strategiesForDifficulty.isEmpty) {
      return Container(); // Non mostrare sezioni vuote
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ...strategiesForDifficulty.map((strategy) => _buildStrategyTile(strategy, color, currentStrategy, ref)),
      ],
    );
  }

  Widget _buildStrategyTile(GuessAIStrategy strategy, Color themeColor, GuessAIStrategy currentStrategy, WidgetRef ref) {
    final isSelected = strategy == currentStrategy;
    final impl = GuessAIStrategyFactory.createStrategy(strategy);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? themeColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        tileColor: isSelected 
            ? themeColor.withOpacity(0.1) 
            : Colors.white,
        
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: Icon(
            Icons.psychology,
            color: Colors.grey.shade600,
            size: 18,
          ),
        ),
        
        title: Text(
          impl.displayName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        
        subtitle: Text(
          impl.description,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
            
        onTap: () {
          if (onStrategySelected != null) {
            onStrategySelected!(strategy);
          } else {
            ref.read(guessNotifierProvider.notifier).changeStrategy(strategy);
          }
        },
      ),
    );
  }
}