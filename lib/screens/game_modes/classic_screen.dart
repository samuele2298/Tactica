import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tacticafe/providers/classic_provider.dart';
import '../../providers/my_progress.dart';
import '../../models/tic_tac_toe_game.dart';
import '../../models/enums.dart';
import '../../models/strategy_progress.dart';
import '../../widgets/game_theory_hint.dart';
import '../../widgets/new_drawer.dart';
import '../../widgets/tacticafe_logo.dart';
import '../../utils/dialog_utils.dart';

class ClassicScreen extends ConsumerStatefulWidget {
  const ClassicScreen({super.key});

  @override
  ConsumerState<ClassicScreen> createState() => _ClassicScreenState();
}

class _ClassicScreenState extends ConsumerState<ClassicScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _gridController;
  late AnimationController _symbolController;
  late Animation<double> _gridAnimation;
  late Animation<double> _symbolAnimation;
  
  bool _isGameInProgress = false;
  bool _hasShownGameOverDialog = false;
  
  // Sistema di tracciamento vittorie
  final StrategyProgress _strategyProgress = StrategyProgress();
  GameStatus? _lastGameStatus;

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
  
  void _processGameResult(GameStatus status) {
    final currentStrategy = ref.read(classicTicTacToeProvider).aiStrategy;
    final wasJustDefeated = !_strategyProgress.isDefeated(currentStrategy.name);
    
    // Aggiorna progresso
    if (status == GameStatus.humanWon) {
      _strategyProgress.addWin(currentStrategy.name);
    } else if (status == GameStatus.aiWon || status == GameStatus.tie) {
      _strategyProgress.addLoss(currentStrategy.name);
    }
    
    setState(() {
      _isGameInProgress = false;
    });
    
    // Se abbiamo appena sconfitto una strategia per la prima volta
    if (status == GameStatus.humanWon && wasJustDefeated && _strategyProgress.isDefeated(currentStrategy.name)) {
      _showStrategyRevealDialog(currentStrategy);
    } else {
      _showNormalGameOverDialog(status);
    }
  }
  
  void _showStrategyRevealDialog(AIStrategy defeatedStrategy) {
    DialogUtils.showStrategyRevealDialog(
      context: context,
      strategy: ref.read(classicTicTacToeProvider).aiStrategy,
      themeColor: DialogUtils.getThemeColor('classic'),
      gameMode: 'Classic',
      onReplay: () {
        if (mounted) {
          ref.read(classicTicTacToeProvider.notifier).reset();
          setState(() {
            _isGameInProgress = true;
            _hasShownGameOverDialog = false;
          });
          _symbolController.reset();
          _gridController.forward();
        }
      },
      onChangeStrategy: () {
        if (mounted) {
          setState(() {
            _hasShownGameOverDialog = false;
          });
          _scaffoldKey.currentState?.openEndDrawer();
        }
      },
    );
  }
  
  void _showNormalGameOverDialog(GameStatus status) {
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
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _hasShownGameOverDialog = false;
                  });
                },
                icon: const Icon(Icons.close, color: Colors.grey),
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
              child: Column(
                children: [
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (mounted) {
                          ref.read(classicTicTacToeProvider.notifier).reset();
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
                          _scaffoldKey.currentState?.openEndDrawer();
                        }
                      },
                      icon: Icon(Icons.psychology, color: color),
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
    final game = ref.watch(classicTicTacToeProvider);
    
    // Mostra dialog quando il gioco finisce (solo se è un nuovo stato finale)
    if (mounted && 
        _lastGameStatus != game.status &&
        game.status != GameStatus.playing &&
        !_hasShownGameOverDialog) {
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _hasShownGameOverDialog = true;
          _processGameResult(game.status);
        }
      });
    }
    _lastGameStatus = game.status;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          children: [
            TacticafeLogo.small(),
            const SizedBox(width: 8),
            const Text('Tris Classico'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.blue.shade700,
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      endDrawer: StrategyDrawer(
        currentStrategy: ref.read(classicTicTacToeProvider.notifier).currentStrategy,
        onStrategySelected: (strategy) {
          ref.read(classicTicTacToeProvider.notifier).changeStrategy(strategy);
          if (Navigator.of(context).canPop()) {
            Navigator.pop(context);
          }
        },
        onInfoPressed: (strategy) {
          final strategyProgress = ref.read(globalProgressProvider.notifier).getProgress(strategy);
          if (strategyProgress.isDefeated) {
            DialogUtils.showStrategyRevealDialog(
              context: context,
              strategy: strategy,
              themeColor: Colors.blue,
              onReplay: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                ref.read(classicTicTacToeProvider.notifier).changeStrategy(strategy);
                ref.read(classicTicTacToeProvider.notifier).reset();
              },
              onChangeStrategy: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              gameMode: '/classic',
            );
          }
        },
        gameMode: 'classic',
      ),
      body: SingleChildScrollView(
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Titolo
              const Padding(
                padding: EdgeInsets.all(30.0),
                child: Text(
                  'Modalità Classica',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
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
                child: Text(
                  game.currentPlayer == Player.human ? 'Tocca a te (X)' : 'Turno avversario (O)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: game.currentPlayer == Player.human ? Colors.blue : Colors.red,
                  ),
                ),
              ),

              // Griglia Tic Tac Toe (visibile solo dopo aver iniziato)
              Container(
                height: 300,
                margin: const EdgeInsets.all(40),
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
                margin: const EdgeInsets.all(40),
                child: GameTheoryHint(
                  gameMode: 'Classic Tic Tac Toe',
                  title: 'Equilibrio Perfetto nei Sottogiochi',
                  concept: 'Questo è un gioco sequenziale a somma zero con informazione completa. È un esempio perfetto di come l\'equilibrio di Nash funzioni nei giochi sequenziali.',
                  learning: 'Imparerai che quando entrambi i giocatori giocano razionalmente, il risultato è sempre un pareggio. Questo dimostra il concetto di "strategia dominante" e come l\'equilibrio perfetto funziona.',
                  experience: 'Sperimenterai come le strategie ottimali portano sempre allo stesso risultato. Capirai che in alcuni giochi, giocare perfettamente significa che nessuno può vincere!',
                  themeColor: Colors.blue,
                ),
              ),
            ], // chiude children del Column
          ), // chiude Column
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
                ref.read(classicTicTacToeProvider.notifier).makeHumanMove(index);
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
                          fontSize: 65,
                          fontWeight: FontWeight.bold,
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