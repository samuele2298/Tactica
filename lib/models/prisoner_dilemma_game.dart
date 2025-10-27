enum PlayerAction { cooperate, betray }

enum BotStrategy { 
  titForTat,     // Imita la mossa precedente
  alwaysBetray,  // Tradisce sempre  
  alwaysCooperate, // Coopera sempre
  random         // Scelta casuale
}

extension BotStrategyExtension on BotStrategy {
  String get displayName {
    switch (this) {
      case BotStrategy.titForTat:
        return 'Tit-for-Tat';
      case BotStrategy.alwaysBetray:
        return 'Always Betray';
      case BotStrategy.alwaysCooperate:
        return 'Always Cooperate';
      case BotStrategy.random:
        return 'Random';
    }
  }

  String get description {
    switch (this) {
      case BotStrategy.titForTat:
        return 'Imita la tua mossa precedente';
      case BotStrategy.alwaysBetray:
        return 'Tradisce sempre';
      case BotStrategy.alwaysCooperate:
        return 'Coopera sempre';
      case BotStrategy.random:
        return 'Scelta casuale';
    }
  }

  String get emoji {
    switch (this) {
      case BotStrategy.titForTat:
        return '🤖';
      case BotStrategy.alwaysBetray:
        return '😈';
      case BotStrategy.alwaysCooperate:
        return '😇';
      case BotStrategy.random:
        return '🎲';
    }
  }
}

extension PlayerActionExtension on PlayerAction {
  String get displayName {
    switch (this) {
      case PlayerAction.cooperate:
        return 'Cooperare';
      case PlayerAction.betray:
        return 'Tradire';
    }
  }

  String get emoji {
    switch (this) {
      case PlayerAction.cooperate:
        return '🟢';
      case PlayerAction.betray:
        return '🔴';
    }
  }
}

class GameRound {
  final int roundNumber;
  final PlayerAction playerAction;
  final PlayerAction botAction;
  final int playerPayoff;
  final int botPayoff;

  const GameRound({
    required this.roundNumber,
    required this.playerAction,
    required this.botAction,
    required this.playerPayoff,
    required this.botPayoff,
  });
}

class GameSettings {
  final BotStrategy botStrategy;
  final int totalRounds;
  final bool showPayoffNumbers;

  const GameSettings({
    required this.botStrategy,
    required this.totalRounds,
    this.showPayoffNumbers = true,
  });
}

class PrisonerDilemmaGame {
  final GameSettings settings;
  final List<GameRound> rounds;
  final int currentRound;
  final bool isGameFinished;
  final int totalPlayerScore;
  final int totalBotScore;

  const PrisonerDilemmaGame({
    required this.settings,
    this.rounds = const [],
    this.currentRound = 1,
    this.isGameFinished = false,
    this.totalPlayerScore = 0,
    this.totalBotScore = 0,
  });

  PrisonerDilemmaGame copyWith({
    GameSettings? settings,
    List<GameRound>? rounds,
    int? currentRound,
    bool? isGameFinished,
    int? totalPlayerScore,
    int? totalBotScore,
  }) {
    return PrisonerDilemmaGame(
      settings: settings ?? this.settings,
      rounds: rounds ?? this.rounds,
      currentRound: currentRound ?? this.currentRound,
      isGameFinished: isGameFinished ?? this.isGameFinished,
      totalPlayerScore: totalPlayerScore ?? this.totalPlayerScore,
      totalBotScore: totalBotScore ?? this.totalBotScore,
    );
  }

  /// Calcola il payoff per una combinazione di azioni
  /// Payoff standard: (3,3) cooperate/cooperate, (0,5) cooperate/betray, (5,0) betray/cooperate, (1,1) betray/betray
  static Map<String, int> getPayoffs(PlayerAction playerAction, PlayerAction botAction) {
    if (playerAction == PlayerAction.cooperate && botAction == PlayerAction.cooperate) {
      return {'player': 3, 'bot': 3};
    } else if (playerAction == PlayerAction.cooperate && botAction == PlayerAction.betray) {
      return {'player': 0, 'bot': 5};
    } else if (playerAction == PlayerAction.betray && botAction == PlayerAction.cooperate) {
      return {'player': 5, 'bot': 0};
    } else { // betray/betray
      return {'player': 1, 'bot': 1};
    }
  }

