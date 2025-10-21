import 'package:flutter/material.dart';
import '../models/ai_difficulty.dart';
import '../models/strategy_progress.dart';

class StrategyDrawer extends StatelessWidget {
  final AIStrategy currentStrategy;
  final StrategyProgress progress;
  final Function(AIStrategy) onStrategySelected;
  final VoidCallback? onClose;

  const StrategyDrawer({
    Key? key,
    required this.currentStrategy,
    required this.progress,
    required this.onStrategySelected,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header del drawer
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade600,
                  Colors.purple.shade600,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Strategia AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (onClose != null)
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Lista delle strategie
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDifficultySection('Facile', AIDifficulty.easy, Colors.green),
                const SizedBox(height: 16),
                _buildDifficultySection('Medio', AIDifficulty.medium, Colors.orange),
                const SizedBox(height: 16),
                _buildDifficultySection('Difficile', AIDifficulty.hard, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySection(String title, AIDifficulty difficulty, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titolo difficoltà
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                _getDifficultyIcon(difficulty),
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Strategie per questa difficoltà
        ...difficulty.strategies.map((strategy) => _buildStrategyTile(strategy, color)),
      ],
    );
  }

  Widget _buildStrategyTile(AIStrategy strategy, Color themeColor) {
    final isSelected = strategy == currentStrategy;
    final isDefeated = progress.isDefeated(strategy.name);
    final consecutiveWins = progress.getConsecutiveWins(strategy.name);
    final winsNeeded = progress.getWinsNeeded(strategy.name);
    
    // Nome da mostrare: generico se non sconfitto, reale se sconfitto
    final displayName = isDefeated ? strategy.displayName : _getGenericName(strategy);
    
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
        
        leading: _buildStrategyIcon(strategy, isDefeated, themeColor),
        
        title: Text(
          displayName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isDefeated ? themeColor : Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        
        subtitle: _buildProgressIndicator(consecutiveWins, winsNeeded, isDefeated, themeColor),
        
        trailing: isDefeated 
            ? Icon(Icons.check_circle, color: themeColor, size: 20)
            : null,
            
        onTap: () => onStrategySelected(strategy),
      ),
    );
  }

  Widget _buildStrategyIcon(AIStrategy strategy, bool isDefeated, Color themeColor) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDefeated ? themeColor.withOpacity(0.2) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDefeated ? themeColor : Colors.grey.shade300,
        ),
      ),
      child: Icon(
        isDefeated ? Icons.star : Icons.smart_toy,
        color: isDefeated ? themeColor : Colors.grey.shade600,
        size: 18,
      ),
    );
  }

  Widget _buildProgressIndicator(int wins, int needed, bool defeated, Color color) {
    if (defeated) {
      return Text(
        'SUPERATO',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      );
    }
    
    if (wins == 0) {
      return Text(
        'Nessuna vittoria',
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade600,
        ),
      );
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.only(right: 2),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: index < wins ? color : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
        const SizedBox(width: 4),
        Text(
          '$wins/3',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getGenericName(AIStrategy strategy) {
    switch (strategy.difficulty) {
      case AIDifficulty.easy:
        final index = AIDifficulty.easy.strategies.indexOf(strategy) + 1;
        return 'Strategia $index';
      case AIDifficulty.medium:
        final index = AIDifficulty.medium.strategies.indexOf(strategy) + 1;
        return 'Strategia $index';
      case AIDifficulty.hard:
        final index = AIDifficulty.hard.strategies.indexOf(strategy) + 1;
        return 'Strategia $index';
    }
  }

  IconData _getDifficultyIcon(AIDifficulty difficulty) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return Icons.sentiment_satisfied;
      case AIDifficulty.medium:
        return Icons.sentiment_neutral;
      case AIDifficulty.hard:
        return Icons.sentiment_very_dissatisfied;
    }
  }
}