import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/prisoner_dilemma_game.dart';
import '../providers/prisoner_dilemma_provider.dart';

class PlayGameScreen extends ConsumerStatefulWidget {
  const PlayGameScreen({super.key});

  @override
  ConsumerState<PlayGameScreen> createState() => _PlayGameScreenState();
}

class _PlayGameScreenState extends ConsumerState<PlayGameScreen> with TickerProviderStateMixin {
  bool _showRoundResult = false;
  GameRound? _lastRound;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(prisonerDilemmaProvider);
    
    // Se il gioco è finito, vai alla schermata dei risultati
    if (game.isGameFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/play/results');
      });
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
                // Header con progresso
                _buildHeader(game),
                
                const SizedBox(height: 30),

                // Punteggio cumulativo
                _buildScoreBoard(game),

                const SizedBox(height: 40),

                // Area principale del gioco
                Expanded(
                  child: _showRoundResult && _lastRound != null
                      ? _buildRoundResult(_lastRound!)
                      : _buildGameArea(game),
                ),

                const SizedBox(height: 20),

                // Pulsanti azione (solo se non stiamo mostrando risultati)
                if (!_showRoundResult) _buildActionButtons(game),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(PrisonerDilemmaGame game) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _showExitDialog(),
          icon: const Icon(Icons.arrow_back, size: 30),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Turno ${game.currentRound}/${game.settings.totalRounds}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              Text(
                'vs ${game.settings.botStrategy.emoji} ${game.settings.botStrategy.displayName}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        // Barra di progresso
        Container(
          width: 100,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (game.currentRound - 1) / game.settings.totalRounds,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreBoard(PrisonerDilemmaGame game) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Tu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${game.totalPlayerScore}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 2,
              height: 50,
              color: Colors.grey.shade300,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    game.settings.botStrategy.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${game.totalBotScore}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
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

  Widget _buildGameArea(PrisonerDilemmaGame game) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology,
              size: 80,
              color: Colors.blue.shade600,
            ),
            
            const SizedBox(height: 30),
            
            Text(
              'L\'avversario sceglie in segreto.',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            Text(
              'Tu scegli:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(PrisonerDilemmaGame game) {
    return Row(
      children: [
        // Cooperare
        Expanded(
          child: Container(
            height: 80,
            margin: const EdgeInsets.only(right: 10),
            child: ElevatedButton(
              onPressed: () => _makeChoice(PlayerAction.cooperate),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🟢',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Cooperare',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Tradire
        Expanded(
          child: Container(
            height: 80,
            margin: const EdgeInsets.only(left: 10),
            child: ElevatedButton(
              onPressed: () => _makeChoice(PlayerAction.betray),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🔴',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Tradire',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoundResult(GameRound round) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Risultato Turno ${round.roundNumber}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),

              const SizedBox(height: 30),

              // Azioni scelte
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Hai ${round.playerAction == PlayerAction.cooperate ? 'cooperato' : 'tradito'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          round.playerAction.emoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 80,
                    color: Colors.grey.shade300,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'L\'avversario ha ${round.botAction == PlayerAction.cooperate ? 'cooperato' : 'tradito'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          round.botAction.emoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Payoff
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  'Risultato: (${round.playerPayoff}, ${round.botPayoff})',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Pulsante continua
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _continueToNextRound,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Continua',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _makeChoice(PlayerAction action) {
    ref.read(prisonerDilemmaProvider.notifier).playRound(action);
    
    // Mostra il risultato del round
    final game = ref.read(prisonerDilemmaProvider);
    if (game.rounds.isNotEmpty) {
      setState(() {
        _showRoundResult = true;
        _lastRound = game.rounds.last;
      });
      _animationController.forward();
    }
  }

  void _continueToNextRound() {
    setState(() {
      _showRoundResult = false;
      _lastRound = null;
    });
    _animationController.reset();
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abbandonare la partita?'),
        content: const Text('Tutti i progressi di questa partita andranno persi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/play');
            },
            child: const Text('Abbandona'),
          ),
        ],
      ),
    );
  }
}