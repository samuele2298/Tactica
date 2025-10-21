import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/nebel_provider.dart';
import '../../models/nebel_game.dart';
import '../../widgets/game_theory_hint.dart';

class NebelScreen extends ConsumerStatefulWidget {
  const NebelScreen({super.key});

  @override
  ConsumerState<NebelScreen> createState() => _NebelScreenState();
}

class _NebelScreenState extends ConsumerState<NebelScreen>
    with TickerProviderStateMixin {
  late AnimationController _mysteryController;
  late AnimationController _revealController;
  late Animation<double> _mysteryAnimation;
  late Animation<double> _revealAnimation;

  @override
  void initState() {
    super.initState();
    
    _mysteryController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _mysteryAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mysteryController,
      curve: Curves.easeInOut,
    ));

    _revealAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _revealController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _mysteryController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _showGameOverDialog(NebelGameStatus status) {
    String title;
    String message;
    Color color;

    switch (status) {
      case NebelGameStatus.humanWon:
        title = '🔮 Hai Vinto!';
        message = 'Incredibile! Sei riuscito a vincere nonostante l\'incertezza!';
        color = Colors.purple;
        break;
      case NebelGameStatus.aiWon:
        title = '🤖 Ha Vinto l\'AI';
        message = 'L\'AI ha sfruttato meglio le informazioni incomplete!';
        color = Colors.red;
        break;
      case NebelGameStatus.tie:
        title = '🌫️ Pareggio!';
        message = 'Ottima gestione dell\'incertezza da entrambe le parti!';
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
                  ref.read(nebelTicTacToeProvider.notifier).resetGame();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Rigioca'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
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
    final game = ref.watch(nebelTicTacToeProvider);
    
    // Mostra dialog quando il gioco finisce
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (game.status == NebelGameStatus.humanWon ||
          game.status == NebelGameStatus.aiWon ||
          game.status == NebelGameStatus.tie) {
        _showGameOverDialog(game.status);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nebel Tic Tac Toe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        backgroundColor: Colors.purple.shade100,
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
                  Colors.purple.shade50,
                  Colors.indigo.shade50,
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
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.visibility_off, color: Colors.purple),
                        const SizedBox(width: 8),
                        Text(
                          'Modalità Strategica',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getStatusText(game),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.help_outline, size: 16, color: Colors.purple),
                        const SizedBox(width: 4),
                        Text(
                          'Celle nascoste: ${game.hiddenCellsCount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.purple.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

              // Info sulla nebbia
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.purple, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Le celle nascoste (?) si rivelano casualmente durante il gioco. Devi decidere strategicamente con informazioni incomplete!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Widget hint per teoria dei giochi
              Container(
                margin: const EdgeInsets.all(20),
                child: GameTheoryHint(
                  gameMode: 'Nebel Tic Tac Toe',
                  title: 'Informazione Incompleta e Gestione del Rischio',
                  concept: 'Questo è un gioco con informazione incompleta dove alcune celle sono nascoste. Introduce i concetti di incertezza e valutazione probabilistica nelle decisioni strategiche.',
                  learning: 'Imparerai a prendere decisioni sotto incertezza. Capirai come valutare i rischi e come l\'informazione nascosta influenza le strategie ottimali.',
                  experience: 'Sperimenterai la sfida di decidere senza avere tutte le informazioni. Dovrai stimare le probabilità e gestire il rischio di rivelare informazioni all\'avversario!',
                  themeColor: Colors.purple,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  String _getStatusText(NebelTicTacToeGame game) {
    switch (game.status) {
      case NebelGameStatus.playing:
        if (game.currentPlayer == NebelPlayer.human) {
          return 'Il tuo turno! Scegli con saggezza tra le celle visibili.';
        } else {
          return 'L\'AI sta pensando...';
        }
      default:
        return 'Gioco terminato';
    }
  }

  Widget _buildGrid(NebelTicTacToeGame game) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
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

  Widget _buildCell(NebelTicTacToeGame game, int index) {
    final isWinning = game.isWinningCell(index);
    final symbol = game.getSymbol(index);
    final isHidden = game.isCellHidden(index);
    final isClickable = game.isCellClickable(index);

    Color backgroundColor = Colors.transparent;
    if (isWinning) {
      backgroundColor = Colors.green.withOpacity(0.3);
    } else if (isHidden) {
      backgroundColor = Colors.purple.withOpacity(0.1);
    } else if (isClickable) {
      backgroundColor = Colors.blue.withOpacity(0.05);
    }

    return GestureDetector(
      onTap: isClickable
          ? () {
              ref.read(nebelTicTacToeProvider.notifier).makeHumanMove(index);
              _revealController.forward().then((_) {
                _revealController.reset();
              });
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: isHidden ? Colors.purple.shade300 : Colors.purple.shade200,
            width: isHidden ? 3 : 2,
          ),
        ),
        child: Center(
          child: _buildCellContent(symbol, isHidden),
        ),
      ),
    );
  }

  Widget _buildCellContent(String symbol, bool isHidden) {
    if (symbol == '?') {
      return AnimatedBuilder(
        animation: _mysteryAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _mysteryAnimation.value,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
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
          scale: 0.3 + 0.7 * _revealAnimation.value,
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