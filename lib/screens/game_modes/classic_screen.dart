import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/tic_tac_toe_provider.dart';
import '../../models/tic_tac_toe_game.dart';
import '../../models/ai_difficulty.dart';
import '../../widgets/game_theory_hint.dart';
import '../../widgets/strategy_selector.dart';

class ClassicScreen extends ConsumerStatefulWidget {
  const ClassicScreen({super.key});

  @override
  ConsumerState<ClassicScreen> createState() => _ClassicScreenState();
}

class _ClassicScreenState extends ConsumerState<ClassicScreen>
    with TickerProviderStateMixin {
  late AnimationController _gridController;
  late AnimationController _symbolController;
  late Animation<double> _gridAnimation;
  late Animation<double> _symbolAnimation;

  @override
  void initState() {
    super.initState();
    
    _gridController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _symbolController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _gridAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gridController,
      curve: Curves.elasticOut,
    ));

    _symbolAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _symbolController,
      curve: Curves.bounceOut,
    ));

    _gridController.forward();
  }

  @override
  void dispose() {
    _gridController.dispose();
    _symbolController.dispose();
    super.dispose();
  }

  void _showGameOverDialog(GameStatus status) {
    String title;
    String message;
    Color color;

    switch (status) {
      case GameStatus.humanWon:
        title = '🎉 Hai Vinto!';
        message = 'Complimenti! Sei stato più furbo dell\'AI!';
        color = Colors.green;
        break;
      case GameStatus.aiWon:
        title = '🤖 Ha Vinto l\'AI';
        message = 'Non arrenderti! Riprova e vincerai!';
        color = Colors.red;
        break;
      case GameStatus.tie:
        title = '🤝 Pareggio!';
        message = 'Bel gioco! Entrambi siete stati bravi!';
        color = Colors.orange;
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: AlertDialog(
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
                    ref.read(ticTacToeProvider.notifier).resetGame();
                    _symbolController.reset();
                    _gridController.forward();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Rigioca'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(ticTacToeProvider);
    
    // Mostra dialog quando il gioco finisce
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (game.status != GameStatus.playing) {
        _showGameOverDialog(game.status);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classic Tic Tac Toe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                  Colors.blue.shade50,
                  Colors.purple.shade50,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Titolo
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Tactica - Tic Tac Toe',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                
                // Indicatore turno
                Container(
                  margin: const EdgeInsets.only(bottom: 30),
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
                  child: Text(
                    game.currentPlayer == Player.human ? 'Il tuo turno (X)' : 'Turno AI (O)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: game.currentPlayer == Player.human ? Colors.blue : Colors.red,
                    ),
                  ),
                ),

                // Selettore strategia AI
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: StrategySelector(
                    selectedDifficulty: game.aiStrategy.difficulty,
                    selectedStrategy: game.aiStrategy,
                    onDifficultyChanged: (difficulty) {
                      // Quando cambia la difficoltà, seleziona la prima strategia di quella difficoltà
                      final firstStrategy = difficulty.strategies.first;
                      ref.read(ticTacToeProvider.notifier).setAIStrategy(firstStrategy);
                    },
                    onStrategyChanged: (strategy) {
                      ref.read(ticTacToeProvider.notifier).setAIStrategy(strategy);
                    },
                  ),
                ),

                // Griglia Tic Tac Toe
                Container(
                  height: 300,
                  margin: const EdgeInsets.all(20),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: AnimatedBuilder(
                        animation: _gridAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _gridAnimation.value,
                            child: _buildGrid(game),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Widget hint per teoria dei giochi
                Container(
                  margin: const EdgeInsets.all(20),
                  child: GameTheoryHint(
                    gameMode: 'Classic Tic Tac Toe',
                    title: 'Equilibrio Perfetto nei Sottogiochi',
                    concept: 'Questo è un gioco sequenziale a somma zero con informazione completa. È un esempio perfetto di come l\'equilibrio di Nash funzioni nei giochi sequenziali.',
                    learning: 'Imparerai che quando entrambi i giocatori giocano razionalmente, il risultato è sempre un pareggio. Questo dimostra il concetto di "strategia dominante" e come l\'equilibrio perfetto funziona.',
                    experience: 'Sperimenterai come le strategie ottimali portano sempre allo stesso risultato. Capirai che in alcuni giochi, giocare perfettamente significa che nessuno può vincere!',
                    themeColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(TicTacToeGame game) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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

  Widget _buildCell(TicTacToeGame game, int index) {
    final isWinning = game.isWinningCell(index);
    final symbol = game.getSymbol(index);
    final isEmpty = game.board[index] == Player.none;

    return GestureDetector(
      onTap: isEmpty && game.currentPlayer == Player.human && game.status == GameStatus.playing
          ? () {
              ref.read(ticTacToeProvider.notifier).makeHumanMove(index);
              _symbolController.forward().then((_) {
                _symbolController.reset();
              });
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isWinning 
              ? Colors.green.withOpacity(0.3)
              : isEmpty && game.currentPlayer == Player.human
                  ? Colors.blue.withOpacity(0.05)
                  : Colors.transparent,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: symbol.isEmpty
              ? Container()
              : AnimatedBuilder(
                  animation: _symbolAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: symbol.isEmpty ? 0 : (0.3 + 0.7 * _symbolAnimation.value),
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
                ),
        ),
      ),
    );
  }
}