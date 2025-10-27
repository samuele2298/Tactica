import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/game_mode_button.dart';

class ClassroomScreen extends StatelessWidget {
  const ClassroomScreen({super.key});

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
                        'Sezione Classe',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.groups,
                      size: 40,
                      color: Colors.orange.shade600,
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),

                // Introduzione per docenti
                Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.school,
                          size: 50,
                          color: Colors.orange.shade600,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Per Docenti',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Crea sessioni multiplayer per la tua classe e monitora i risultati in tempo reale.',
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

                const SizedBox(height: 40),

                // Opzioni per docenti
                Expanded(
                  child: Column(
                    children: [
                      // Crea sessione
                      GameModeButton(
                        title: 'Crea Sessione',
                        subtitle: 'Crea una nuova lobby per i tuoi studenti',
                        icon: Icons.add_circle,
                        color: Colors.green,
                        route: '/classroom/create',
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Divider con "oppure"
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade400)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'oppure',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade400)),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Entra come studente
                      GameModeButton(
                        title: 'Entra come Studente',
                        subtitle: 'Partecipa a una sessione esistente',
                        icon: Icons.login,
                        color: Colors.blue,
                        route: '/classroom/join',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Info tecnica
                Card(
                  elevation: 4,
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade600,
                          size: 30,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Funzionalità Multiplayer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '• Crea lobby con codice univoco\n• Monitora risultati in tempo reale\n• Sessioni automatiche con timeout\n• Statistiche aggregate per la classe',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade600,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
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