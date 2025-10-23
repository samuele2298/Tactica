/// Core interfaces for strategy system across all game modes
/// Provides common structure for AI strategies, progress tracking, and drawer configuration

/// Generic interface for AI strategies across all game modes
abstract class GameStrategy {
  /// Display name of the strategy
  String get name;
  
  /// Detailed description of the strategy behavior
  String get description;
  
  /// Difficulty level (Easy, Medium, Hard)
  String get difficulty;
}

/// Generic interface for progress tracking across all game modes  
abstract class GameProgress {
  /// Success rate as formatted percentage string
  String get successRate;
  
  /// Detailed statistics string for display
  String get detailedStats;
  
  /// Update progress with game result
  void updateStats({required Map<String, dynamic> gameResult});
  
  /// Reset all progress statistics
  void reset();
  
  /// Convert to map for serialization
  Map<String, dynamic> toMap();
}

/// Generic interface for strategy counter-advice
abstract class StrategyAdvice {
  /// Get basic counter-strategy for a given strategy name
  String getCounterStrategy(String strategyName);
  
  /// Get multiple detailed counter-strategies for advanced strategies
  List<String> getMultipleCounterStrategies(String strategyName);
}

/// Drawer configuration interface
abstract class DrawerConfiguration {
  /// Title displayed in drawer header
  String get title;
  
  /// Icon for drawer header
  dynamic get headerIcon;
  
  /// Primary color for drawer theme
  dynamic get primaryColor;
  
  /// Secondary/accent color for drawer
  dynamic get accentColor;
  
  /// Game mode identifier
  String get gameMode;
}