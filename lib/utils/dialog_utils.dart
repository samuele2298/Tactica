import 'package:flutter/material.dart';

/// Utilità per creare dialog di gioco standardizzati
class DialogUtils {
  
  /// Crea un dialog di fine partita generico
  static void showGameOverDialog({
    required BuildContext context,
    required String title,
    required String message,
    required Color themeColor,
    required VoidCallback onReplay,
    String replayButtonText = 'Rigioca',
    IconData titleIcon = Icons.emoji_events,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(titleIcon, color: themeColor, size: 28),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: themeColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onReplay();
                },
                icon: const Icon(Icons.refresh),
                label: Text(replayButtonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Crea un dialog di rivelazione strategia generico
  static void showStrategyRevealDialog({
    required BuildContext context,
    required String strategyName,
    required String strategyDescription, 
    required String counterStrategy,
    required Color themeColor,
    required VoidCallback onReplay,
    required VoidCallback onChangeStrategy,
    String gameMode = 'AI',
    List<String>? multipleCounterStrategies, // Nuovo parametro opzionale
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  themeColor.withOpacity(0.1),
                  themeColor.withOpacity(0.05),
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                // Header con icona vittoria
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Titolo
                Text(
                  '🎉 STRATEGIA SCONFITTA!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: themeColor.withOpacity(0.9),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Messaggio principale
                Text(
                  'Complimenti! Hai battuto 3 volte consecutive questa AI!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Rivelazione strategia AI
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: themeColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.psychology, color: themeColor.withOpacity(0.8)),
                          const SizedBox(width: 8),
                          const Text(
                            'Strategia AI Rivelata:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strategyName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeColor.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strategyDescription,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Rivelazione counter-strategia (supporto multiple)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.shield, color: Colors.green.shade600),
                          const SizedBox(width: 8),
                          Text(
                            multipleCounterStrategies != null && multipleCounterStrategies.isNotEmpty 
                                ? 'Le Tue Counter-Strategie:' 
                                : 'La Tua Counter-Strategia:',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Mostra multiple counter-strategie se presenti
                      if (multipleCounterStrategies != null && multipleCounterStrategies.isNotEmpty)
                        ...multipleCounterStrategies.asMap().entries.map((entry) {
                          final index = entry.key;
                          final counterStr = entry.value;
                          return Container(
                            margin: EdgeInsets.only(bottom: index < multipleCounterStrategies!.length - 1 ? 12 : 0),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade300, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade600,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _extractCounterTitle(counterStr),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _extractCounterDescription(counterStr),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList()
                      
                      // Fallback alla singola counter-strategia
                      else
                        Text(
                          counterStrategy,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Pulsanti
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onReplay();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Rigioca'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor.withOpacity(0.8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onChangeStrategy();
                        },
                        icon: const Icon(Icons.change_circle),
                        label: const Text('Nuova Sfida'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  /// Crea messaggi di stato specifici per modalità
  static Map<String, String> getGameOverMessages({
    required String gameMode,
    required String status, // 'won', 'lost', 'tie'
  }) {
    switch (gameMode.toLowerCase()) {
      case 'classic':
        switch (status) {
          case 'won':
            return {
              'title': '🎉 Hai Vinto!',
              'message': 'Eccellente strategia! Hai dimostrato di saper giocare tatticamente!',
            };
          case 'lost':
            return {
              'title': '🤖 Ha Vinto l\'AI',
              'message': 'Non arrenderti! Analizza la strategia dell\'AI e riprova!',
            };
          case 'tie':
            return {
              'title': '🤝 Pareggio!',
              'message': 'Partita perfetta! Entrambi avete giocato in modo ottimale!',
            };
          default:
            return {'title': 'Partita finita', 'message': 'Grazie per aver giocato!'};
        }
      
      case 'simultaneous':
        switch (status) {
          case 'won':
            return {
              'title': '⚡ Hai Vinto!',
              'message': 'Ottima strategia simultanea! Hai imparato a predire l\'avversario!',
            };
          case 'lost':
            return {
              'title': '🤖 Ha Vinto l\'AI',
              'message': 'Nel gioco simultaneo la predizione è tutto! Riprova!',
            };
          case 'tie':
            return {
              'title': '🤝 Pareggio!',
              'message': 'Equilibrio perfetto nel chaos simultaneo! Bene giocato!',
            };
          default:
            return {'title': 'Partita finita', 'message': 'Grazie per aver giocato!'};
        }
      
      default:
        return {
          'title': 'Partita finita',
          'message': 'Grazie per aver giocato!',
        };
    }
  }

  /// Ottieni colore tema per modalità di gioco
  static Color getThemeColor(String gameMode) {
    switch (gameMode.toLowerCase()) {
      case 'classic':
        return Colors.blue;
      case 'simultaneous':
        return Colors.orange;
      case 'coop':
      case 'cooperative':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  /// Estrae il titolo dalla counter-strategia (prima parte prima dei due punti)
  static String _extractCounterTitle(String counterStrategy) {
    if (counterStrategy.contains(':')) {
      return counterStrategy.split(':')[0].trim();
    }
    return counterStrategy.length > 30 
        ? counterStrategy.substring(0, 30) + '...'
        : counterStrategy;
  }

  /// Estrae la descrizione dalla counter-strategia (parte dopo i due punti)
  static String _extractCounterDescription(String counterStrategy) {
    if (counterStrategy.contains(':')) {
      return counterStrategy.split(':').skip(1).join(':').trim();
    }
    return counterStrategy;
  }

  /// Ottieni icone per diversi tipi di risultato
  static IconData getResultIcon(String status) {
    switch (status) {
      case 'won':
        return Icons.emoji_events;
      case 'lost':
        return Icons.psychology;
      case 'tie':
        return Icons.handshake;
      default:
        return Icons.info;
    }
  }
}