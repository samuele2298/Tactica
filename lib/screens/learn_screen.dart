import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/learning_content.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
              Colors.orange.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.arrow_back, size: 30),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Teoria dei Giochi',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.school,
                      size: 40,
                      color: Colors.green.shade600,
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),

                // Introduzione
                Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          size: 50,
                          color: Colors.orange.shade600,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Impara i Concetti Fondamentali',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Scopri come le decisioni strategiche influenzano i risultati nei giochi e nella vita reale.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Moduli di apprendimento dinamici
                Expanded(
                  child: ListView.builder(
                    itemCount: LearningModules.modules.length,
                    itemBuilder: (context, index) {
                      final module = LearningModules.modules[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildModuleButton(context, module),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Pulsante torna al gioco
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/play'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow, size: 24),
                    label: const Text(
                      'Ora metti in pratica!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleButton(BuildContext context, LearningModule module) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.indigo.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: Colors.indigo,
            child: Icon(_getModuleIcon(module.iconData), color: Colors.white),
          ),
          title: Text(
            module.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            module.description,
            style: const TextStyle(fontSize: 12),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            context.go('/impara/modulo/${module.id}');
          },
        ),
      ),
    );
  }

  IconData _getModuleIcon(String iconName) {
    switch (iconName) {
      case 'psychology': return Icons.psychology;
      case 'balance': return Icons.balance;
      case 'trending_up': return Icons.trending_up;
      case 'center_focus_strong': return Icons.center_focus_strong;
      case 'repeat': return Icons.repeat;
      default: return Icons.school;
    }
  }
}