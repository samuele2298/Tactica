import 'dart:math';

import 'package:tacticafe/models/tic_tac_toe_game.dart';
import 'package:tacticafe/strategies/ai_strategy.dart';

class CenterThenRandomStrategy extends AIStrategyImplementation {
  @override
  String get displayName => 'Center Then Random';

  @override
  String get description =>
      'Se possibile prende il centro, altrimenti mossa casuale tra disponibili';


  @override
  String get counterName =>
      'Gioca Solido';

  @override
  String get counterDescription =>
      'Gioca una mossa casuale tra quelle disponibili';

  @override
  int inferMove(TicTacToeGame game) {
    final moves = game.getAvailableCells();

    // 1️⃣ Centro se libero
    if (moves.contains(4)) return 4;

    // 2️⃣ Altrimenti casuale
    final random = Random();
    return moves[random.nextInt(moves.length)];
  }
}