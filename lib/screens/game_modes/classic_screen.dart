import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/tic_tac_toe_provider.dart';
import '../../models/tic_tac_toe_game.dart';
import '../../models/ai_difficulty.dart';
import '../../widgets/game_theory_hint.dart';
import '../../widgets/strategy_selection_dialog.dart';

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
  
  bool _isFirstTime = true;
  bool _isGameInProgress = false;
  bool _hasShownGameOverDialog = false;

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
    
    // Mostra il popup di selezione strategia solo alla prima apertura
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFirstTime) {
        _showStrategySelectionDialog(isGameStart: true);
      }
    });
  }

  @override
  void dispose() {
    _gridController.dispose();
    _symbolController.dispose();
    super.dispose();
  }

  void _showStrategySelectionDialog({required bool isGameStart, bool autoStartAfterSelection = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StrategySelectionDialog(
          currentStrategy: ref.read(ticTacToeProvider).aiStrategy,
          isGameStart: isGameStart,
          onStart: () {
            if (mounted) {
              setState(() {
                _isFirstTime = false;
                _isGameInProgress = true;
                _hasShownGameOverDialog = false;
              });
            }
          },
          onStrategySelected: (strategy) {
            if (mounted) {
              ref.read(ticTacToeProvider.notifier).setAIStrategy(strategy);
              
              // Se dobbiamo iniziare automaticamente dopo la selezione
              if (autoStartAfterSelection) {
                ref.read(ticTacToeProvider.notifier).resetGame();
                setState(() {
                  _isGameInProgress = true;
                  _hasShownGameOverDialog = false;
                });
                _symbolController.reset();
                _gridController.forward();
              }
            }
          },
          onReplay: () {
            if (mounted) {
              ref.read(ticTacToeProvider.notifier).resetGame();
              setState(() {
                _isGameInProgress = true;
                _hasShownGameOverDialog = false;
              });
              _symbolController.reset();
              _gridController.forward();
            }
          },
        );
      },
    );
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

    setState(() {
      _isGameInProgress = false;
    });

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
                child: Column(
                    children: [
                    SizedBox(
                        width: 200,
                        child: ElevatedButton.icon(
                        onPressed: () {
                            Navigator.of(context).pop();
                            if (mounted) {
                            ref.read(ticTacToeProvider.notifier).resetGame();
                            setState(() {
                                _isGameInProgress = true;
                                _hasShownGameOverDialog = false;
                            });
                            _symbolController.reset();
                            _gridController.forward();
                            }
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
                    const SizedBox(height: 8),
                    SizedBox(
                        width: 200,
                        child: OutlinedButton.icon(
                        onPressed: () {
                            Navigator.of(context).pop();
                            if (mounted) {
                            _showStrategySelectionDialog(isGameStart: false, autoStartAfterSelection: true);
                            }
                        },
                        icon: Icon(Icons.settings, color: color),
                        label: Text(
                            'Cambia Strategia',
                            style: TextStyle(color: color),
                        ),
                        style: OutlinedButton.styleFrom(
                            side: BorderSide(color: color),
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
                ),
            ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(ticTacToeProvider);
    
    // Mostra dialog quando il gioco finisce (solo se il widget è ancora montato e non già mostrato)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && game.status != GameStatus.playing && !_hasShownGameOverDialog) {
        _hasShownGameOverDialog = true;
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

                // Indicatore strategia corrente (non modificabile durante gioco)
                if (!_isFirstTime && _isGameInProgress)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.psychology, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'AI: ${game.aiStrategy.displayName}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Griglia Tic Tac Toe (visibile solo dopo aver iniziato)
                if (!_isFirstTime)
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

                // Messaggio di benvenuto (visibile solo prima di iniziare)
                if (_isFirstTime)
                  Container(
                    height: 300,
                    margin: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle_fill,
                            size: 80,
                            color: Colors.blue.shade300,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Premi START per iniziare!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Scegli la strategia AI e inizia a giocare',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
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
              if (mounted) {
                ref.read(ticTacToeProvider.notifier).makeHumanMove(index);
                _symbolController.forward().then((_) {
                  if (mounted) {
                    _symbolController.reset();
                  }
                });
              }
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
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: symbol == 'X' ? Colors.blue : Colors.red,
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