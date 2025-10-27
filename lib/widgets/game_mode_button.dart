import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
              border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
            ),
            child: Row(
              children: [
                // Icona principale
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
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
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
