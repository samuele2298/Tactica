import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/simultaneous_provider.dart';
import '../../models/simultaneous_game.dart';
import '../../widgets/game_theory_hint.dart';

class SimultaneousScreen extends ConsumerStatefulWidget {
  const SimultaneousScreen({super.key});

  @override
  ConsumerState<SimultaneousScreen> createState() => _SimultaneousScreenState();
}

class _SimultaneousScreenState extends ConsumerState<SimultaneousScreen>
    with TickerProviderStateMixin {
  late AnimationController _flashController;
  late AnimationController _revealController;
  late Animation<double> _flashAnimation;
  late Animation<double> _revealAnimation;

  @override
  void initState() {
    super.initState();
    
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _flashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flashController,
      curve: Curves.elasticOut,
    ));

    _revealAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _revealController,
      curve: Curves.bounceOut,
    ));
  }

  @override
  void dispose() {
    _flashController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _showGameOverDialog(SimultaneousGameStatus status) {
    String title;
    String message;
    Color color;

    switch (status) {
      case SimultaneousGameStatus.humanWon:
        title = '⚡ Hai Vinto!';
        message = 'Ottima strategia! Hai imparato a giocare simultaneamente!';
        color = Colors.orange;
        break;
      case SimultaneousGameStatus.aiWon:
        title = '🤖 Ha Vinto l\'AI';
        message = 'Non arrenderti! Prova strategie diverse la prossima volta!';
        color = Colors.red;
        break;
      case SimultaneousGameStatus.tie:
        title = '🤝 Pareggio!';
        message = 'Equilibrio perfetto! Entrambi avete giocato bene!';
        color = Colors.grey;
        break;
      default:
        return;
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
                  ref.read(simultaneousTicTacToeProvider.notifier).resetGame();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Rigioca'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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
    final game = ref.watch(simultaneousTicTacToeProvider);
    
    // Mostra dialog quando il gioco finisce
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (game.status == SimultaneousGameStatus.humanWon ||
          game.status == SimultaneousGameStatus.aiWon ||
          game.status == SimultaneousGameStatus.tie) {
        _showGameOverDialog(game.status);
      } else if (game.status == SimultaneousGameStatus.revealing) {
        _revealController.forward().then((_) {
          _revealController.reset();
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simultaneous Tic Tac Toe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        backgroundColor: Colors.orange.shade100,
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
                  Colors.orange.shade50,
                  Colors.yellow.shade50,
                ],
              ),
            ),
            child: Column(
            children: [
              // Header info
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.flash_on, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Modalità Tattica',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getStatusText(game.status, game.humanSelectedMove),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Griglia di gioco
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      child: _buildGrid(game),
                    ),
                  ),
                ),
              ),

              // Pulsante conferma
              if (game.status == SimultaneousGameStatus.selectingMoves && 
                  game.humanSelectedMove != null)
                Container(
                  margin: const EdgeInsets.all(20),
                  child: AnimatedBuilder(
                    animation: _flashAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + 0.1 * _flashAnimation.value,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ref.read(simultaneousTicTacToeProvider.notifier).confirmMove();
                            _flashController.forward().then((_) {
                              _flashController.reset();
                            });
                          },
                          icon: const Icon(Icons.flash_on),
                          label: const Text('Rivela Mosse!'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Widget hint per teoria dei giochi
              Container(
                margin: const EdgeInsets.all(20),
                child: GameTheoryHint(
                  gameMode: 'Simultaneous Tic Tac Toe',
                  title: 'Equilibrio Misto e Strategie Simultanee',
                  concept: 'Questo è un gioco simultaneo dove entrambi i giocatori scelgono le loro mosse in segreto. Introduce il concetto di equilibrio misto e l\'importanza della randomizzazione.',
                  learning: 'Imparerai che senza informazione sulle mosse dell\'avversario, la randomizzazione diventa strategica. Capirai come l\'equilibrio misto funziona nei giochi simultanei.',
                  experience: 'Sperimenterai l\'importanza di essere imprevedibili. Scoprirai che essere troppo prevedibili può essere svantaggioso quando le mosse sono simultanee!',
                  themeColor: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  String _getStatusText(SimultaneousGameStatus status, int? selectedMove) {
    switch (status) {
      case SimultaneousGameStatus.selectingMoves:
        if (selectedMove == null) {
          return 'Scegli segretamente una cella!\nL\'AI farà lo stesso contemporaneamente.';
        } else {
          return 'Mossa selezionata! Premi "Rivela Mosse" per vedere cosa succede!';
        }
      case SimultaneousGameStatus.revealing:
        return 'Rivelazione delle mosse in corso...';
      default:
        return '';
    }
  }

  Widget _buildGrid(SimultaneousTicTacToeGame game) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
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

  Widget _buildCell(SimultaneousTicTacToeGame game, int index) {
    final isWinning = game.isWinningCell(index);
    final symbol = game.getSymbol(index);
    final isEmpty = game.board[index] == SimultaneousPlayer.none;
    final isSelected = game.isHumanSelected(index);
    final isAiSelected = game.isAiSelected(index);
    final hasConflict = game.hasConflict(index);

    Color backgroundColor = Colors.transparent;
    if (isWinning) {
      backgroundColor = Colors.green.withOpacity(0.3);
    } else if (hasConflict && game.isRevealingMoves) {
      backgroundColor = Colors.red.withOpacity(0.3);
    } else if (isSelected && game.status == SimultaneousGameStatus.selectingMoves) {
      backgroundColor = Colors.orange.withOpacity(0.2);
    } else if ((isSelected || isAiSelected) && game.isRevealingMoves) {
      backgroundColor = Colors.yellow.withOpacity(0.2);
    }

    return GestureDetector(
      onTap: isEmpty && game.status == SimultaneousGameStatus.selectingMoves
          ? () {
              ref.read(simultaneousTicTacToeProvider.notifier).selectMove(index);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: Colors.orange.shade200,
            width: 2,
          ),
        ),
        child: Center(
          child: _buildCellContent(symbol, hasConflict, game.isRevealingMoves),
        ),
      ),
    );
  }

  Widget _buildCellContent(String symbol, bool hasConflict, bool isRevealing) {
    if (hasConflict && isRevealing) {
      return AnimatedBuilder(
        animation: _revealAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _revealAnimation.value,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.close,
                  size: 30,
                  color: Colors.red,
                ),
                Text(
                  'CONFLITTO!',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    if (symbol.isEmpty) {
      return Container();
    }

    return AnimatedBuilder(
      animation: _revealAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isRevealing ? _revealAnimation.value : 1.0,
          child: Text(
            symbol,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: symbol == 'X' ? Colors.blue : Colors.red,
            ),
          ),
        );
      },
    );
  }
}