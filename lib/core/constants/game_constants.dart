/// Common constants for Tic Tac Toe gameplay across all modes
/// Shared logic, patterns, and configurations

import 'package:flutter/material.dart';

/// Winning patterns for 3x3 tic tac toe grid
class TicTacToePatterns {
  /// All possible winning combinations (indices 0-8)
  static const List<List<int>> winningPatterns = [
    // Righe (Rows)
    [0, 1, 2], [3, 4, 5], [6, 7, 8],
    // Colonne (Columns)  
    [0, 3, 6], [1, 4, 7], [2, 5, 8],
    // Diagonali (Diagonals)
    [0, 4, 8], [2, 4, 6]
  ];
  
  /// Corner positions on the grid
  static const List<int> corners = [0, 2, 6, 8];
  
  /// Edge/side positions on the grid
  static const List<int> edges = [1, 3, 5, 7];
  
  /// Center position
  static const int center = 4;
  
  /// All positions in grid
  static const List<int> allPositions = [0, 1, 2, 3, 4, 5, 6, 7, 8];
}

/// Common difficulty levels across all game modes
enum GameDifficulty {
  easy('Facile'),
  medium('Medio'),
  hard('Difficile');
  
  const GameDifficulty(this.displayName);
  final String displayName;
}

/// Theme colors for different game modes
class GameModeColors {
  static const Map<String, List<Color>> gradients = {
    'classic': [Color(0xFF1976D2), Color(0xFF7B1FA2)], // blue to purple
    'simultaneous': [Color(0xFFFF9800), Color(0xFFFF5722)], // orange to deep orange
    'coop': [Color(0xFF4CAF50), Color(0xFF8BC34A)], // green to light green
    'nebel': [Color(0xFF7B1FA2), Color(0xFF4A148C)], // purple to dark purple
    'guess': [Color(0xFFFF9800), Color(0xFFE65100)], // orange to deep orange
  };
  
  static const Map<String, Color> primaryColors = {
    'classic': Color(0xFF1976D2),
    'simultaneous': Color(0xFFFF9800),
    'coop': Color(0xFF4CAF50),
    'nebel': Color(0xFF7B1FA2),
    'guess': Color(0xFFFF9800),
  };
  
  static const Map<String, IconData> icons = {
    'classic': Icons.psychology,
    'simultaneous': Icons.flash_on,
    'coop': Icons.group,
    'nebel': Icons.visibility_off,
    'guess': Icons.casino,
  };
}

/// Common animation durations
class GameAnimations {
  static const Duration moveDelay = Duration(milliseconds: 800);
  static const Duration aiThinkTime = Duration(milliseconds: 1200);
  static const Duration dialogDelay = Duration(milliseconds: 500);
  static const Duration transitionDuration = Duration(milliseconds: 300);
}

/// Grid layout constants
class GridConstants {
  static const int gridSize = 3;
  static const int totalCells = 9;
  static const double cellAspectRatio = 1.0;
  static const double gridPadding = 16.0;
  static const double cellSpacing = 8.0;
}