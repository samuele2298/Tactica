import 'package:tacticafe/strategies/ai_strategy.dart';

enum AIDifficulty { easy, medium, hard }
extension AIDifficultyExtension on AIDifficulty {
  String get displayName {
    switch (this) {
      case AIDifficulty.easy:
        return 'Facile';
      case AIDifficulty.medium:
        return 'Medio';
      case AIDifficulty.hard:
        return 'Difficile';
    }
  }

  String get description {
    switch (this) {
      case AIDifficulty.easy:
        return 'Pattern semplici e riconoscibili';
      case AIDifficulty.medium:
        return 'Strategia tattica con alcune debolezze';
      case AIDifficulty.hard:
        return 'Gioco avanzato e adattivo';
    }
  }
}

enum AIMode { classic, bluff, simultaneous, async, nebel }


enum AIStrategy {
  // ================= CLASSIC =================
  classic_easy1,
  classic_easy2,
  classic_easy3,
  classic_medium1,
  classic_medium2,
  classic_medium3,
  classic_hard1,
  classic_hard2,
  classic_hard3,

  // ================= BLUFF =================
  bluff_easy1,
  bluff_easy2,
  bluff_easy3,
  bluff_medium1,
  bluff_medium2,
  bluff_medium3,
  bluff_hard1,
  bluff_hard2,
  bluff_hard3,

  // ================= NEBEL =================
  nebel_easy1,
  nebel_easy2,
  nebel_easy3,
  nebel_medium1,
  nebel_medium2,
  nebel_medium3,
  nebel_hard1,
  nebel_hard2,
  nebel_hard3,

  // ================= SIMULTANEOUS =================
  simultaneous_easy1,
  simultaneous_easy2,
  simultaneous_easy3,
  simultaneous_medium1,
  simultaneous_medium2,
  simultaneous_medium3,
  simultaneous_hard1,
  simultaneous_hard2,
  simultaneous_hard3,

  // ================= ASYNC =================
  async_easy1,
  async_easy2,
  async_easy3,
  async_medium1,
  async_medium2,
  async_medium3,
  async_hard1,
  async_hard2,
  async_hard3,
}
extension AIStrategyExtension on AIStrategy {
  AIMode get mode {
    final name = toString().split('.').last;
    if (name.startsWith('classic')) return AIMode.classic;
    if (name.startsWith('bluff')) return AIMode.bluff;
    if (name.startsWith('simultaneous')) return AIMode.simultaneous;
    if (name.startsWith('async')) return AIMode.async;
    if (name.startsWith('nebel')) return AIMode.nebel;
    return AIMode.classic;
  }

  AIDifficulty get difficulty {
    final name = toString().split('.').last;
    if (name.contains('easy')) return AIDifficulty.easy;
    if (name.contains('medium')) return AIDifficulty.medium;
    if (name.contains('hard')) return AIDifficulty.hard;
    return AIDifficulty.easy;
  }
}

extension AIStrategyInfo on AIStrategy {
  /// Restituisce l'oggetto della strategia
  AIStrategyImplementation get implementation {
    return AIStrategyFactory.createStrategy(this);
  }

  /// Nome da mostrare
  String get displayName => implementation.displayName;

  /// Descrizione della strategia
  String get description => implementation.description;

  /// Spiegazione di come battere la strategia
  String get counterName => implementation.counterName;

  /// Spiegazione di come battere la strategia
  String get counterDescription => implementation.counterDescription;
}