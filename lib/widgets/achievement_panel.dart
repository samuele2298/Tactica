import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/global_progress_provider.dart';
import '../models/ai_difficulty.dart';

/// Pannello degli achievement militari
class AchievementPanel extends ConsumerWidget {
  const AchievementPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalState = ref.watch(globalProgressProvider);
    final notifier = ref.read(globalProgressProvider.notifier);
    final stats = notifier.getGeneralStats();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.green.shade100,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.military_tech,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COMANDO GENERALE',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      Text(
                        'Rapporto Achievement',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Stato generale
            _buildGeneralStatus(globalState, stats),
            
            const SizedBox(height: 20),
            
            // Lista achievement
            Expanded(
              child: _buildAchievementsList(globalState, notifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralStatus(GlobalPlayerState state, Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Rank e Score
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.yellow,
                      size: 30,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.currentRank,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Grado',
                      style: TextStyle(
                        color: Colors.green.shade200,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Icon(
                      Icons.score,
                      color: Colors.orange,
                      size: 30,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.totalScore}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Punteggio',
                      style: TextStyle(
                        color: Colors.green.shade200,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Icon(
                      _getDifficultyIcon(state.unlockedDifficulty),
                      color: _getDifficultyColor(state.unlockedDifficulty),
                      size: 30,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDifficultyName(state.unlockedDifficulty),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Max Livello',
                      style: TextStyle(
                        color: Colors.green.shade200,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Medaglie
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMedalStat('Bronzo', stats['bronzeMedals'], Colors.orange.shade700),
              _buildMedalStat('Argento', stats['silverMedals'], Colors.grey.shade400),
              _buildMedalStat('Oro', stats['goldMedals'], Colors.yellow.shade700),
              _buildMedalStat('Platino', stats['platinumMedals'], Colors.grey.shade300),
              _buildMedalStat('Diamante', stats['diamondMedals'], Colors.cyan),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedalStat(String name, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            color: Colors.green.shade200,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsList(GlobalPlayerState state, GlobalProgressNotifier notifier) {
    final achievements = state.achievements.values.toList();
    achievements.sort((a, b) => b.earnedAt.compareTo(a.earnedAt)); // Più recenti prima

    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.military_tech,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nessun Achievement',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Inizia a giocare per guadagnare medaglie!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementTile(achievement);
      },
    );
  }

  Widget _buildAchievementTile(Achievement achievement) {
    final medalColor = _getMedalColor(achievement.medal);
    final difficultyColor = _getDifficultyColor(achievement.difficulty);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: medalColor.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: medalColor.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Medaglia
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: medalColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: medalColor.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.military_tech,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      achievement.strategyName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: difficultyColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getDifficultyName(achievement.difficulty),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Modalità: ${_getGameModeName(achievement.gameMode)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${achievement.victoriesCount} vittorie',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMedalColor(MedalType medal) {
    switch (medal) {
      case MedalType.bronze:
        return Colors.orange.shade700;
      case MedalType.silver:
        return Colors.grey.shade400;
      case MedalType.gold:
        return Colors.yellow.shade700;
      case MedalType.platinum:
        return Colors.grey.shade300;
      case MedalType.diamond:
        return Colors.cyan;
    }
  }

  Color _getDifficultyColor(AIDifficulty difficulty) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return Colors.green;
      case AIDifficulty.medium:
        return Colors.orange;
      case AIDifficulty.hard:
        return Colors.red;
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

  String _getDifficultyName(AIDifficulty difficulty) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return 'Facile';
      case AIDifficulty.medium:
        return 'Medio';
      case AIDifficulty.hard:
        return 'Difficile';
    }
  }

  String _getGameModeName(String gameMode) {
    switch (gameMode) {
      case 'classic':
        return 'Classic';
      case 'coop':
        return 'Co-op';
      case 'nebel':
        return 'Nebel';
      case 'guess':
        return 'Guess';
      case 'simultaneous':
        return 'Simultaneous';
      default:
        return gameMode;
    }
  }
}