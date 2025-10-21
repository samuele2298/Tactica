import 'package:flutter/material.dart';
import '../models/ai_difficulty.dart';

class StrategySelector extends StatefulWidget {
  final AIDifficulty selectedDifficulty;
  final AIStrategy? selectedStrategy;
  final Function(AIDifficulty) onDifficultyChanged;
  final Function(AIStrategy) onStrategyChanged;

  const StrategySelector({
    Key? key,
    required this.selectedDifficulty,
    this.selectedStrategy,
    required this.onDifficultyChanged,
    required this.onStrategyChanged,
  }) : super(key: key);

  @override
  State<StrategySelector> createState() => _StrategySelectorState();
}

class _StrategySelectorState extends State<StrategySelector> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seleziona Difficoltà AI',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 16),
          
          // Selezione Difficoltà
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: AIDifficulty.values.map((difficulty) {
              return _buildDifficultyOption(difficulty);
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Selezione Strategia Specifica
          Text(
            'Strategia Specifica',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          
          _buildStrategyOptions(),
        ],
      ),
    );
  }

  Widget _buildDifficultyOption(AIDifficulty difficulty) {
    final isSelected = difficulty == widget.selectedDifficulty;
    
    Color backgroundColor;
    Color textColor;
    String label;
    
    switch (difficulty) {
      case AIDifficulty.easy:
        backgroundColor = isSelected ? Colors.green : Colors.green.withOpacity(0.3);
        textColor = isSelected ? Colors.white : Colors.green[700]!;
        label = 'Facile';
        break;
      case AIDifficulty.medium:
        backgroundColor = isSelected ? Colors.orange : Colors.orange.withOpacity(0.3);
        textColor = isSelected ? Colors.white : Colors.orange[700]!;
        label = 'Medio';
        break;
      case AIDifficulty.hard:
        backgroundColor = isSelected ? Colors.red : Colors.red.withOpacity(0.3);
        textColor = isSelected ? Colors.white : Colors.red[700]!;
        label = 'Difficile';
        break;
    }

    return GestureDetector(
      onTap: () => widget.onDifficultyChanged(difficulty),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(25),
          border: isSelected ? null : Border.all(color: backgroundColor, width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildStrategyOptions() {
    final availableStrategies = widget.selectedDifficulty.strategies;
    
    return Column(
      children: availableStrategies.map((strategy) {
        return _buildStrategyCard(strategy);
      }).toList(),
    );
  }

  Widget _buildStrategyCard(AIStrategy strategy) {
    final isSelected = strategy == widget.selectedStrategy;
    
    return GestureDetector(
      onTap: () => widget.onStrategyChanged(strategy),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? Colors.deepPurple : Colors.grey[400],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    strategy.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.deepPurple : Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              strategy.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '💡 ${strategy.learningHint}',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}