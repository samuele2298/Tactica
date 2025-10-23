import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_difficulty.dart';
import '../providers/global_progress_provider.dart';

/// Configurazione per personalizzare il drawer per ogni modalità
class DrawerConfig {
  final String title;
  final IconData headerIcon;
  final List<Color> gradientColors;
  final Color accentColor;
  final String gameMode;
  
  const DrawerConfig({
    required this.title,
    required this.headerIcon,
    required this.gradientColors,
    required this.accentColor,
    required this.gameMode,
  });
  
  // Preset configurazioni per modalità
  static const classic = DrawerConfig(
    title: 'Strategia AI',
    headerIcon: Icons.psychology,
    gradientColors: [Color(0xFF1976D2), Color(0xFF7B1FA2)], // blue to purple
    accentColor: Color(0xFF1976D2),
    gameMode: 'classic',
  );
  
  static const simultaneous = DrawerConfig(
    title: 'Strategia Simultanea',
    headerIcon: Icons.flash_on,
    gradientColors: [Color(0xFFFF9800), Color(0xFFFF5722)], // orange to deep orange
    accentColor: Color(0xFFFF9800),
    gameMode: 'simultaneous',
  );
  
  static const coop = DrawerConfig(
    title: 'Strategia Cooperativa',
    headerIcon: Icons.group,
    gradientColors: [Color(0xFF4CAF50), Color(0xFF8BC34A)], // green to light green
    accentColor: Color(0xFF4CAF50),
    gameMode: 'coop',
  );
  
  static const nebel = DrawerConfig(
    title: 'Strategia Nebel',
    headerIcon: Icons.visibility_off,
    gradientColors: [Color(0xFF7B1FA2), Color(0xFF4A148C)], // purple to dark purple
    accentColor: Color(0xFF7B1FA2),
    gameMode: 'nebel',
  );
  
  static const guess = DrawerConfig(
    title: 'Strategia Guess',
    headerIcon: Icons.casino,
    gradientColors: [Color(0xFFFF9800), Color(0xFFE65100)], // orange to deep orange
    accentColor: Color(0xFFFF9800),
    gameMode: 'guess',
  );
}

/// Interfaccia per oggetti strategia generici
abstract class GenericStrategy {
  String get name;
  String get displayName;
  AIDifficulty get difficulty;
}

/// Interfaccia per progress tracking generico 
abstract class GenericProgress {
  int getConsecutiveWins(String strategyName);
  int getWinsNeeded(String strategyName);
  bool isDefeated(String strategyName);
  String getDisplayName(GenericStrategy strategy);
  Map<String, dynamic> getStats();
}

/// Widget drawer base unificato per tutte le modalità
class BaseStrategyDrawer<T extends GenericStrategy> extends ConsumerWidget {
  final T currentStrategy;
  final GenericProgress progress;
  final Function(T) onStrategySelected;
  final VoidCallback? onClose;
  final DrawerConfig config;
  final List<T> strategies;
  final Function(T)? onInfoPressed; // Nuovo: pulsante info per strategie sconfitte

  const BaseStrategyDrawer({
    Key? key,
    required this.currentStrategy,
    required this.progress,
    required this.onStrategySelected,
    required this.config,
    required this.strategies,
    this.onClose,
    this.onInfoPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Column(
        children: [
          // Header del drawer - altezza fissa
          SizedBox(
            height: 120,
            child: _buildHeader(),
          ),
          
          // Statistiche progresso (solo se implementate) - altezza fissa
          if (_shouldShowProgress()) 
            SizedBox(
              height: 80,
              child: _buildProgressHeader(),
            ),
          
          // Lista delle strategie - occupa lo spazio rimanente
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDifficultySection('Facile', AIDifficulty.easy, Colors.green, ref),
                const SizedBox(height: 16),
                _buildDifficultySection('Medio', AIDifficulty.medium, Colors.orange, ref),
                const SizedBox(height: 16),
                _buildDifficultySection('Difficile', AIDifficulty.hard, Colors.red, ref),
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
          colors: config.gradientColors,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                config.headerIcon,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  config.title,
                  style: const TextStyle(
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
    );
  }
  
  bool _shouldShowProgress() {
    try {
      progress.getStats();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Widget _buildProgressHeader() {
    final stats = progress.getStats();
    final overallProgress = (stats['overallProgress'] as double?) ?? 0.0;
    final defeatedCount = (stats['defeatedCount'] as int?) ?? 0;
    final totalStrategies = (stats['totalStrategies'] as int?) ?? strategies.length;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: config.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.accentColor.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Progresso: $defeatedCount/$totalStrategies',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: config.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySection(String title, AIDifficulty difficulty, Color color, WidgetRef ref) {
    final strategiesForDifficulty = strategies.where((s) => s.difficulty == difficulty).toList();
    final globalProgress = ref.read(globalProgressProvider.notifier);
    final isUnlocked = globalProgress.isDifficultyUnlocked(difficulty);
    
    if (strategiesForDifficulty.isEmpty) {
      return Container(); // Non mostrare sezioni vuote
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titolo difficoltà
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isUnlocked ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isUnlocked ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                isUnlocked ? _getDifficultyIcon(difficulty) : Icons.lock,
                color: isUnlocked ? color : Colors.grey.shade500,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isUnlocked ? title : '$title (Bloccato)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? color : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Strategie per questa difficoltà
        if (isUnlocked)
          ...strategiesForDifficulty.map((strategy) => _buildStrategyTile(strategy, color, ref))
        else
          _buildLockedMessage(difficulty),
      ],
    );
  }

  Widget _buildLockedMessage(AIDifficulty difficulty) {
    String message;
    switch (difficulty) {
      case AIDifficulty.easy:
        message = 'Sempre disponibile';
        break;
      case AIDifficulty.medium:
        message = 'Sconfiggi 2 strategie AI su Facile per sbloccare';
        break;
      case AIDifficulty.hard:
        message = 'Sconfiggi 2 strategie AI su Medio per sbloccare';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyTile(T strategy, Color themeColor, WidgetRef ref) {
    final isSelected = strategy.name == currentStrategy.name;
    final isDefeated = progress.isDefeated(strategy.name);
    final consecutiveWins = progress.getConsecutiveWins(strategy.name);
    final winsNeeded = progress.getWinsNeeded(strategy.name);
    
    // Nome da mostrare: usa il progress per determinare il nome
    final displayName = progress.getDisplayName(strategy);
    
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
        
        trailing: _buildTrailingWidget(strategy, isDefeated, themeColor),
            
        onTap: () => onStrategySelected(strategy),
      ),
    );
  }
  
  Widget _buildTrailingWidget(T strategy, bool isDefeated, Color themeColor) {
    if (isDefeated) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsante info per strategie sconfitte
          if (onInfoPressed != null)
            IconButton(
              icon: Icon(Icons.info_outline, color: themeColor, size: 18),
              onPressed: () => onInfoPressed!(strategy),
              tooltip: 'Info Strategia',
            ),
          Icon(Icons.check_circle, color: themeColor, size: 20),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStrategyIcon(T strategy, bool isDefeated, Color themeColor) {
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
        isDefeated ? Icons.star : _getStrategyIcon(),
        color: isDefeated ? themeColor : Colors.grey.shade600,
        size: 18,
      ),
    );
  }
  
  IconData _getStrategyIcon() {
    switch (config.gameMode) {
      case 'classic':
        return Icons.smart_toy;
      case 'simultaneous':
        return Icons.flash_on;
      case 'coop':
        return Icons.group_work;
      default:
        return Icons.smart_toy;
    }
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

    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: wins / needed,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$wins/$needed',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
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