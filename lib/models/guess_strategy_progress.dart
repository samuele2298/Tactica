/// Implementazione della strategia generica per Guess mode
class GuessGenericStrategy {
  final String _name;
  final String _description;
  final String _difficulty;

  const GuessGenericStrategy({
    required String name,
    required String description,
    required String difficulty,
  }) : _name = name, _description = description, _difficulty = difficulty;

  String get name => _name;

  String get description => _description;

  String get difficulty => _difficulty;
}

/// Progress tracking per Guess mode - scommesse su AI1 vs AI2
class GuessStrategyProgress {
  int gamesPlayed = 0;
  int correctGuesses = 0;
  int totalBets = 0;
  double accuracy = 0.0;
  
  // Statistiche per AI1
  int ai1Wins = 0;
  int ai2Wins = 0;
  int ties = 0;

  // Default constructor
  GuessStrategyProgress();
  
  // Mappatura delle strategie con nomi generici
  static final Map<String, GuessGenericStrategy> _strategyMap = {
    'AI Sequenziale': GuessGenericStrategy(
      name: 'Strategia Alpha',
      description: 'Approccio metodico e ordinato, facile da analizzare.',
      difficulty: 'Facile',
    ),
    'AI Angoli': GuessGenericStrategy(
      name: 'Strategia Beta',
      description: 'Preferisce posizioni specifiche, pattern riconoscibile.',
      difficulty: 'Facile',
    ),
    'AI Centro': GuessGenericStrategy(
      name: 'Strategia Gamma',
      description: 'Focalizzata su controllo centrale, logica prevedibile.',
      difficulty: 'Facile',
    ),
    'AI Prevedibile': GuessGenericStrategy(
      name: 'Strategia Delta',
      description: 'Pattern logici ma più complessi da decifrare.',
      difficulty: 'Medio',
    ),
    'AI Posizionale': GuessGenericStrategy(
      name: 'Strategia Epsilon',
      description: 'Strategia classica con variazioni sottili.',
      difficulty: 'Medio',
    ),
    'AI Difensiva': GuessGenericStrategy(
      name: 'Strategia Zeta',
      description: 'Approccio cauto e reattivo, prioritizza la sicurezza.',
      difficulty: 'Medio',
    ),
    'AI Imprevedibile': GuessGenericStrategy(
      name: 'Strategia Eta',
      description: 'Mescola logica e casualità, difficile da anticipare.',
      difficulty: 'Difficile',
    ),
    'AI Adattiva': GuessGenericStrategy(
      name: 'Strategia Theta',
      description: 'Si evolve in base alle tue azioni, altamente dinamica.',
      difficulty: 'Difficile',
    ),
    'AI Caotica': GuessGenericStrategy(
      name: 'Strategia Omega',
      description: 'Comportamento totalmente imprevedibile, quasi impossibile da decifrare.',
      difficulty: 'Difficile',
    ),
  };

  /// Ottiene la rappresentazione generica di una strategia
  GuessGenericStrategy? getGenericStrategy(String strategyName) {
    return _strategyMap[strategyName];
  }

  /// Aggiorna le statistiche dopo una partita
  void updateStats({
    required bool guessedCorrectly,
    required String winner, // 'AI1', 'AI2', or 'Tie'
  }) {
    gamesPlayed++;
    totalBets++;
    
    if (guessedCorrectly) {
      correctGuesses++;
    }
    
    switch (winner) {
      case 'AI1':
        ai1Wins++;
        break;
      case 'AI2':
        ai2Wins++;
        break;
      case 'Tie':
        ties++;
        break;
    }
    
    // Calcola accuratezza
    accuracy = totalBets > 0 ? (correctGuesses / totalBets) * 100 : 0.0;
  }

  /// Ottiene il tasso di successo formattato
  String get successRate => '${accuracy.toStringAsFixed(1)}%';

  /// Ottiene statistiche dettagliate
  String get detailedStats => 
      'Partite: $gamesPlayed | Accuratezza: $successRate | '
      'AI1: $ai1Wins | AI2: $ai2Wins | Pareggi: $ties';

  /// Consiglio strategico base per Guess mode
  String getCounterStrategy(String strategyName) {
    switch (strategyName) {
      case 'AI Sequenziale':
        return 'Osserva l\'ordine: l\'AI gioca in sequenza numerica. '
               'Scommetti sulla prossima cella nella sequenza 0→1→2→3...';
        
      case 'AI Angoli':
        return 'Pattern angoli: l\'AI preferisce sempre gli angoli (0,2,6,8). '
               'Scommetti sugli angoli liberi, evita centro e lati.';
        
      case 'AI Centro':
        return 'Controllo centrale: l\'AI punta sempre al centro (4) e poi lati (1,3,5,7). '
               'Scommetti su centro prima, poi posizioni centrali.';
        
      case 'AI Prevedibile':
        return 'Pattern diagonali: l\'AI cerca angoli opposti (0↔8, 2↔6). '
               'Osserva quale diagonale ha iniziato e scommetti sull\'angolo opposto.';
        
      case 'AI Posizionale':
        return 'Strategia classica: Centro → Angoli → Lati con leggere variazioni. '
               'Segui la priorità posizionale ma considera il numero di turno.';
        
      case 'AI Difensiva':
        return 'Priorità difesa: l\'AI blocca sempre prima di attaccare. '
               'Se AI2 ha una minaccia, l\'AI1 la bloccherà sicuramente.';
        
      case 'AI Imprevedibile':
        return 'Mix strategico-casuale: 70% logica, 30% casualità. '
               'Segui la logica base ma aspettati deviazioni improvvise.';
        
      case 'AI Adattiva':
        return 'Contrario alle tue abitudini: l\'AI evita le tue scommesse preferite. '
               'Cambia pattern - se scommetti su angoli, passerà a centro/lati.';
        
      case 'AI Caotica':
        return 'Totale imprevedibilità: cambia personalità ogni mossa. '
               'Non cercare pattern - è più efficace scommettere casualmente.';
        
      default:
        return 'Strategia sconosciuta. Osserva i primi turni per identificare il pattern.';
    }
  }

