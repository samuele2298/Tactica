import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/prisoner_dilemma_game.dart';
import '../providers/prisoner_dilemma_provider.dart';

class PlaySetupScreen extends ConsumerStatefulWidget {
  const PlaySetupScreen({super.key});

  @override
  ConsumerState<PlaySetupScreen> createState() => _PlaySetupScreenState();
}

class _PlaySetupScreenState extends ConsumerState<PlaySetupScreen> {
  BotStrategy selectedStrategy = BotStrategy.titForTat;
  int selectedRounds = 5;
  bool showPayoffNumbers = true;

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
                        'Dilemma del Prigioniero',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),

                // Matrice dei Payoff
                Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Matrice dei Payoff',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildPayoffMatrix(),
                        const SizedBox(height: 10),
                        Text(
                          'Formato: (Tu, Avversario)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Selezione Avversario
                Expanded(
                  child: Card(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scegli il tuo avversario:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          
                          const SizedBox(height: 20),

                          // Lista strategie bot
                          Expanded(
                            child: ListView(
                              children: BotStrategy.values.map((strategy) {
                                return _buildStrategyTile(strategy);
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Impostazioni aggiuntive
                          Text(
                            'Impostazioni:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          
                          const SizedBox(height: 10),

                          // Numero di turni
                          Row(
                            children: [
                              Text(
                                'Numero di turni:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const Spacer(),
                              DropdownButton<int>(
                                value: selectedRounds,
                                items: [3, 5, 10].map((rounds) {
                                  return DropdownMenuItem(
                                    value: rounds,
                                    child: Text('$rounds'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedRounds = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Mostra numeri
                          Row(
                            children: [
                              Text(
                                'Mostra payoff numerici:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                value: showPayoffNumbers,
                                onChanged: (value) {
                                  setState(() {
                                    showPayoffNumbers = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Pulsante Inizia
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Inizia Partita',
                      style: TextStyle(
                        fontSize: 20,
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

  Widget _buildPayoffMatrix() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade400),
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: [
            const TableCell(child: SizedBox(height: 40)),
            TableCell(
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Text('🟢 Coopera', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            TableCell(
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Text('🔴 Tradisce', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        // Coopera row
        TableRow(
          children: [
            TableCell(
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.grey.shade100),
                child: Text('🟢 Coopera', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            TableCell(
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Text('(3, 3)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
              ),
            ),
            TableCell(
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Text('(0, 5)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
              ),
            ),
          ],
        ),
        // Tradisce row
        TableRow(
          children: [
            TableCell(
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.grey.shade100),
                child: Text('🔴 Tradisce', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            TableCell(
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Text('(5, 0)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
              ),
            ),
            TableCell(
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Text('(1, 1)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStrategyTile(BotStrategy strategy) {
    final isSelected = selectedStrategy == strategy;
    
    return Card(
      elevation: isSelected ? 6 : 2,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: RadioListTile<BotStrategy>(
        value: strategy,
        groupValue: selectedStrategy,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              selectedStrategy = value;
            });
          }
        },
        title: Row(
          children: [
            Text(
              strategy.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 10),
            Text(
              strategy.displayName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSelected ? Colors.blue.shade700 : Colors.black,
              ),
            ),
          ],
        ),
        subtitle: Text(
          strategy.description,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        activeColor: Colors.blue.shade600,
      ),
    );
  }

  void _startGame() {
    final settings = GameSettings(
      botStrategy: selectedStrategy,
      totalRounds: selectedRounds,
      showPayoffNumbers: showPayoffNumbers,
    );

    ref.read(prisonerDilemmaProvider.notifier).startNewGame(settings);
    context.go('/play/game');
  }
}