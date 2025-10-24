import 'package:tacticafe/models/enums.dart';
import 'package:tacticafe/models/tic_tac_toe_game.dart';
import 'package:tacticafe/strategies/classic/center_then_random.dart';
import 'package:tacticafe/strategies/classic/random.dart' show RandomStrategy;

abstract class AIStrategyImplementation {
  String get displayName;
  String get description;
  String get counterName; 
  String get counterDescription;

  /// Restituisce l'indice della mossa migliore dato il gioco corrente
  int inferMove(TicTacToeGame game);
}


class AIStrategyFactory {
  static AIStrategyImplementation createStrategy(AIStrategy strategy) {
    switch (strategy) {
      case AIStrategy.classic_easy1:
        return CenterThenRandomStrategy();
      case AIStrategy.classic_easy2:
        return RandomStrategy();
      case AIStrategy.classic_easy3:
        return RandomStrategy();
      case AIStrategy.classic_medium1:
        return RandomStrategy();
      case AIStrategy.classic_medium2:
        return RandomStrategy();
      case AIStrategy.classic_medium3:
        return RandomStrategy();
      case AIStrategy.classic_hard1:
        return RandomStrategy();
      case AIStrategy.classic_hard2:
        return RandomStrategy();
      case AIStrategy.classic_hard3:
        return RandomStrategy();  
      // Altre strategie...
      default:
        return RandomStrategy();
    }
  }
}

