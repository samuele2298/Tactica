import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tacticafe/models/enums.dart';
import '../models/tic_tac_toe_game.dart';

class ClassicTicTacToeNotifier extends StateNotifier<TicTacToeGame> {
  ClassicTicTacToeNotifier({AIStrategy strategy = AIStrategy.classic_easy1})
      : _currentStrategy = strategy,
        super(TicTacToeGame.initial(aiStrategy: strategy));

  AIStrategy _currentStrategy;

  // Getter per la strategia corrente
  AIStrategy get currentStrategy => _currentStrategy;

  /// Cambia strategia AI e resetta il gioco
  void changeStrategy(AIStrategy strategy) {
    _currentStrategy = strategy;
    reset(strategy: strategy);
  }

  /// Mossa dell'umano
  void makeHumanMove(int index) {
    state = state.makeHumanMove(index);
    state = state.makeAIMove();
  }

  /// Reset del gioco
  void reset({AIStrategy? strategy}) {
    state = state.reset(aiStrategy: strategy ?? _currentStrategy);
  }
}

// Provider per la modalità classica
final classicTicTacToeProvider =
    StateNotifierProvider<ClassicTicTacToeNotifier, TicTacToeGame>((ref) {
  return ClassicTicTacToeNotifier();
});
