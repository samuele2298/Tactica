import 'dart:math';

import 'package:tacticafe/models/tic_tac_toe_game.dart';
import 'package:tacticafe/strategies/ai_strategy.dart';

class RandomStrategy extends AIStrategyImplementation {
  @override
  String get displayName => 'Random';

  @override
  String get description =>
      'Gioca una mossa casuale tra quelle disponibili';

  @override
  String get counterName =>
      'Gioca Solido';

  @override
  String get counterDescription =>
      'Gioca una mossa casuale tra quelle disponibili';

  @override
  int inferMove(TicTacToeGame game) {
    final moves = game.getAvailableCells();

    final random = Random();
    return moves[random.nextInt(moves.length)];
  }
}