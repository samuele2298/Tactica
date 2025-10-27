import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/tacticafe_logo.dart';
import '../widgets/game_mode_button.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                const SizedBox(height: 40),
                
                // Header con avatar militare
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar militare
                    /* MilitaryAvatar(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const AchievementPanel(),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                     */
                    // Titolo dell'app
                    Expanded(
                      child: Column(
                        children: [
                          // Logo e titolo combinati
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo animato
                              TacticafeLogo.large(animated: true),
                              const SizedBox(width: 20),
                              // Titolo
                              Text(
                                'TACTICA',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          // Sottotitolo con gradiente che richiama il logo
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.blue.shade600,
                                Colors.purple.shade600,
                                Colors.orange.shade600,
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'Impara la Teoria dei Giochi giocando',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 70),
                
                // Le 3 sezioni principali del gioco
                Expanded(
                  child: ListView(
                    children: [
                      GameModeButton(
                        title: 'Gioca',
                        subtitle: 'Dilemma del Prigioniero - Sperimenta cooperazione vs tradimento',
                        icon: Icons.play_arrow,
                        color: Colors.blue,
                        route: '/play',
                      ),
                      const SizedBox(height: 10),
                      GameModeButton(
                        title: 'Impara',
                        subtitle: 'Teoria dei Giochi - Concetti fondamentali spiegati semplice',
                        icon: Icons.school,
                        color: Colors.green,
                        route: '/impara',
                      ),
                      const SizedBox(height: 10),
                      GameModeButton(
                        title: 'Classe',
                        subtitle: 'Per Docenti - Crea sessioni multiplayer per la tua classe',
                        icon: Icons.groups,
                        color: Colors.orange,
                        route: '/classroom',
                      ),
                    ],
                  ),
                ),
                              
              ],
            ),
          ),
        ),
      ),
    );
  }
}

