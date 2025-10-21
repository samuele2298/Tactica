import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/guess_provider.dart';
import '../../models/guess_game.dart';
import '../../widgets/game_theory_hint.dart';

class GuessScreen extends ConsumerStatefulWidget {
  const GuessScreen({super.key});

  @override
  ConsumerState<GuessScreen> createState() => _GuessScreenState();
}

class _GuessScreenState extends ConsumerState<GuessScreen>
    with TickerProviderStateMixin {
  late AnimationController _betController;
  late Animation<double> _betAnimation;
  GuessGameStatus? _lastGameStatus;

  @override
  void initState() {
    super.initState();
    
    _betController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _betAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _betController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _betController.dispose();
    super.dispose();
  }

  void _showFinalDialog(GuessTicTacToeGame game) {
    final accuracy = game.bettingAccuracy;
    String winner = '';
    if (game.winner == GuessPlayer.ai1) {
      winner = 'AI1 (X) ha vinto!';
    } else if (game.winner == GuessPlayer.ai2) {
      winner = 'AI2 (O) ha vinto!';
    } else {
      winner = 'Pareggio!';
    }

    String title;
    String message;
    Color color;

    if (accuracy >= 80) {
      title = '🎯 Scommettitore Professionista!';
      message = 'Incredibile! Hai previsto AI1 con ${accuracy.toStringAsFixed(1)}% di precisione!';
      color = Colors.green;
    } else if (accuracy >= 60) {
      title = '📈 Buon Analista!';
      message = 'Bravo! Hai mostrato ottime capacità predittive: ${accuracy.toStringAsFixed(1)}%';
      color = Colors.orange;
    } else if (accuracy >= 40) {
      title = '🤔 In Miglioramento!';
      message = 'Non male! Continua a studiare le mosse di AI1: ${accuracy.toStringAsFixed(1)}%';
      color = Colors.blue;
    } else {
      title = '🎲 Strategia Difficile!';
      message = 'AI1 era imprevedibile! Precisione: ${accuracy.toStringAsFixed(1)}%';
      color = Colors.red;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Risultato della partita:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      winner,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scommesse corrette: ${game.correctBets}/${game.userBets.length}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (mounted) {
                    ref.read(guessTicTacToeProvider.notifier).resetGame();
                    setState(() {
                      _lastGameStatus = null;
                    });
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Nuova Partita'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(guessTicTacToeProvider);
    
    // Mostra dialog quando il gioco finisce (solo se è un nuovo stato finale)
    if (mounted && 
        _lastGameStatus != game.status &&
        game.status == GuessGameStatus.gameOver) {
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showFinalDialog(game);
        }
      });
    }
    _lastGameStatus = game.status;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guess & Bet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        backgroundColor: Colors.red.shade100,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                        MediaQuery.of(context).padding.top - 
                        kToolbarHeight,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.shade50,
                  Colors.pink.shade50,
                ],
              ),
            ),
            child: Column(
            children: [
              // Header con info giocatori
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    const Text(
                      'AI1 (X) vs AI2 (O)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scommetti su dove giocherà AI1!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard('Turno', '${game.currentTurn}', Colors.blue),
                        _buildStatCard('Corrette', '${game.correctBets}', Colors.green),
                        _buildStatCard('Precisione', '${game.bettingAccuracy.toStringAsFixed(1)}%', Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),

              // Status message
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatusIcon(game.status),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusText(game),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Griglia di gioco
              Container(
                height: 300,
                margin: const EdgeInsets.all(20),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: _buildGrid(game),
                  ),
                ),
              ),

              // Istruzioni
              Container(
                margin: const EdgeInsets.all(20),
                child: Text(
                  _getInstructionText(game.status),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),

              // Widget hint per teoria dei giochi
              Container(
                margin: const EdgeInsets.all(20),
                child: GameTheoryHint(
                  gameMode: 'Guess & Bet Tic Tac Toe',
                  title: 'Predizione e Strategie Miste degli Avversari',
                  concept: 'Questo è un gioco di osservazione e predizione dove devi analizzare le strategie di AI1 mentre compete contro AI2. Introduce pattern recognition e adattamento strategico.',
                  learning: 'Imparerai a riconoscere i pattern comportamentali degli avversari e a fare previsioni basate su osservazioni precedenti. Capirai come le strategie miste rendono difficile la predizione.',
                  experience: 'Sperimenterai la sfida di essere un analista strategico! Dovrai osservare, imparare e scommettere sulle mosse future basandoti sui pattern che riconosci.',
                  themeColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(GuessGameStatus status) {
    switch (status) {
      case GuessGameStatus.waitingForBet:
        return const Icon(Icons.casino, color: Colors.orange);
      case GuessGameStatus.ai1Turn:
        return const Icon(Icons.smart_toy, color: Colors.blue);
      case GuessGameStatus.ai2Turn:
        return const Icon(Icons.android, color: Colors.green);
      case GuessGameStatus.gameOver:
        return const Icon(Icons.flag, color: Colors.purple);
    }
  }

  String _getStatusText(GuessTicTacToeGame game) {
    switch (game.status) {
      case GuessGameStatus.waitingForBet:
        return 'Scommetti dove giocherà AI1';
      case GuessGameStatus.ai1Turn:
        return 'AI1 sta pensando...';
      case GuessGameStatus.ai2Turn:
        return 'AI2 sta rispondendo...';
      case GuessGameStatus.gameOver:
        return game.winner == null 
            ? 'Pareggio!' 
            : '${game.winner == GuessPlayer.ai1 ? "AI1" : "AI2"} ha vinto!';
    }
  }

  String _getInstructionText(GuessGameStatus status) {
    switch (status) {
      case GuessGameStatus.waitingForBet:
        return 'Tocca una cella vuota per scommettere su AI1';
      case GuessGameStatus.ai1Turn:
        return 'AI1 (X) sta facendo la sua mossa...';
      case GuessGameStatus.ai2Turn:
        return 'AI2 (O) sta contrattaccando...';
      case GuessGameStatus.gameOver:
        return 'Partita finita! Guarda i risultati sopra';
    }
  }

  Widget _buildGrid(GuessTicTacToeGame game) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            return _buildCell(game, index);
          },
        ),
      ),
    );
  }

  Widget _buildCell(GuessTicTacToeGame game, int index) {
    final symbol = game.getSymbol(index);
    final isBetCell = game.isBetCell(index);
    final isLastCorrectBet = game.isLastCorrectBet(index);
    final isLastWrongBet = game.isLastWrongBet(index);
    final isWinningCell = game.isWinningCell(index);
    final isClickable = game.status == GuessGameStatus.waitingForBet && 
                       game.board[index] == GuessPlayer.none;

    Color backgroundColor = Colors.transparent;
    Color borderColor = Colors.red.shade200;

    if (isWinningCell) {
      backgroundColor = Colors.purple.withOpacity(0.3);
      borderColor = Colors.purple;
    } else if (isLastCorrectBet) {
      backgroundColor = Colors.green.withOpacity(0.3);
      borderColor = Colors.green;
    } else if (isLastWrongBet) {
      backgroundColor = Colors.red.withOpacity(0.3);
      borderColor = Colors.red;
    } else if (isBetCell) {
      backgroundColor = Colors.orange.withOpacity(0.3);
      borderColor = Colors.orange;
    }

    return GestureDetector(
      onTap: isClickable
          ? () {
              if (mounted) {
                _betController.forward().then((_) {
                  if (mounted) {
                    _betController.reset();
                  }
                });
                ref.read(guessTicTacToeProvider.notifier).placeBet(index);
              }
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
        ),
        child: Center(
          child: Stack(
            children: [
              // Simbolo del giocatore
              if (symbol.isNotEmpty)
                Center(
                  child: Text(
                    symbol,
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: game.board[index] == GuessPlayer.ai1 
                          ? Colors.blue.shade700 
                          : Colors.green.shade700,
                      shadows: [
                        Shadow(
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Indicatore scommessa
              if (isBetCell && symbol.isEmpty)
                AnimatedBuilder(
                  animation: _betAnimation,
                  builder: (context, child) {
                    return Center(
                      child: Transform.scale(
                        scale: _betAnimation.value,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // Feedback visivo per le scommesse
              if (isLastCorrectBet)
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
              if (isLastWrongBet)
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    Icons.cancel,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}