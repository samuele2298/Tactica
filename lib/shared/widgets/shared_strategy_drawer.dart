/// Shared base strategy drawer component
/// Provides consistent UI and functionality across all game modes

import 'package:flutter/material.dart';
import '../../core/interfaces/game_interfaces.dart';
import '../../core/constants/game_constants.dart';

/// Configuration for strategy drawer appearance
class StrategyDrawerConfig implements DrawerConfiguration {
  @override
  final String title;
  
  @override
  final IconData headerIcon;
  
  @override
  final Color primaryColor;
  
  @override
  final Color accentColor;
  
  @override
  final String gameMode;
  
  final List<Color> gradientColors;

  const StrategyDrawerConfig({
    required this.title,
    required this.headerIcon,
    required this.primaryColor,
    required this.accentColor,
    required this.gameMode,
    required this.gradientColors,
  });

  /// Factory constructors for different game modes
  factory StrategyDrawerConfig.forGameMode(String mode) {
    final colors = GameModeColors.gradients[mode] ?? GameModeColors.gradients['classic']!;
    final primaryColor = GameModeColors.primaryColors[mode] ?? GameModeColors.primaryColors['classic']!;
    final icon = GameModeColors.icons[mode] ?? GameModeColors.icons['classic']!;
    
    String title;
    switch (mode) {
      case 'classic':
        title = 'Strategie Classic';
        break;
      case 'simultaneous':
        title = 'Strategie Simultaneous';
        break;
      case 'coop':
        title = 'Strategie Cooperative';
        break;
      case 'nebel':
        title = 'Strategie Nebel';
        break;
      case 'guess':
        title = 'Strategie Guess';
        break;
      default:
        title = 'Strategie';
    }
    
    return StrategyDrawerConfig(
      title: title,
      headerIcon: icon,
      primaryColor: primaryColor,
      accentColor: primaryColor.withOpacity(0.1),
      gameMode: mode,
      gradientColors: colors,
    );
  }
}

/// Generic strategy drawer that can be used by all game modes
class SharedStrategyDrawer<T extends GameStrategy> extends StatelessWidget {
  final StrategyDrawerConfig config;
  final List<T> strategies;
  final T currentStrategy;
  final GameProgress progress;
  final void Function(T strategy) onStrategySelected;
  final void Function(T strategy) onInfoPressed;

  const SharedStrategyDrawer({
    super.key,
    required this.config,
    required this.strategies,
    required this.currentStrategy,
    required this.progress,
    required this.onStrategySelected,
    required this.onInfoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: config.gradientColors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStrategyList(),
              _buildProgressInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(config.headerIcon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              config.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyList() {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: strategies.length,
          itemBuilder: (context, index) {
            final strategy = strategies[index];
            final isSelected = strategy.name == currentStrategy.name;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: isSelected ? 8 : 2,
              color: isSelected ? config.accentColor : null,
              child: ListTile(
                leading: Icon(
                  Icons.psychology,
                  color: isSelected ? config.primaryColor : Colors.grey,
                ),
                title: Text(
                  strategy.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? config.primaryColor : null,
                  ),
                ),
                subtitle: Text(strategy.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(strategy.difficulty),
                      backgroundColor: _getDifficultyColor(strategy.difficulty),
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () => onInfoPressed(strategy),
                    ),
                  ],
                ),
                onTap: () {
                  onStrategySelected(strategy);
                  Navigator.of(context).pop();
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'Statistiche',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: config.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(progress.detailedStats),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'facile':
      case 'easy':
        return Colors.green;
      case 'medio':
      case 'medium':
        return Colors.orange;
      case 'difficile':
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}