  /// Calcola la percentuale di cooperazione del giocatore
  double get playerCooperationRate {
    if (rounds.isEmpty) return 0.0;
    final cooperateCount = rounds.where((r) => r.playerAction == PlayerAction.cooperate).length;
    return cooperateCount / rounds.length;
  }

  /// Calcola la percentuale di cooperazione del bot
  double get botCooperationRate {
    if (rounds.isEmpty) return 0.0;
    final cooperateCount = rounds.where((r) => r.botAction == PlayerAction.cooperate).length;
    return cooperateCount / rounds.length;
  }

  /// Calcola il payoff medio del giocatore
  double get averagePlayerPayoff {
    if (rounds.isEmpty) return 0.0;
    return totalPlayerScore / rounds.length;
  }

  /// Calcola il payoff medio del bot
  double get averageBotPayoff {
    if (rounds.isEmpty) return 0.0;
    return totalBotScore / rounds.length;
  }
}

class GameAnalysis {
  final String summary;
  final String equilibriumAnalysis;
  final String suggestedLearningModule;
  final bool reachedStableEquilibrium;

  const GameAnalysis({
    required this.summary,
    required this.equilibriumAnalysis,
    required this.suggestedLearningModule,
    required this.reachedStableEquilibrium,
  });

  static GameAnalysis analyzeGame(PrisonerDilemmaGame game) {
    final playerCoopRate = game.playerCooperationRate;
    final botCoopRate = game.botCooperationRate;
    
    String summary;
    String equilibriumAnalysis;
    String suggestedModule;
    bool stableEquilibrium = false;

    // Analisi del comportamento del giocatore
    if (playerCoopRate > 0.7) {
      summary = "Hai adottato una strategia principalmente cooperativa. ";
    } else if (playerCoopRate < 0.3) {
      summary = "Hai adottato una strategia principalmente competitiva. ";
    } else {
      summary = "Hai alternato tra cooperazione e tradimento. ";
    }

    // Analisi dell'interazione
    if (botCoopRate > 0.7 && playerCoopRate > 0.7) {
      summary += "Entrambi avete mantenuto un alto livello di cooperazione.";
      equilibriumAnalysis = "Avete raggiunto un equilibrio cooperativo efficiente. Questo dimostra come la fiducia reciproca possa portare ai migliori risultati per entrambi.";
      suggestedModule = "Giochi ripetuti e fiducia";
      stableEquilibrium = true;
    } else if (botCoopRate < 0.3 && playerCoopRate < 0.3) {
      summary += "Entrambi avete scelto principalmente di tradire.";
      equilibriumAnalysis = "Avete raggiunto l'equilibrio di Nash: (Tradisci, Tradisci). Strategicamente razionale ma inefficiente per entrambi.";
      suggestedModule = "Equilibrio di Nash";
      stableEquilibrium = true;
    } else {
      summary += "Il gioco non ha raggiunto un equilibrio stabile: la fiducia si è rotta.";
      equilibriumAnalysis = "Le strategie hanno continuato a cambiare. Questo mostra l'importanza della reputazione nei giochi ripetuti.";
      suggestedModule = "Strategia dominante";
      stableEquilibrium = false;
    }

    // Analisi specifica per strategia bot
    switch (game.settings.botStrategy) {
      case BotStrategy.titForTat:
        if (playerCoopRate > 0.5) {
          equilibriumAnalysis += " Tit-for-Tat premia la cooperazione e punisce il tradimento.";
        }
        break;
      case BotStrategy.alwaysBetray:
        equilibriumAnalysis += " Contro un avversario che tradisce sempre, la strategia dominante è tradire.";
        suggestedModule = "Strategia dominante";
        break;
      case BotStrategy.alwaysCooperate:
        if (playerCoopRate < 0.5) {
          equilibriumAnalysis += " Hai sfruttato un avversario troppo cooperativo.";
        }
        break;
      case BotStrategy.random:
        equilibriumAnalysis += " Contro un avversario imprevedibile, è difficile sviluppare una strategia ottimale.";
        break;
    }

    return GameAnalysis(
      summary: summary,
      equilibriumAnalysis: equilibriumAnalysis,
      suggestedLearningModule: suggestedModule,
      reachedStableEquilibrium: stableEquilibrium,
    );
  }
}