  /// Consigli multipli per strategie avanzate
  List<String> getMultipleCounterStrategies(String strategyName) {
    final baseStrategy = getCounterStrategy(strategyName);
    
    switch (strategyName) {
      case 'AI Sequenziale':
        return [
          baseStrategy,
          'Trucco: Se l\'AI ha saltato una cella per bloccare, riprenderà la sequenza dalla cella successiva.',
          'Attenzione: Nelle situazioni critiche, l\'AI può deviare per vincere o bloccare.',
        ];
        
      case 'AI Angoli':
        return [
          baseStrategy,
          'Pattern specifico: Preferisce l\'ordine 0→2→6→8 se tutti sono liberi.',
          'Eccezione: Se il centro è libero dopo aver preso un angolo, potrebbe prenderlo per fork.',
        ];
        
      case 'AI Centro':
        return [
          baseStrategy,
          'Sequenza tipica: Centro (4) → Lati in ordine (1,3,5,7) → Angoli come ultima risorsa.',
          'Variante: Se AI2 occupa il centro, l\'AI punterà sui lati per controllare le linee.',
        ];
        
      case 'AI Prevedibile':
        return [
          baseStrategy,
          'Pattern avanzato: Prima diagonale 0→8, poi seconda diagonale 2→6, infine centro.',
          'Timing: Il turno numero influenza la scelta - turni dispari preferiscono l\'angolo 0.',
        ];
        
      case 'AI Posizionale':
        return [
          baseStrategy,
          'Strategia fork: Dopo il centro, cerca angoli che possano creare doppie minacce.',
          'Adattamento: Se AI2 occupa posizioni chiave, l\'AI si adatta ma mantiene la priorità posizionale.',
        ];
        
      case 'AI Difensiva':
        return [
          baseStrategy,
          'Gerarchia: Blocco immediato → Vittoria propria → Centro → Angoli → Lati.',
          'Psicologia: L\'AI2 diventa più aggressiva per compensare la difesa di AI1.',
        ];
        
      case 'AI Imprevedibile':
        return [
          baseStrategy,
          'Pattern nascosto: La casualità non è vera - segue micro-pattern di 2-3 mosse.',
          'Strategia: Osserva le ultime 2 mosse per intuire se è in "modalità logica" o "casuale".',
        ];
        
      case 'AI Adattiva':
        return [
          baseStrategy,
          'Contromossa: Cambia le tue scommesse ogni 2-3 partite per confondere l\'adattamento.',
          'Memory: L\'AI ricorda le tue ultime 3 scommesse - usa questa conoscenza a tuo vantaggio.',
        ];
        
      case 'AI Caotica':
        return [
          baseStrategy,
          'Personalità multiple: Sequenziale (20%), Anti-sequenziale (20%), Centro-focale (20%), '
          'Angoli-focale (20%), Casuale puro (20%).',
          'Meta-strategia: Cerca di identificare quale "personalità" ha assunto nei primi 1-2 turni.',
        ];
        
      default:
        return [
          baseStrategy,
          'Consiglio generale: Osserva sempre i primi due turni per identificare il pattern.',
          'Backup: Quando in dubbio, scommetti su centro o angoli - sono statisticamente più probabili.',
        ];
    }
  }

  /// Reset delle statistiche
  void reset() {
    gamesPlayed = 0;
    correctGuesses = 0;
    totalBets = 0;
    accuracy = 0.0;
    ai1Wins = 0;
    ai2Wins = 0;
    ties = 0;
  }

  /// Conversione a mappa per serializzazione
  Map<String, dynamic> toMap() {
    return {
      'gamesPlayed': gamesPlayed,
      'correctGuesses': correctGuesses,
      'totalBets': totalBets,
      'accuracy': accuracy,
      'ai1Wins': ai1Wins,
      'ai2Wins': ai2Wins,
      'ties': ties,
    };
  }

  /// Creazione da mappa per deserializzazione
  GuessStrategyProgress.fromMap(Map<String, dynamic> map) {
    gamesPlayed = map['gamesPlayed'] ?? 0;
    correctGuesses = map['correctGuesses'] ?? 0;
    totalBets = map['totalBets'] ?? 0;
    accuracy = map['accuracy'] ?? 0.0;
    ai1Wins = map['ai1Wins'] ?? 0;
    ai2Wins = map['ai2Wins'] ?? 0;
    ties = map['ties'] ?? 0;
  }

  /// Factory method per creare da mappa
  factory GuessStrategyProgress.fromMapFactory(Map<String, dynamic> map) {
    return GuessStrategyProgress.fromMap(map);
  }
}