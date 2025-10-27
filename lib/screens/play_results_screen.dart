import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/prisoner_dilemma_game.dart';
import '../providers/prisoner_dilemma_provider.dart';

class PlayResultsScreen extends ConsumerWidget {
  const PlayResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(prisonerDilemmaProvider);
    final analysis = ref.watch(gameAnalysisProvider);

    if (!game.isGameFinished || analysis == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Analizzando i risultati...'),
            ],
          ),
        ),
      );
    }

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
                      onPressed: () => context.go('/play'),
                      icon: const Icon(Icons.arrow_back, size: 30),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Risultato della tua partita',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Risultati
                Expanded(
                  child: ListView(
                    children: [
                      // Statistiche di base
                      _buildBasicStats(game),
                      
                      const SizedBox(height: 20),
                      
                      // Grafico temporale
                      _buildPayoffChart(game),
                      
                      const SizedBox(height: 20),
                      
                      // Analisi testuale
                      _buildAnalysis(analysis),
                      
                      const SizedBox(height: 20),
                      
                      // Pulsanti azioni
                      _buildActionButtons(context, analysis),
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

  Widget _buildBasicStats(PrisonerDilemmaGame game) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🧩 Dati base',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            
            const SizedBox(height: 15),
            
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
              },
              children: [
                _buildTableRow('Turni totali', '${game.settings.totalRounds}'),
                _buildTableRow('% Cooperazione tua', '${(game.playerCooperationRate * 100).toStringAsFixed(0)}%'),
                _buildTableRow('% Cooperazione avversario', '${(game.botCooperationRate * 100).toStringAsFixed(0)}%'),
                _buildTableRow('Payoff medio tuo', game.averagePlayerPayoff.toStringAsFixed(1)),
                _buildTableRow('Payoff medio avversario', game.averageBotPayoff.toStringAsFixed(1)),
                _buildTableRow('Punteggio finale', '${game.totalPlayerScore} - ${game.totalBotScore}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildPayoffChart(PrisonerDilemmaGame game) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📈 Payoff per turno',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Visualizzazione semplificata dei turni
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: game.rounds.length,
                itemBuilder: (context, index) {
                  final round = game.rounds[index];
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 10),
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'T${round.roundNumber}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${round.playerPayoff}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Text('Tu', style: TextStyle(fontSize: 10)),
                            const SizedBox(height: 5),
                            Text(
                              '${round.botPayoff}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const Text('Bot', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 10),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Tu', Colors.blue),
                const SizedBox(width: 20),
                _buildLegendItem('Avversario', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAnalysis(GameAnalysis analysis) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔍 Analisi automatica',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            
            const SizedBox(height: 15),
            
            Text(
              analysis.summary,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 15),
            
            Text(
              analysis.equilibriumAnalysis,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey.shade700,
              ),
            ),
            
            if (analysis.reachedStableEquilibrium)
              Container(
                margin: const EdgeInsets.only(top: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Equilibrio stabile raggiunto',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, GameAnalysis analysis) {
    return Column(
      children: [
        // Pulsante per approfondire
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () => _goToLearningModule(context, analysis.suggestedLearningModule),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            icon: const Icon(Icons.school, size: 24),
            label: Text(
              'Capisci perché → ${analysis.suggestedLearningModule}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 15),
        
        // Pulsanti secondari
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () => context.go('/play'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Nuova Partita',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 10),
            
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () => context.go('/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Menu Principale',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _goToLearningModule(BuildContext context, String module) {
    // Converti il nome del modulo in route
    String route = '/learn';
    switch (module) {
      case 'Strategia dominante':
        route = '/learn/dominant-strategy';
        break;
      case 'Equilibrio di Nash':
        route = '/learn/nash-equilibrium';
        break;
      case 'Giochi ripetuti e fiducia':
        route = '/learn/repeated-games';
        break;
      case 'Cos\'è un gioco strategico':
        route = '/learn/strategic-games';
        break;
      default:
        route = '/learn/prisoner-dilemma';
        break;
    }
    context.go(route);
  }
}