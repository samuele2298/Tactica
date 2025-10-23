import 'package:flutter/material.dart';
import '../models/ai_difficulty.dart';
import '../models/simultaneous_strategy_progress.dart';
import '../strategies/simultaneous/simultaneous_ai_strategy.dart';

class SimultaneousStrategyDrawer extends StatelessWidget {
  final SimultaneousAIStrategy currentStrategy;
  final SimultaneousStrategyProgress progress;
  final Function(SimultaneousAIStrategy) onStrategySelected;
  final VoidCallback? onClose;

  const SimultaneousStrategyDrawer({
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
                  Colors.orange.shade600,
                  Colors.deepOrange.shade600,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.flash_on,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Strategia Simultanea',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
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
          
          // Statistiche progresso
          _buildProgressHeader(),
          
          // Lista delle strategie
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDifficultySection('Semplice', AIDifficulty.easy, Colors.green),
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

  Widget _buildProgressHeader() {
    final stats = progress.getStats();
    final overallProgress = stats['overallProgress'] as double;
    final defeatedCount = stats['defeatedCount'] as int;
    final totalStrategies = stats['totalStrategies'] as int;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              const Text(
                'Progresso Globale',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Barra progresso
          LinearProgressIndicator(
            value: overallProgress,
            backgroundColor: Colors.orange.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '$defeatedCount / $totalStrategies strategie superate',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySection(String title, AIDifficulty difficulty, Color color) {
    final strategies = SimultaneousStrategyProgress.getStrategiesByDifficulty(difficulty);
    
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
              const Spacer(),
              _buildDifficultyProgress(strategies, color),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Strategie per questa difficoltà
        ...strategies.map((strategy) => _buildStrategyTile(strategy, color)),
      ],
    );
  }

  Widget _buildDifficultyProgress(List<SimultaneousAIStrategy> strategies, Color color) {
    final defeatedCount = strategies.where((s) => progress.isDefeated(s)).length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$defeatedCount/${strategies.length}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStrategyTile(SimultaneousAIStrategy strategy, Color themeColor) {
    final isSelected = strategy == currentStrategy;
    final isDefeated = progress.isDefeated(strategy);
    final consecutiveWins = progress.getConsecutiveWins(strategy);
    final winsNeeded = progress.getWinsNeeded(strategy);
    
    // Nome da mostrare: generico se non sconfitto, reale se sconfitto
    final displayName = progress.getDisplayName(strategy);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? Colors.orange.shade600 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        tileColor: isSelected 
            ? Colors.orange.shade50 
            : Colors.white,
        
        leading: _buildStrategyIcon(strategy, isDefeated, themeColor),
        
        title: Text(
          displayName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isDefeated ? Colors.orange.shade700 : Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        
        subtitle: _buildProgressIndicator(consecutiveWins, winsNeeded, isDefeated, themeColor),
        
        trailing: isDefeated 
            ? Icon(Icons.check_circle, color: Colors.orange.shade600, size: 20)
            : _buildStatusIcon(consecutiveWins),
            
        onTap: () => onStrategySelected(strategy),
      ),
    );
  }

  Widget _buildStrategyIcon(SimultaneousAIStrategy strategy, bool isDefeated, Color themeColor) {
    IconData iconData;
    Color iconColor;
    Color backgroundColor;
    
    if (isDefeated) {
      iconData = Icons.star;
      iconColor = Colors.orange.shade600;
      backgroundColor = Colors.orange.shade100;
    } else {
      iconData = Icons.flash_on;
      iconColor = Colors.grey.shade600;
      backgroundColor = Colors.grey.shade100;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDefeated ? Colors.orange.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 18,
      ),
    );
  }

  Widget? _buildStatusIcon(int wins) {
    if (wins == 0) return null;
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.trending_up,
        color: Colors.orange.shade600,
        size: 16,
      ),
    );
  }

  Widget _buildProgressIndicator(int wins, int needed, bool defeated, Color color) {
    if (defeated) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events,
            color: Colors.orange.shade600,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            'SUPERATO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade600,
            ),
          ),
        ],
      );
    }
    
    if (wins == 0) {
      return Text(
        'Non affrontato',
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade600,
        ),
      );
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Indicatori di progresso
        ...List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.only(right: 2),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: index < wins ? Colors.orange.shade600 : Colors.grey.shade300,
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
            color: Colors.orange.shade600,
          ),
        ),
      ],
    );
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