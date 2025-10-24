import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/tacticafe_logo.dart';
import '../widgets/military_avatar.dart';
import '../widgets/achievement_panel.dart';
import '../widgets/game_mode_button.dart';
import '../providers/global_progress_provider.dart';
import '../models/enums.dart';

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
                
                // Lista delle modalità di gioco
                Expanded(
                  child: ListView(
                    children: [
                      GameModeButton(
                        title: 'Classica',
                        subtitle: 'Turni alternati, somma zero, equilibrio perfetto di Nash',
                        icon: Icons.grid_3x3,
                        color: Colors.blue,
                        route: '/classic',
                      ),
                      GameModeButton(
                        title: 'Co-op',
                        subtitle: 'Cooperazione vs competizione',
                        icon: Icons.group,
                        color: Colors.green,
                        route: '/coop',
                      ),
                      GameModeButton(
                        title: 'Nascosta',
                        subtitle: 'Informazioni incomplete, probabilità',
                        icon: Icons.visibility_off,
                        color: Colors.purple,
                        route: '/nebel',
                      ),
                      GameModeButton(
                        title: 'Simultanea',
                        subtitle: 'Bluff e strategie miste',
                        icon: Icons.flash_on,
                        color: Colors.orange,
                        route: '/simultaneous',
                      ),
                      GameModeButton(
                        title: 'Indovina',
                        subtitle: 'Riconoscimento di pattern e previsioni',
                        icon: Icons.psychology,
                        color: Colors.red,
                        route: '/guess',
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

