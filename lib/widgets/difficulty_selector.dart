import 'package:flutter/material.dart';
import '../models/ai_difficulty.dart';

class DifficultySelector extends StatelessWidget {
  final AIDifficulty selectedDifficulty;
  final Function(AIDifficulty) onDifficultyChanged;
  final Color themeColor;

  const DifficultySelector({
    super.key,
    required this.selectedDifficulty,
    required this.onDifficultyChanged,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: themeColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: themeColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Difficoltà AI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: AIDifficulty.values.map((difficulty) {
              return _buildDifficultyOption(difficulty);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyOption(AIDifficulty difficulty) {
    final isSelected = selectedDifficulty == difficulty;
    Color optionColor;
    IconData icon;

    switch (difficulty) {
      case AIDifficulty.easy:
        optionColor = Colors.green;
        icon = Icons.sentiment_satisfied;
        break;
      case AIDifficulty.medium:
        optionColor = Colors.orange;
        icon = Icons.sentiment_neutral;
        break;
      case AIDifficulty.hard:
        optionColor = Colors.red;
        icon = Icons.sentiment_very_dissatisfied;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onDifficultyChanged(difficulty),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? optionColor.withOpacity(0.2) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected 
                  ? optionColor 
                  : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: optionColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      difficulty.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      difficulty.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: optionColor,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}