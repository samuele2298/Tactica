import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

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
                const SizedBox(height: 40),
                
                // Titolo dell'app
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'TACTICA',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Impara le Strategie Giocando',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 50),
                
                // Sottotitolo modalità
                Text(
                  'Scegli la tua modalità di gioco:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Lista delle modalità di gioco
                Expanded(
                  child: ListView(
                    children: const [
                      GameModeCard(
                        title: 'Classic Tic Tac Toe',
                        subtitle: 'Modalità Base',
                        description: 'Turni alternati, informazione completa.\nImpara l\'equilibrio perfetto di Nash.',
                        icon: Icons.grid_3x3,
                        color: Colors.blue,
                        route: '/classic',
                      ),
                      GameModeCard(
                        title: 'Simultaneous Tic Tac Toe',
                        subtitle: 'Modalità Tattica',
                        description: 'Entrambi scelgono segretamente.\nScopri le strategie miste e l\'imprevedibilità.',
                        icon: Icons.flash_on,
                        color: Colors.orange,
                        route: '/simultaneous',
                      ),
                      GameModeCard(
                        title: 'Co-op Tic Tac Toe',
                        subtitle: 'Modalità Cooperativa',
                        description: 'Tu + AI amica vs AI nemica.\nSperimenta fiducia e collaborazione.',
                        icon: Icons.group,
                        color: Colors.green,
                        route: '/coop',
                      ),
                      GameModeCard(
                        title: 'Nebel Tic Tac Toe',
                        subtitle: 'Modalità Strategica',
                        description: 'Alcune celle sono nascoste.\nDecidi con informazioni incomplete.',
                        icon: Icons.visibility_off,
                        color: Colors.purple,
                        route: '/nebel',
                      ),
                      GameModeCard(
                        title: 'Guess & Match',
                        subtitle: 'Modalità Sfida',
                        description: 'Prevedi le mosse dell\'AI.\nImpara pattern e adattamento strategico.',
                        icon: Icons.psychology,
                        color: Colors.red,
                        route: '/guess',
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Footer info
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Impara la Teoria dei Giochi in un modo interattivo e divertente!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
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
}

class GameModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  const GameModeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => context.go(route),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  color.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Icona
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: color,
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Contenuto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Freccia
                Icon(
                  Icons.arrow_forward_ios,
                  color: color.withOpacity(0.7),
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