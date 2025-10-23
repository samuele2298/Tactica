/// Base strategy interfaces and common implementations
/// Shared foundation for all game mode strategies

import '../../core/interfaces/game_interfaces.dart';
import '../../core/constants/game_constants.dart';
import '../../core/utils/game_logic.dart';

/// Base interface for all AI strategies across game modes
abstract class BaseAIStrategy implements GameStrategy {
  /// Difficulty level of this strategy
  GameDifficulty get difficultyLevel;
  
  @override
  String get difficulty => difficultyLevel.displayName;
}

/// Common strategy behaviors that can be mixed into different implementations
mixin StrategicBehaviors {
  /// Find immediate winning moves
  List<int> findWinningMoves<T>(List<T> board, T player, T emptyValue) {
    return TicTacToeUtils.findWinningMoves(board, player, emptyValue);
  }
  
  /// Find moves that block opponent's wins
  List<int> findBlockingMoves<T>(List<T> board, T player, T opponent, T emptyValue) {
    return TicTacToeUtils.findBlockingMoves(board, player, opponent, emptyValue);
  }
  
  /// Get strategically prioritized moves (center > corners > edges)
  List<int> getStrategicMoves<T>(List<T> board, T emptyValue) {
    return TicTacToeUtils.getStrategicMoves(board, emptyValue);
  }
  
  /// Get all available moves
  List<int> getAvailableMoves<T>(List<T> board, T emptyValue) {
    return TicTacToeUtils.getAvailableMoves(board, emptyValue);
  }
  
  /// Check if a move would result in a win
  bool wouldWin<T>(List<T> board, int moveIndex, T player, T emptyValue) {
    return TicTacToeUtils.wouldWin(board, moveIndex, player, emptyValue);
  }
}

/// Common implementation patterns for different difficulty levels
abstract class EasyStrategy extends BaseAIStrategy with StrategicBehaviors {
  @override
  GameDifficulty get difficultyLevel => GameDifficulty.easy;
}

abstract class MediumStrategy extends BaseAIStrategy with StrategicBehaviors {
  @override
  GameDifficulty get difficultyLevel => GameDifficulty.medium;
}

abstract class HardStrategy extends BaseAIStrategy with StrategicBehaviors {
  @override
  GameDifficulty get difficultyLevel => GameDifficulty.hard;
}

/// Factory interface for creating strategies
abstract class StrategyFactory<T extends BaseAIStrategy> {
  T createStrategy(dynamic strategyEnum);
  List<T> getAllStrategies();
}