import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';

/// Tipi di medaglia militare
enum MedalType {
  bronze,    // Bronzo - primo completamento
  silver,    // Argento - competenza dimostrata  
  gold,      // Oro - maestria
  platinum,  // Platino - eccellenza
  diamond,   // Diamante - leggendario
}

/// Achievement per una specifica modalità e difficoltà
class Achievement {
  final String id;
  final String gameMode;
  final AIDifficulty difficulty;
  final String strategyName;
  final MedalType medal;
  final int victoriesCount;
  final DateTime earnedAt;
  final String description;

  const Achievement({
    required this.id,
    required this.gameMode,
    required this.difficulty,
    required this.strategyName,
    required this.medal,
    required this.victoriesCount,
    required this.earnedAt,
    required this.description,
  });

  Achievement copyWith({
    MedalType? medal,
    int? victoriesCount,
    DateTime? earnedAt,
  }) {
    return Achievement(
      id: id,
      gameMode: gameMode,
      difficulty: difficulty,
      strategyName: strategyName,
      medal: medal ?? this.medal,
      victoriesCount: victoriesCount ?? this.victoriesCount,
      earnedAt: earnedAt ?? this.earnedAt,
      description: description,
    );
  }
}

/// Stato generale del giocatore
class GlobalPlayerState {
  final Map<String, Achievement> achievements;
  final int totalScore;
  final AIDifficulty unlockedDifficulty;
  final Map<String, Map<AIDifficulty, int>> modeProgress; // mode -> difficulty -> defeated bots count
  final String currentRank;
  
  const GlobalPlayerState({
    this.achievements = const {},
    this.totalScore = 0,
    this.unlockedDifficulty = AIDifficulty.easy,
    this.modeProgress = const {},
    this.currentRank = 'Recluta',
  });

  GlobalPlayerState copyWith({
    Map<String, Achievement>? achievements,
    int? totalScore,
    AIDifficulty? unlockedDifficulty,
    Map<String, Map<AIDifficulty, int>>? modeProgress,
    String? currentRank,
  }) {
    return GlobalPlayerState(
      achievements: achievements ?? this.achievements,
      totalScore: totalScore ?? this.totalScore,
      unlockedDifficulty: unlockedDifficulty ?? this.unlockedDifficulty,
      modeProgress: modeProgress ?? this.modeProgress,
      currentRank: currentRank ?? this.currentRank,
    );
  }
}

/// Provider globale per gestire achievement e progressi
class GlobalProgressNotifier extends StateNotifier<GlobalPlayerState> {
  GlobalProgressNotifier() : super(const GlobalPlayerState());

  /// Registra una vittoria contro una strategia specifica
  void recordVictory({
    required String gameMode,
    required AIDifficulty difficulty,
    required String strategyName,
  }) {
    final achievementId = '${gameMode}_${difficulty.name}_$strategyName';
    final existing = state.achievements[achievementId];
    
    final newVictoryCount = (existing?.victoriesCount ?? 0) + 1;
    final medal = _calculateMedal(newVictoryCount);
    
    final achievement = Achievement(
      id: achievementId,
      gameMode: gameMode,
      difficulty: difficulty,
      strategyName: strategyName,
      medal: medal,
      victoriesCount: newVictoryCount,
      earnedAt: DateTime.now(),
      description: _getAchievementDescription(gameMode, strategyName, medal),
    );

    // Aggiorna achievements
    final newAchievements = Map<String, Achievement>.from(state.achievements);
    newAchievements[achievementId] = achievement;

    // Aggiorna progresso modalità
    final newModeProgress = Map<String, Map<AIDifficulty, int>>.from(state.modeProgress);
    newModeProgress[gameMode] ??= {};
    
    // Conta quanti bot sono stati sconfitti almeno una volta in questa difficoltà
    final defeatedBots = newAchievements.values
        .where((a) => a.gameMode == gameMode && a.difficulty == difficulty && a.victoriesCount > 0)
        .length;
    
    newModeProgress[gameMode]![difficulty] = defeatedBots;

    // Calcola nuovo score
    final newScore = _calculateTotalScore(newAchievements);
    
    // Determina difficoltà sbloccata
    final unlockedDifficulty = _calculateUnlockedDifficulty(newModeProgress);
    
    // Determina rank
    final currentRank = _calculateRank(newScore, newAchievements);

    state = state.copyWith(
      achievements: newAchievements,
      totalScore: newScore,
      unlockedDifficulty: unlockedDifficulty,
      modeProgress: newModeProgress,
      currentRank: currentRank,
    );
  }

  /// Calcola la medaglia in base al numero di vittorie
  MedalType _calculateMedal(int victories) {
    if (victories >= 10) return MedalType.diamond;
    if (victories >= 7) return MedalType.platinum;
    if (victories >= 5) return MedalType.gold;
    if (victories >= 3) return MedalType.silver;
    return MedalType.bronze;
  }

