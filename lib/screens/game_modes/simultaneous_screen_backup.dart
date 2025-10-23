import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/simultaneous_provider.dart';
import '../../models/simultaneous_game.dart';
import '../../models/simultaneous_strategy_progress.dart';
import '../../strategies/simultaneous/simultaneous_ai_strategy.dart';
import '../../widgets/game_theory_hint.dart';
import '../../widgets/simultaneous_strategy_drawer.dart';
import '../../utils/dialog_utils.dart';

class SimultaneousScreen extends ConsumerStatefulWidget {
  const SimultaneousScreen({super.key});

  @override
  ConsumerState<SimultaneousScreen> createState() => _SimultaneousScreenState();
}

class _SimultaneousScreenState extends ConsumerState<SimultaneousScreen>
    with TickerProviderStateMixin {
  late AnimationController _flashController;
  late AnimationController _revealController;
  late AnimationController _gridController;
  late Animation<double> _flashAnimation;
  late Animation<double> _revealAnimation; 
  late Animation<double> _gridAnimation;
  
  SimultaneousGameStatus? _lastGameStatus;
  bool _isDrawerOpen = false;
  bool _isFirstTime = true;
  bool _isGameInProgress = false;

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

    _gridController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    _gridAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gridController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _flashController.dispose();
    _revealController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  void _openDrawer() {
    setState(() {
      _isDrawerOpen = true;
    });
  }

  void _closeDrawer() {
    setState(() {
      _isDrawerOpen = false;
    });
  }

  void _selectStrategy(SimultaneousAIStrategy strategy) {
    if (mounted) {
      ref.read(simultaneousTicTacToeProvider.notifier).changeStrategy(strategy);
      _closeDrawer();
      
      setState(() {
        _isFirstTime = false;
        _isGameInProgress = false;
      });
      
      // Anima la griglia
      _gridController.forward();
    }
  }

  void _processGameResult(SimultaneousGameStatus status) {
    if (mounted) {
      final notifier = ref.read(simultaneousTicTacToeProvider.notifier);
      final strategyProgress = notifier.strategyProgress;
      final currentStrategy = notifier.currentStrategy;
      
      // Processa il risultato
      notifier.processGameResult(status);
      
      // Mostra dialog appropriato
      if (status == SimultaneousGameStatus.humanWon && 
          strategyProgress.isDefeated(currentStrategy)) {
        // Prima sconfitta di questa strategia - mostra rivelazione
        _showStrategyRevealDialog(currentStrategy);
      } else {
        // Dialog normale di fine partita
        _showGameOverDialog(status);
      }
    }
  }

  void _showGameOverDialog(SimultaneousGameStatus status) {
    String statusKey;
    switch (status) {
      case SimultaneousGameStatus.humanWon:
        statusKey = 'won';
        break;
      case SimultaneousGameStatus.aiWon:
        statusKey = 'lost';
        break;
      case SimultaneousGameStatus.tie:
        statusKey = 'tie';
        break;
      default:
        return;
    }

    final messages = DialogUtils.getGameOverMessages(
      gameMode: 'simultaneous',
      status: statusKey,
    );

    DialogUtils.showGameOverDialog(
      context: context,
      title: messages['title']!,
      message: messages['message']!,
      themeColor: DialogUtils.getThemeColor('simultaneous'),
      titleIcon: DialogUtils.getResultIcon(statusKey),
      onReplay: () {
        if (mounted) {
          ref.read(simultaneousTicTacToeProvider.notifier).resetGame();
          setState(() {
            _isGameInProgress = false;
            _lastGameStatus = null;
          });
        }
      },
    );
  }

  void _showStrategyRevealDialog(SimultaneousAIStrategy strategy) {
    final strategyProgress = ref.read(simultaneousTicTacToeProvider.notifier).strategyProgress;
    final impl = SimultaneousAIStrategyFactory.createStrategy(strategy);

    DialogUtils.showStrategyRevealDialog(
      context: context,
      strategyName: impl.displayName,
      strategyDescription: impl.description,
      counterStrategy: strategyProgress.getCounterStrategy(strategy),
      themeColor: DialogUtils.getThemeColor('simultaneous'),
      gameMode: 'Simultaneous',
      onReplay: () {
        if (mounted) {
          ref.read(simultaneousTicTacToeProvider.notifier).resetGame();
          setState(() {
            _isGameInProgress = false;
            _lastGameStatus = null;
          });
        }
      },
      onChangeStrategy: () {
        if (mounted) {
          _openDrawer();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(simultaneousTicTacToeProvider);
    final notifier = ref.read(simultaneousTicTacToeProvider.notifier);
    
    // Aggiorna stato gioco
    _isGameInProgress = !_isFirstTime && game.status == SimultaneousGameStatus.selectingMoves;
    
    // Mostra dialog quando il gioco finisce (solo se è un nuovo stato finale)  
    if (mounted && 
        _lastGameStatus != game.status &&
        game.status != SimultaneousGameStatus.selectingMoves &&
        game.status != SimultaneousGameStatus.revealing) {
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _processGameResult(game.status);
        }
      });
    } else if (mounted && 
               _lastGameStatus != game.status &&
               game.status == SimultaneousGameStatus.revealing) {
      _revealController.forward().then((_) {
        if (mounted) {
          _revealController.reset();
        }
      });
    }
    _lastGameStatus = game.status;

    // Costruisco la lista dei children dello Stack
    List<Widget> stackChildren = [
      // Contenuto principale
      SafeArea(
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Titolo
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Tactica - Simultaneo',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
                
                // Header info / indicatore turno
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
                            'Modalità Simultanea',
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

                // Indicatore strategia corrente (non modificabile durante gioco)
                if (!_isFirstTime && _isGameInProgress)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.flash_on, color: Colors.orange.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'AI: ${notifier.strategyProgress.getDisplayName(notifier.currentStrategy)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
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
                            Icons.flash_on,
                            size: 80,
                            color: Colors.orange.shade300,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Scegli una Strategia Simultanea!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Premi il menu in alto a destra per iniziare',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Freccia che punta verso il menu hamburger
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Qui! ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade600,
                                ),
                              ),
                              Icon(
                                Icons.arrow_upward,
                                color: Colors.orange.shade600,
                                size: 24,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // Pulsante conferma (solo se ha selezionato una mossa)
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
                              if (mounted) {
                                ref.read(simultaneousTicTacToeProvider.notifier).confirmMove();
                                _flashController.forward().then((_) {
                                  if (mounted) {
                                    _flashController.reset();
                                  }
                                });
                              }
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
              ], // chiude children del Column
            ), // chiude Column
          ), // chiude Container  
        ), // chiude SingleChildScrollView
      ), // chiude SafeArea
    ];

    // Aggiungo l'overlay del drawer se aperto
    if (_isDrawerOpen) {
      stackChildren.add(
        GestureDetector(
          onTap: _closeDrawer,
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
      );
    }
    
    // Aggiungo sempre il drawer scorrevole
    stackChildren.add(
      AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        top: 0,
        right: _isDrawerOpen ? 0 : -350,
        bottom: 0,
        width: 350,
        child: Material(
          elevation: 16,
          child: SimultaneousStrategyDrawer(
            currentStrategy: notifier.currentStrategy,
            progress: notifier.strategyProgress,
            onStrategySelected: _selectStrategy,
            onClose: _closeDrawer,
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simultaneous Tic Tac Toe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isDrawerOpen ? Icons.close : Icons.menu,
              color: Colors.orange.shade700,
            ),
            onPressed: () {
              if (_isDrawerOpen) {
                _closeDrawer();
              } else {
                _openDrawer();
              }
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: stackChildren,
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

  Widget _buildGrid_OLD_DELETE_ME(SimultaneousTicTacToeGame game) {
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
          gridDelegate: const SliverGridDelegateTEST_OLD(
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
                            if (mounted) {
                              ref.read(simultaneousTicTacToeProvider.notifier).confirmMove();
                              _flashController.forward().then((_) {
                                if (mounted) {
                                  _flashController.reset();
                                }
                              });
                            }
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
              if (mounted) {
                ref.read(simultaneousTicTacToeProvider.notifier).selectMove(index);
              }
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
    );
  }
}