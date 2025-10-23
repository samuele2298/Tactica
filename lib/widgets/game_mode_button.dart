import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/global_progress_provider.dart';
import '../models/ai_difficulty.dart';

/// Widget che mostra il pulsante di una modalità di gioco - sempre accessibile
class GameModeButton extends ConsumerWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const GameModeButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalProgress = ref.watch(globalProgressProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.go(route);
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Row(
              children: [
                // Icona principale
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: color,
                      size: 30,
                    ),
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Testo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Indicatori difficoltà e freccia
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDifficultyIndicators(ref),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: color,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyIndicators(WidgetRef ref) {
    final notifier = ref.read(globalProgressProvider.notifier);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDifficultyDot(AIDifficulty.easy, Colors.green, true),
        const SizedBox(width: 4),
        _buildDifficultyDot(AIDifficulty.medium, Colors.orange, notifier.isDifficultyUnlocked(AIDifficulty.medium)),
        const SizedBox(width: 4),
        _buildDifficultyDot(AIDifficulty.hard, Colors.red, notifier.isDifficultyUnlocked(AIDifficulty.hard)),
      ],
    );
  }

  Widget _buildDifficultyDot(AIDifficulty difficulty, Color color, bool unlocked) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: unlocked ? color : Colors.grey.shade300,
        shape: BoxShape.circle,
        border: unlocked ? null : Border.all(color: Colors.grey.shade400),
      ),
      child: unlocked ? null : Icon(
        Icons.lock,
        size: 8,
        color: Colors.grey.shade500,
      ),
    );
  }
}