  /// Calcola il punteggio totale
  int _calculateTotalScore(Map<String, Achievement> achievements) {
    int score = 0;
    for (final achievement in achievements.values) {
      // Punti base per vittoria
      score += achievement.victoriesCount * 10;
      
      // Bonus per medaglia
      switch (achievement.medal) {
        case MedalType.bronze:
          score += 50;
          break;
        case MedalType.silver:
          score += 150;
          break;
        case MedalType.gold:
          score += 300;
          break;
        case MedalType.platinum:
          score += 500;
          break;
        case MedalType.diamond:
          score += 1000;
          break;
      }
      
      // Bonus per difficoltà
      switch (achievement.difficulty) {
        case AIDifficulty.easy:
          // Nessun bonus
          break;
        case AIDifficulty.medium:
          score += achievement.victoriesCount * 5;
          break;
        case AIDifficulty.hard:
          score += achievement.victoriesCount * 15;
          break;
      }
    }
    return score;
  }

  /// Determina quale difficoltà è sbloccata
  AIDifficulty _calculateUnlockedDifficulty(Map<String, Map<AIDifficulty, int>> modeProgress) {
    // Per sbloccare Medium: almeno 2 bot sconfitti su Easy in qualsiasi modalità
    bool canUnlockMedium = false;
    for (final modeDifficulties in modeProgress.values) {
      if ((modeDifficulties[AIDifficulty.easy] ?? 0) >= 2) {
        canUnlockMedium = true;
        break;
      }
    }
    
    if (!canUnlockMedium) return AIDifficulty.easy;
    
    // Per sbloccare Hard: almeno 2 bot sconfitti su Medium in qualsiasi modalità
    bool canUnlockHard = false;
    for (final modeDifficulties in modeProgress.values) {
      if ((modeDifficulties[AIDifficulty.medium] ?? 0) >= 2) {
        canUnlockHard = true;
        break;
      }
    }
    
    return canUnlockHard ? AIDifficulty.hard : AIDifficulty.medium;
  }

  /// Calcola il rank militare basato su score e achievement
  String _calculateRank(int score, Map<String, Achievement> achievements) {
    final goldMedals = achievements.values.where((a) => a.medal == MedalType.gold).length;
    final platinumMedals = achievements.values.where((a) => a.medal == MedalType.platinum).length;
    final diamondMedals = achievements.values.where((a) => a.medal == MedalType.diamond).length;
    
    if (diamondMedals >= 3) return 'Generale ★★★';
    if (diamondMedals >= 1 || platinumMedals >= 5) return 'Colonnello ★★';
    if (platinumMedals >= 2 || goldMedals >= 8) return 'Maggiore ★';
    if (goldMedals >= 4 || score >= 3000) return 'Capitano';
    if (goldMedals >= 2 || score >= 1500) return 'Tenente';
    if (score >= 800) return 'Sergente';
    if (score >= 400) return 'Caporale';
    if (score >= 100) return 'Soldato';
    return 'Recluta';
  }

  /// Genera descrizione achievement
  String _getAchievementDescription(String gameMode, String strategyName, MedalType medal) {
    final modeNames = {
      'classic': 'Classic',
      'coop': 'Co-op',
      'nebel': 'Nebel',
      'guess': 'Guess',
      'simultaneous': 'Simultaneous',
    };
    
    final medalDescriptions = {
      MedalType.bronze: 'Prima vittoria',
      MedalType.silver: 'Competenza dimostrata',
      MedalType.gold: 'Maestria tattica',
      MedalType.platinum: 'Eccellenza strategica',
      MedalType.diamond: 'Leggenda militare',
    };
    
    return 'Sconfitto $strategyName in ${modeNames[gameMode] ?? gameMode} - ${medalDescriptions[medal]}';
  }

  /// Verifica se una difficoltà è sbloccata
  bool isDifficultyUnlocked(AIDifficulty difficulty) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return true; // Sempre sbloccato
      case AIDifficulty.medium:
        return state.unlockedDifficulty == AIDifficulty.medium || 
               state.unlockedDifficulty == AIDifficulty.hard;
      case AIDifficulty.hard:
        return state.unlockedDifficulty == AIDifficulty.hard;
    }
  }

  /// Ottieni achievement per modalità e difficoltà
  List<Achievement> getAchievementsFor({
    String? gameMode,
    AIDifficulty? difficulty,
  }) {
    return state.achievements.values.where((achievement) {
      bool matchMode = gameMode == null || achievement.gameMode == gameMode;
      bool matchDifficulty = difficulty == null || achievement.difficulty == difficulty;
      return matchMode && matchDifficulty;
    }).toList();
  }

  /// Ottieni statistiche generali
  Map<String, dynamic> getGeneralStats() {
    final achievements = state.achievements.values.toList();
    return {
      'totalAchievements': achievements.length,
      'totalScore': state.totalScore,
      'currentRank': state.currentRank,
      'unlockedDifficulty': state.unlockedDifficulty,
      'bronzeMedals': achievements.where((a) => a.medal == MedalType.bronze).length,
      'silverMedals': achievements.where((a) => a.medal == MedalType.silver).length,
      'goldMedals': achievements.where((a) => a.medal == MedalType.gold).length,
      'platinumMedals': achievements.where((a) => a.medal == MedalType.platinum).length,
      'diamondMedals': achievements.where((a) => a.medal == MedalType.diamond).length,
    };
  }
}

/// Provider globale per i progressi
final globalProgressProvider = StateNotifierProvider<GlobalProgressNotifier, GlobalPlayerState>((ref) {
  return GlobalProgressNotifier();
});