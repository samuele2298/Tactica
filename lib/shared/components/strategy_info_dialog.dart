/// Shared strategy information dialog
/// Provides consistent strategy info display across all game modes

import 'package:flutter/material.dart';
import '../../core/interfaces/game_interfaces.dart';

/// Shared dialog for displaying strategy information and counter-strategies
class StrategyInfoDialog extends StatelessWidget {
  final String strategyName;
  final IconData icon;
  final Color primaryColor;
  final List<String> strategies;
  final String statisticsText;

  const StrategyInfoDialog({
    super.key,
    required this.strategyName,
    required this.icon,
    required this.primaryColor,
    required this.strategies,
    required this.statisticsText,
  });

  /// Static method to show the dialog
  static void show({
    required BuildContext context,
    required String strategyName,
    required IconData icon,
    required Color primaryColor,
    required StrategyAdvice advice,
    required String statisticsText,
  }) {
    final strategies = advice.getMultipleCounterStrategies(strategyName);
    
    showDialog(
      context: context,
      builder: (context) => StrategyInfoDialog(
        strategyName: strategyName,
        icon: icon,
        primaryColor: primaryColor,
        strategies: strategies,
        statisticsText: statisticsText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Strategia: $strategyName',
              style: TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Consigli strategici:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            ...strategies.asMap().entries.map((entry) {
              final index = entry.key;
              final strategy = entry.value;
              return _buildStrategyItem(index, strategy);
            }),
            const SizedBox(height: 16),
            _buildStatisticsSection(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Chiudi',
            style: TextStyle(color: primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildStrategyItem(int index, String strategy) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              strategy,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Le tue statistiche con questa strategia:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(statisticsText),
        ],
      ),
    );
  }
}