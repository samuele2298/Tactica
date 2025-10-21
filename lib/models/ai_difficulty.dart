enum AIDifficulty { easy, medium, hard }

enum AIStrategy { 
  // Easy Strategies
  easy1, easy2, easy3,
  // Medium Strategies  
  medium1, medium2, medium3,
  // Hard Strategies
  hard1, hard2, hard3
}

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

  List<AIStrategy> get strategies {
    switch (this) {
      case AIDifficulty.easy:
        return [AIStrategy.easy1, AIStrategy.easy2, AIStrategy.easy3];
      case AIDifficulty.medium:
        return [AIStrategy.medium1, AIStrategy.medium2, AIStrategy.medium3];
      case AIDifficulty.hard:
        return [AIStrategy.hard1, AIStrategy.hard2, AIStrategy.hard3];
    }
  }
}

extension AIStrategyExtension on AIStrategy {
  String get displayName {
    switch (this) {
      // Easy Strategies
      case AIStrategy.easy1:
        return 'Centro-Fisso';
      case AIStrategy.easy2:
        return 'Angoli-Fisso';
      case AIStrategy.easy3:
        return 'Spirale';
      
      // Medium Strategies
      case AIStrategy.medium1:
        return 'Difensore';
      case AIStrategy.medium2:
        return 'Opportunista';
      case AIStrategy.medium3:
        return 'Bilanciato';
      
      // Hard Strategies
      case AIStrategy.hard1:
        return 'Minimax Puro';
      case AIStrategy.hard2:
        return 'Aggressivo';
      case AIStrategy.hard3:
        return 'Adattivo';
    }
  }

  String get description {
    switch (this) {
      // Easy Strategies - Pattern riconoscibili
      case AIStrategy.easy1:
        return 'Parte sempre dal centro, poi va verso gli angoli';
      case AIStrategy.easy2:
        return 'Preferisce sempre gli angoli, poi il centro';
      case AIStrategy.easy3:
        return 'Segue un movimento a spirale prevedibile';
      
      // Medium Strategies - Tattiche con debolezze
      case AIStrategy.medium1:
        return 'Eccelle nel difendere ma attacca poco';
      case AIStrategy.medium2:
        return 'Cerca sempre l\'attacco ma trascura la difesa';
      case AIStrategy.medium3:
        return 'Equilibrato ma con pattern riconoscibili';
      
      // Hard Strategies - Avanzate
      case AIStrategy.hard1:
        return 'Matematicamente perfetto, cerca sempre il pareggio';
      case AIStrategy.hard2:
        return 'Prende rischi per forzare la vittoria';
      case AIStrategy.hard3:
        return 'Si adatta al tuo stile di gioco';
    }
  }

  String get learningHint {
    switch (this) {
      // Easy - Come contrattaccare
      case AIStrategy.easy1:
        return 'Contromossa: Prendi gli angoli prima che arrivi lì!';
      case AIStrategy.easy2:
        return 'Contromossa: Controlla il centro quando prende gli angoli!';
      case AIStrategy.easy3:
        return 'Contromossa: Rompi la spirale giocando al centro!';
      
      // Medium - Sfrutta le debolezze
      case AIStrategy.medium1:
        return 'Contromossa: Crea minacce multiple, non può difendere tutto!';
      case AIStrategy.medium2:
        return 'Contromossa: Gioca difensivo, lasciagli fare errori!';
      case AIStrategy.medium3:
        return 'Contromossa: Varia il tuo stile, non essere prevedibile!';
      
      // Hard - Strategia avanzata
      case AIStrategy.hard1:
        return 'Contromossa: Accetta il pareggio, cerca di imparare la perfezione!';
      case AIStrategy.hard2:
        return 'Contromossa: Sii paziente, punisci i rischi eccessivi!';
      case AIStrategy.hard3:
        return 'Contromossa: Cambia strategia costantemente!';
    }
  }

  AIDifficulty get difficulty {
    switch (this) {
      case AIStrategy.easy1:
      case AIStrategy.easy2:
      case AIStrategy.easy3:
        return AIDifficulty.easy;
      case AIStrategy.medium1:
      case AIStrategy.medium2:
      case AIStrategy.medium3:
        return AIDifficulty.medium;
      case AIStrategy.hard1:
      case AIStrategy.hard2:
      case AIStrategy.hard3:
        return AIDifficulty.hard;
    }
  }
}