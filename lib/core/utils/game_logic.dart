/// Common utility functions for Tic Tac Toe game logic
/// Shared across all game modes for consistency

import '../constants/game_constants.dart';

/// Utility class for common tic tac toe operations
class TicTacToeUtils {
  /// Check if a move would result in a win for the given player
  static bool wouldWin<T>(List<T> board, int moveIndex, T player, T emptyValue) {
    // Create a copy of the board with the hypothetical move
    final testBoard = List<T>.from(board);
    testBoard[moveIndex] = player;
    
    // Check if this move creates a winning pattern
    return checkWinner(testBoard, emptyValue) == player;
  }
  
  /// Check the current winner of the board
  static T? checkWinner<T>(List<T> board, T emptyValue) {
    for (final pattern in TicTacToePatterns.winningPatterns) {
      final [a, b, c] = pattern;
      if (board[a] != emptyValue &&
          board[a] == board[b] &&
          board[b] == board[c]) {
        return board[a];
      }
    }
    return null;
  }
  
  /// Get the winning line if there is a winner
  static List<int>? getWinningLine<T>(List<T> board, T emptyValue) {
    for (final pattern in TicTacToePatterns.winningPatterns) {
      final [a, b, c] = pattern;
      if (board[a] != emptyValue &&
          board[a] == board[b] &&
          board[b] == board[c]) {
        return pattern;
      }
    }
    return null;
  }
  
  /// Check if the board is full (tie condition)
  static bool isBoardFull<T>(List<T> board, T emptyValue) {
    return board.every((cell) => cell != emptyValue);
  }
  
  /// Get all available moves on the board
  static List<int> getAvailableMoves<T>(List<T> board, T emptyValue) {
    final availableMoves = <int>[];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == emptyValue) {
        availableMoves.add(i);
      }
    }
    return availableMoves;
  }
  
  /// Find immediate winning moves for a player
  static List<int> findWinningMoves<T>(List<T> board, T player, T emptyValue) {
    final winningMoves = <int>[];
    final availableMoves = getAvailableMoves(board, emptyValue);
    
    for (final move in availableMoves) {
      if (wouldWin(board, move, player, emptyValue)) {
        winningMoves.add(move);
      }
    }
    
    return winningMoves;
  }
  
  /// Find blocking moves (opponent's winning moves)
  static List<int> findBlockingMoves<T>(List<T> board, T player, T opponent, T emptyValue) {
    return findWinningMoves(board, opponent, emptyValue);
  }
  
  /// Convert grid index to row/column coordinates
  static Map<String, int> indexToCoordinates(int index) {
    return {
      'row': index ~/ GridConstants.gridSize,
      'col': index % GridConstants.gridSize,
    };
  }
  
  /// Convert row/column coordinates to grid index
  static int coordinatesToIndex(int row, int col) {
    return row * GridConstants.gridSize + col;
  }
  
  /// Check if a position is a corner
  static bool isCorner(int index) {
    return TicTacToePatterns.corners.contains(index);
  }
  
  /// Check if a position is an edge/side
  static bool isEdge(int index) {
    return TicTacToePatterns.edges.contains(index);
  }
  
  /// Check if a position is the center
  static bool isCenter(int index) {
    return index == TicTacToePatterns.center;
  }
  
  /// Get strategic priority positions (center > corners > edges)
  static List<int> getStrategicMoves<T>(List<T> board, T emptyValue) {
    final available = getAvailableMoves(board, emptyValue);
    final prioritized = <int>[];
    
    // Center first
    if (available.contains(TicTacToePatterns.center)) {
      prioritized.add(TicTacToePatterns.center);
    }
    
    // Then corners
    for (final corner in TicTacToePatterns.corners) {
      if (available.contains(corner)) {
        prioritized.add(corner);
      }
    }
    
    // Finally edges
    for (final edge in TicTacToePatterns.edges) {
      if (available.contains(edge)) {
        prioritized.add(edge);
      }
    }
    
    return prioritized;
  }
}