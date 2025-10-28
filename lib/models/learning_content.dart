enum SlideType {
  intro,         // Slide introduttiva con titolo e overview
  concept,       // Spiegazione di un concetto
  example,       // Esempio pratico
  interactive,   // Slide interattiva
  summary        // Riassunto finale
}

class LearningSlide {
  final String id;
  final String title;
  final String content;
  final SlideType type;
  final String? imageAsset;
  final String? iconData;
  final List<String>? bulletPoints;
  final Map<String, dynamic>? interactiveData;
  final String? quote;
  final String? example;

  const LearningSlide({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.imageAsset,
    this.iconData,
    this.bulletPoints,
    this.interactiveData,
    this.quote,
    this.example,
  });
}

class LearningModule {
  final String id;
  final String title;
  final String description;
  final String iconData;
  final String color;
  final List<LearningSlide> slides;
  final int estimatedMinutes;
  final String difficulty;

  const LearningModule({
    required this.id,
    required this.title,
    required this.description,
    required this.iconData,
    required this.color,
    required this.slides,
    required this.estimatedMinutes,
    required this.difficulty,
  });
}

// Dati dei moduli educativi
class LearningModules {
  static final List<LearningModule> modules = [
    
    // MODULO 1: Introduzione alla Teoria dei Giochi
    LearningModule(
      id: 'game-theory-intro',
      title: 'Introduzione alla Teoria dei Giochi',
      description: 'Comprendere cos’è la teoria dei giochi, come funziona e perché è utile nella vita quotidiana e nel lavoro.',
      iconData: 'psychology',
      color: 'blue',
      estimatedMinutes: 12,
      difficulty: 'Facile',
      slides: [
        LearningSlide(
          id: 'gt-welcome',
          title: 'Benvenuto nella Teoria dei Giochi 🎯',
          content: 'Scopriamo come le decisioni interagiscono tra persone, aziende, algoritmi…',
          type: SlideType.intro,
          iconData: 'games',
        ),
        LearningSlide(
          id: 'gt-ubiquity',
          title: 'Giochi ovunque 🌟',
          content: 'Esempi quotidiani di giochi strategici: traffico, scelta del ristorante, scelte di acquisto.',
          type: SlideType.concept,
          iconData: 'psychology',
          bulletPoints: [
            '🚗 Traffico e scelta della strada',
            '🍽️ Decidere dove mangiare in gruppo',
            '📱 Scelte d’acquisto tra alternative',
          ],
        ),
        LearningSlide(
          id: 'gt-definition',
          title: 'Definizione di Gioco 📋',
          content: 'Un gioco è composto da giocatori, strategie, payoff e regole.',
          type: SlideType.concept,
          iconData: 'list',
          bulletPoints: [
            '👥 Giocatori',
            '🎯 Strategie',
            '🏆 Payoff',
            '📋 Regole'
          ],
        ),
        LearningSlide(
          id: 'gt-players',
          title: 'I Giocatori 👥',
          content: 'Chi prende decisioni: individui, aziende, governi, algoritmi.',
          type: SlideType.concept,
          iconData: 'groups',
          bulletPoints: [
            '🧑 Individui',
            '🏢 Aziende',
            '🏛️ Governi',
            '🤖 Algoritmi'
          ],
        ),
        LearningSlide(
          id: 'gt-strategies',
          title: 'Strategie 🔄',
          content: 'Tutte le possibili azioni che un giocatore può fare.',
          type: SlideType.concept,
          iconData: 'route',
          bulletPoints: [
            '📝 Piani d’azione possibili',
            '🔄 Possono cambiare durante il gioco',
            '🤝 Cooperative o competitive',
            '🎲 Con elementi casuali'
          ],
        ),
        LearningSlide(
          id: 'gt-payoffs',
          title: 'Payoff 🏆',
          content: 'Risultati di ogni scelta: punti, soldi, soddisfazione.',
          type: SlideType.concept,
          iconData: 'emoji_events',
          bulletPoints: [
            '💰 Non sempre denaro',
            '📊 Misurabili in modi diversi',
            '⚖️ Trade-off tra opzioni',
            '🎯 Obiettivo: massimizzare il payoff'
          ],
        ),
        LearningSlide(
          id: 'gt-rules',
          title: 'Regole del Gioco 📋',
          content: 'Come le decisioni interagiscono e quali vincoli ci sono.',
          type: SlideType.concept,
          iconData: 'table_chart',
        ),
        LearningSlide(
          id: 'gt-competitive-cooperative',
          title: 'Giochi Competitivi vs Cooperativi 🤝💥',
          content: 'Differenza tra competizione e collaborazione nei giochi strategici.',
          type: SlideType.concept,
          iconData: 'handshake',
          bulletPoints: [
            'Competitivo: il vantaggio di uno è lo svantaggio dell’altro',
            'Cooperativo: vantaggi reciproci possibili'
          ],
        ),
        LearningSlide(
          id: 'gt-simple-examples',
          title: 'Esempi di Giochi Semplici 🎲',
          content: 'Sasso-Carta-Forbici, scelta della strada nel traffico.',
          type: SlideType.example,
          iconData: 'back_hand',
          example: '''
    👥 Giocatori: tu e un avversario
    🎯 Strategie: Sasso, Carta, Forbici
    🏆 Payoff: Vinci = +1, Pareggi = 0, Perdi = -1
    📋 Regole: Scelta simultanea
    ''',
        ),
        LearningSlide(
          id: 'gt-simultaneous-sequential',
          title: 'Giochi Simultanei vs Sequenziali ⏱️',
          content: 'Spiegare quando si sceglie senza sapere cosa fa l’altro o a turni.',
          type: SlideType.concept,
          iconData: 'auto_stories',
          bulletPoints: [
            'Simultaneo: decisione contemporanea',
            'Sequenziale: decisione a turni'
          ],
        ),
        LearningSlide(
          id: 'gt-zero-sum',
          title: 'Giochi a Somma Zero 0️⃣',
          content: 'Il vantaggio di uno è lo svantaggio dell’altro.',
          type: SlideType.concept,
          iconData: 'balance',
        ),
        LearningSlide(
          id: 'gt-nonzero-sum',
          title: 'Giochi a Somma Non Zero ➕',
          content: 'Possibilità di vantaggi reciproci.',
          type: SlideType.concept,
          iconData: 'groups',
        ),
        LearningSlide(
          id: 'gt-dominant-strategy',
          title: 'Strategia Dominante ⭐',
          content: 'Che cos’è e come riconoscerla.',
          type: SlideType.concept,
          iconData: 'lightbulb',
        ),
        LearningSlide(
          id: 'gt-nash-intro',
          title: 'Equilibrio di Nash (introduzione) ⚖️',
          content: 'Quando nessuno vuole cambiare strategia da solo.',
          type: SlideType.concept,
          iconData: 'psychology',
        ),
        LearningSlide(
          id: 'gt-summary',
          title: 'Riassunto 🌟',
          content: 'Riepilogo concetti base, pronto per approfondire il Dilemma del Prigioniero.',
          type: SlideType.summary,
          iconData: 'celebration',
          bulletPoints: [
            '✅ Cos’è un gioco strategico',
            '✅ Giocatori, strategie e payoff',
            '✅ Giochi competitivi, cooperativi, zero-sum e non-zero-sum',
            '✅ Introduzione all’equilibrio di Nash e strategia dominante'
          ],
        ),
      ],
    ),

    // MODULO 2: Il Dilemma del Prigioniero
    LearningModule(
      id: 'prisoner-dilemma',
      title: 'Il Dilemma del Prigioniero',
      description: 'Spiegazione dettagliata del Dilemma del Prigioniero e delle sue implicazioni pratiche.',
      iconData: 'balance',
      color: 'purple',
      estimatedMinutes: 10,
      difficulty: 'Medio',
      slides: [
        LearningSlide(
          id: 'pd-intro',
          title: 'Introduzione al Dilemma 📖',
          content: 'Breve storia: due prigionieri devono scegliere tra cooperare o tradire.',
          type: SlideType.intro,
          iconData: 'auto_stories',
        ),
        LearningSlide(
          id: 'pd-scenario',
          title: 'Scenario del Dilemma 🏛️',
          content: 'Racconto semplice e intuitivo della situazione tra due complici arrestati.',
          type: SlideType.concept,
          iconData: 'account_balance',
        ),
        LearningSlide(
          id: 'pd-choices',
          title: 'Scelte dei Giocatori 🔄',
          content: 'Cooperare o tradire: cosa significa nella pratica per ciascun giocatore.',
          type: SlideType.concept,
          iconData: 'swap_horiz',
        ),
        LearningSlide(
          id: 'pd-payoff',
          title: 'Payoff della Scelta 📊',
          content: 'Tabelle dei risultati: vinci, perdi, pareggi.',
          type: SlideType.concept,
          iconData: 'table_chart',
          bulletPoints: [
            '🤐🤐 Entrambi cooperano: risultato positivo moderato',
            '🤐😠 Uno coopera, l’altro tradisce: vantaggio per chi tradisce',
            '😠😠 Entrambi tradiscono: peggior risultato per entrambi',
          ],
        ),
        LearningSlide(
          id: 'pd-dominant-strategy',
          title: 'Strategia Dominante ⭐',
          content: 'Analisi: tradire è sempre meglio? Spiegazione intuitiva.',
          type: SlideType.concept,
          iconData: 'lightbulb',
        ),
        LearningSlide(
          id: 'pd-equilibrium',
          title: 'Equilibrio del Gioco ⚖️',
          content: 'Equilibrio di Nash nel Dilemma del Prigioniero spiegato in modo semplice.',
          type: SlideType.concept,
          iconData: 'psychology',
        ),
        LearningSlide(
          id: 'pd-real-examples',
          title: 'Esempi Reali 🌍',
          content: 'Collaborazioni aziendali, traffico, negoziazioni.',
          type: SlideType.example,
          iconData: 'public',
        ),
        LearningSlide(
          id: 'pd-coop-vs-defect',
          title: 'Cooperazione vs Tradimento 🤝💥',
          content: 'Quando conviene cooperare? Quando tradire?',
          type: SlideType.concept,
          iconData: 'handshake',
        ),
        LearningSlide(
          id: 'pd-repeated',
          title: 'Ripetizione del Gioco 🔁',
          content: 'Giochi ripetuti: possibilità di strategie diverse e reputazione.',
          type: SlideType.concept,
          iconData: 'replay',
        ),
        LearningSlide(
          id: 'pd-reciprocity',
          title: 'Strategie di Reciprocità 🤝',
          content: 'Tit for Tat: spiegazione semplice del concetto.',
          type: SlideType.concept,
          iconData: 'repeat',
        ),
        LearningSlide(
          id: 'pd-reputation',
          title: 'Effetto Reputazione 🌟',
          content: 'Come le scelte influenzano le decisioni future dei giocatori.',
          type: SlideType.concept,
          iconData: 'star',
        ),
        LearningSlide(
          id: 'pd-social-applications',
          title: 'Applicazioni Sociali 👥',
          content: 'Amicizia, lavoro di squadra, comunità.',
          type: SlideType.example,
          iconData: 'groups',
        ),
        LearningSlide(
          id: 'pd-economic-applications',
          title: 'Applicazioni Economiche 💰',
          content: 'Mercati, negoziazioni, pubblicità competitiva.',
          type: SlideType.example,
          iconData: 'shopping_cart',
        ),
        LearningSlide(
          id: 'pd-practical-exercise',
          title: 'Esercizio Pratico 📝',
          content: 'Piccolo gioco interattivo per capire i payoff e le scelte.',
          type: SlideType.interactive,
          iconData: 'gamepad',
        ),
        LearningSlide(
          id: 'pd-summary',
          title: 'Riassunto 💫',
          content: 'Concetti chiave del Dilemma del Prigioniero e takeaway principali.',
          type: SlideType.summary,
          iconData: 'celebration',
          bulletPoints: [
            '✅ Storia e scenario originale',
            '✅ Matrice dei payoff e strategia dominante',
            '✅ Applicazioni reali in scuola, economia e società',
            '✅ Capire perché la cooperazione è difficile ma importante',
          ],
        ),
      ],
    ),

    // MODULO 3: Espansione e Applicazioni della Teoria dei Giochi
    LearningModule(
      id: 'games-expansion',
      title: 'Espansione e Applicazioni della Teoria dei Giochi',
      description: 'Altri giochi, scenari e come la teoria dei giochi aiuta nelle decisioni quotidiane e professionali.',
      iconData: 'explore',
      color: 'green',
      estimatedMinutes: 12,
      difficulty: 'Medio',
      slides: [
        LearningSlide(
          id: 'expansion-welcome',
          title: 'Benvenuto! 🌟',
          content: 'Introduzione agli scenari più complessi della teoria dei giochi.',
          type: SlideType.intro,
          iconData: 'emoji_objects',
        ),
        LearningSlide(
          id: 'expansion-coordination',
          title: 'Giochi di Coordinamento 🔗',
          content: 'Come le persone cercano di coordinarsi: esempi pratici come orari dei treni.',
          type: SlideType.concept,
          iconData: 'train',
        ),
        LearningSlide(
          id: 'expansion-zero-sum',
          title: 'Giochi a Somma Zero ⚔️',
          content: 'Rivedere con esempi pratici: scacchi, mercati competitivi.',
          type: SlideType.concept,
          iconData: 'sports_esports',
        ),
        LearningSlide(
          id: 'expansion-non-zero-sum',
          title: 'Giochi a Somma Non Zero 🤝',
          content: 'Collaborazione tra aziende, progetti condivisi e risultati vantaggiosi per tutti.',
          type: SlideType.concept,
          iconData: 'groups',
        ),
        LearningSlide(
          id: 'expansion-repeated-games',
          title: 'Giochi Ripetuti 🔁',
          content: 'Differenza tra giochi singoli e ripetuti, e come le strategie cambiano.',
          type: SlideType.concept,
          iconData: 'repeat',
        ),
        LearningSlide(
          id: 'expansion-evolutionary',
          title: 'Giochi Evolutivi 🧬',
          content: 'Breve introduzione alla selezione di strategie vincenti nel tempo.',
          type: SlideType.concept,
          iconData: 'trending_up',
        ),
        LearningSlide(
          id: 'expansion-chicken-game',
          title: 'Il Gioco del Pollo 🐓',
          content: 'Scenario conflittuale semplice, parallelo al Dilemma del Prigioniero.',
          type: SlideType.example,
          iconData: 'sports_motorsports',
        ),
        LearningSlide(
          id: 'expansion-mixed-strategy',
          title: 'Strategia Mista 🎲',
          content: 'Quando mescolare strategie può essere vantaggioso.',
          type: SlideType.concept,
          iconData: 'casino',
        ),
        LearningSlide(
          id: 'expansion-correlated-equilibrium',
          title: 'Equilibrio Correlato 📡',
          content: 'Concetto intuitivo: quando le scelte sono condizionate da segnali esterni.',
          type: SlideType.concept,
          iconData: 'signal_cellular_alt',
        ),
        LearningSlide(
          id: 'expansion-multiplayer',
          title: 'Giochi con Più Giocatori 👥',
          content: 'Introduzione ai giochi multiplayer, non solo 2 giocatori.',
          type: SlideType.concept,
          iconData: 'people_alt',
        ),
        LearningSlide(
          id: 'expansion-communication',
          title: 'Comunicazione nei Giochi 🗣️',
          content: 'Come parlare può cambiare le strategie e gli esiti.',
          type: SlideType.concept,
          iconData: 'chat',
        ),
        LearningSlide(
          id: 'expansion-bluff',
          title: 'Bluff e Inganno 🃏',
          content: 'Spiegazione pratica del bluff senza matematica avanzata.',
          type: SlideType.concept,
          iconData: 'mood',
        ),
        LearningSlide(
          id: 'expansion-business',
          title: 'Applicazioni Aziendali 💼',
          content: 'Pricing, concorrenza, partnership strategiche.',
          type: SlideType.example,
          iconData: 'business_center',
        ),
        LearningSlide(
          id: 'expansion-social',
          title: 'Applicazioni Sociali 👥',
          content: 'Cooperazione, fiducia e dinamiche di gruppo.',
          type: SlideType.example,
          iconData: 'groups',
        ),
        LearningSlide(
          id: 'expansion-political',
          title: 'Applicazioni Politiche 🏛️',
          content: 'Elezioni, accordi internazionali, negoziazioni.',
          type: SlideType.example,
          iconData: 'gavel',
        ),
        LearningSlide(
          id: 'expansion-mini-exercise',
          title: 'Mini Esercizio 📝',
          content: 'Piccolo gioco interattivo o scenario da risolvere per applicare i concetti.',
          type: SlideType.interactive,
          iconData: 'gamepad',
        ),
        LearningSlide(
          id: 'expansion-summary',
          title: 'Riassunto dei Concetti 💡',
          content: 'Ripasso chiave di tutto il modulo e takeaway principali.',
          type: SlideType.summary,
          iconData: 'celebration',
          bulletPoints: [
            '✅ Giochi di coordinamento, somma zero e non zero',
            '✅ Strategie evolutive, miste e giochi ripetuti',
            '✅ Applicazioni aziendali, sociali e politiche',
            '✅ Comprensione pratica dei giochi più complessi',
          ],
        ),
      ],
    ),

  ];

  static LearningModule? getModuleById(String id) {
    try {
      return modules.firstWhere((module) => module.id == id);
    } catch (e) {
      return null;
    }
  }
}