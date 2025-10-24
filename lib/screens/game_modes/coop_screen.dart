import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/coop_provider.dart';
import '../../models/coop_game.dart';
import '../../widgets/game_theory_hint.dart';
import '../../widgets/coop_strategy_drawer.dart';
import '../../strategies/coop/coop_ai_strategy.dart';
import '../../utils/dialog_utils.dart';

class CoopScreen extends ConsumerStatefulWidget {
  const CoopScreen({super.key});

  @override
  ConsumerState<CoopScreen> createState() => _CoopScreenState();
}

class _CoopScreenState extends ConsumerState<CoopScreen>
    with TickerProviderStateMixin {
  late AnimationController _teamController;
  late AnimationController _pulseController;
  late Animation<double> _teamAnimation;
  late Animation<double> _pulseAnimation;
  CoopGameStatus? _lastGameStatus;

  @override
  void initState() {
    super.initState();
    
    _teamController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _teamAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _teamController,
      curve: Curves.bounceOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _teamController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _showGameOverDialog(CoopGameStatus status) {
    String title;
    String message;
    Color color;

    switch (status) {
      case CoopGameStatus.teamWon:
        title = '🎉 Il Team ha Vinto!';
        message = 'Ottimo lavoro di squadra! Tu e la tua AI amica avete collaborato perfettamente!';
        color = Colors.green;
        // Mostra il dialog delle strategie se il team ha vinto
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final coopProvider = ref.read(coopTicTacToeProvider.notifier);
            final currentStrategy = coopProvider.currentStrategy;
            final strategyProgress = coopProvider.strategyProgress;
            
           /*  DialogUtils.showStrategyRevealDialog(
              context: context,
              strategyName: _getStrategyDisplayName(currentStrategy),
              strategyDescription: _getStrategyDescription(currentStrategy),
              counterStrategy: '', // Verrà ignorato se multipleCounterStrategies è fornito
              themeColor: Colors.green,
              onReplay: () {
                Navigator.of(context).pop();
                ref.read(coopTicTacToeProvider.notifier).resetGame();
              },
              onChangeStrategy: () {
                Navigator.of(context).pop();
                // Non serve riaprire il drawer, è già aperto
              },
              gameMode: 'Co-op',
              multipleCounterStrategies: strategyProgress.getMultipleCounterStrategies(currentStrategy),
            ); */
            return; // Non mostrare subito il dialog di vittoria
          }
        });
        break;
      case CoopGameStatus.enemyWon:
        title = '😤 Il Nemico ha Vinto';
        message = 'Non arrendetevi! Provate una strategia diversa la prossima volta!';
        color = Colors.pink;
        break;
      case CoopGameStatus.tie:
        title = '🤝 Pareggio!';
        message = 'Buona collaborazione! Nessuno è riuscito a prevalere!';
        color = Colors.orange;
        break;
      default:
        return;
    }

    // Per tutte le condizioni diverse da teamWon, mostra direttamente il dialog
    if (status != CoopGameStatus.teamWon) {
      _showVictoryDialog(title, message, color);
    }
  }

  String _getStrategyDisplayName(CoopAIStrategy strategy) {
    switch (strategy) {
      case CoopAIStrategy.supportive:
        return 'AI Supportiva';
      case CoopAIStrategy.defensive:
        return 'AI Difensiva';
      case CoopAIStrategy.random:
        return 'AI Casuale';
      case CoopAIStrategy.coordinated:
        return 'AI Coordinata';
      case CoopAIStrategy.aggressive:
        return 'AI Aggressiva';
      case CoopAIStrategy.balanced:
        return 'AI Bilanciata';
      case CoopAIStrategy.tactical:
        return 'AI Tattica';
      case CoopAIStrategy.adaptive:
        return 'AI Adattiva';
      case CoopAIStrategy.optimal:
        return 'AI Ottimale';
    }
  }

  String _getStrategyDescription(CoopAIStrategy strategy) {
    switch (strategy) {
      case CoopAIStrategy.supportive:
        return 'L\'AI amica si concentrava sul supportarti, bloccando le mosse nemiche e creando opportunità per te.';
      case CoopAIStrategy.defensive:
        return 'L\'AI amica giocava in modo difensivo, prioritizzando la protezione da minacce immediate.';
      case CoopAIStrategy.random:
        return 'L\'AI amica sceglieva mosse casuali tra quelle disponibili, rendendo il gioco imprevedibile.';
      case CoopAIStrategy.coordinated:
        return 'L\'AI amica coordinava attentamente le mosse con le tue, creando sinergie strategiche.';
      case CoopAIStrategy.aggressive:
        return 'L\'AI amica giocava aggressivamente, cercando sempre di creare minacce multiple.';
      case CoopAIStrategy.balanced:
        return 'L\'AI amica bilanciava attacco e difesa, adattandosi dinamicamente alla situazione.';
      case CoopAIStrategy.tactical:
        return 'L\'AI amica utilizzava tattiche avanzate, pianificando diversi turni in anticipo.';
      case CoopAIStrategy.adaptive:
        return 'L\'AI amica si adattava in tempo reale al tuo stile di gioco e alle mosse nemiche.';
      case CoopAIStrategy.optimal:
        return 'L\'AI amica giocava in modo matematicamente ottimale, massimizzando sempre le probabilità di vittoria del team.';
    }
  }

  void _showVictoryDialog(String title, String message, Color color) {
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
                  if (mounted) {
                    ref.read(coopTicTacToeProvider.notifier).resetGame();
                    setState(() {
                      _lastGameStatus = null;
                    });
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Rigioca'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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
    final game = ref.watch(coopTicTacToeProvider);
    
    // Mostra dialog quando il gioco finisce (solo se è un nuovo stato finale)
    if (mounted && 
        _lastGameStatus != game.status &&
        (game.status == CoopGameStatus.teamWon ||
         game.status == CoopGameStatus.enemyWon ||
         game.status == CoopGameStatus.tie)) {
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showGameOverDialog(game.status);
        }
      });
    }
    _lastGameStatus = game.status;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Co-op'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          Builder(
            builder: (BuildContext scaffoldContext) {
              return IconButton(
                icon: Icon(
                  Icons.menu,
                  color: Colors.green.shade700,
                ),
                onPressed: () {
                  Scaffold.of(scaffoldContext).openEndDrawer();
                },
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
      ),
      endDrawer: CoopStrategyDrawer(
        currentStrategy: ref.read(coopTicTacToeProvider.notifier).currentStrategy,
        progress: ref.read(coopTicTacToeProvider.notifier).strategyProgress,
        onStrategySelected: (strategy) {
          ref.read(coopTicTacToeProvider.notifier).changeStrategy(strategy);
          if (Navigator.of(context).canPop()) {
            Navigator.pop(context);
          }
        },
        onInfoPressed: (strategy) {
          final strategyProgress = ref.read(coopTicTacToeProvider.notifier).strategyProgress;
          if (strategyProgress.isDefeated(strategy)) {
          
          }
        },
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
                  Colors.green.shade50,
                  Colors.blue.shade50,
                ],
              ),
            ),
            child: Column(
            children: [
              // Titolo
              Padding(
                padding: EdgeInsets.all(30.0),
                child: Text(
                  'Modalità Co-op',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700
                  ),
                ),
              ),
              
              // Indicatore turno
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
   
              ),
              
              // Griglia di gioco
              Container(
                height: 300,
                margin: const EdgeInsets.all(40),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: _buildGrid(game),
                  ),
                ),
              ),

              // Widget hint per teoria dei giochi
              Container(
                margin: const EdgeInsets.all(20),
                child: GameTheoryHint(
                  gameMode: 'Co-op Tic Tac Toe',
                  title: 'Coordinamento e Pareto Efficiency',
                  concept: 'Questo è un gioco cooperativo dove tu e l\'AI amica dovete coordinarvi per sconfiggere l\'AI nemica. Introduce i concetti di coordinamento e efficienza di Pareto.',
                  learning: 'Imparerai l\'importanza della fiducia e del coordinamento. Vedrai come la cooperazione può portare a risultati migliori per tutti i partecipanti (Pareto efficiency).',
                  experience: 'Sperimenterai come lavorare in squadra cambia completamente la strategia. Capirai che a volte aiutare il partner è più importante che cercare la vittoria personale!',
                  themeColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildStatusIndicator(CoopGameStatus status) {
    String text;
    Color color;
    IconData icon;

    switch (status) {
      case CoopGameStatus.humanTurn:
        text = 'Il tuo turno!';
        color = Colors.blue;
        icon = Icons.person;
        break;
      case CoopGameStatus.friendlyAiTurn:
        text = 'Turno AI Amica';
        color = Colors.green;
        icon = Icons.android;
        break;
      case CoopGameStatus.enemyAiTurn:
        text = 'Turno AI Nemica';
        color = Colors.pink;
        icon = Icons.smart_toy;
        break;
      default:
        text = 'Gioco terminato';
        color = Colors.grey;
        icon = Icons.flag;
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: status == CoopGameStatus.humanTurn ? _pulseAnimation.value : 1.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid(CoopTicTacToeGame game) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
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

  Widget _buildCell(CoopTicTacToeGame game, int index) {
    final isWinning = game.isWinningCell(index);
    final symbol = game.getSymbol(index);
    final isEmpty = game.board[index] == CoopPlayer.none;
    final symbolColor = game.getSymbolColor(index);

    Color backgroundColor = Colors.transparent;
    if (isWinning) {
      backgroundColor = game.board[index] == CoopPlayer.team 
          ? Colors.green.withOpacity(0.3)
          : Colors.pink.withOpacity(0.3);
    } else if (isEmpty && game.status == CoopGameStatus.humanTurn) {
      backgroundColor = Colors.blue.withOpacity(0.05);
    }

    return GestureDetector(
      onTap: isEmpty && game.status == CoopGameStatus.humanTurn
          ? () {
              if (mounted) {
                ref.read(coopTicTacToeProvider.notifier).makeHumanMove(index);
                _teamController.forward().then((_) {
                  if (mounted) {
                    _teamController.reset();
                  }
                });
              }
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: Colors.green.shade200,
            width: 2,
          ),
        ),
        child: Center(
          child: symbol.isEmpty
              ? Container()
              : AnimatedBuilder(
                  animation: _teamAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.3 + 0.7 * _teamAnimation.value,
                      child: Text(
                        symbol,
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: symbolColor,
                          shadows: [
                            Shadow(
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}