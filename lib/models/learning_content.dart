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
    
    // MODULO 1: Cos'è un gioco strategico
    LearningModule(
      id: 'strategic-games',
      title: 'Cos\'è un gioco strategico',
      description: 'Definizione di gioco, giocatori, strategie e payoff',
      iconData: 'psychology',
      color: 'blue',
      estimatedMinutes: 15,
      difficulty: 'Facile',
      slides: [
        LearningSlide(
          id: 'strategic-welcome',
          title: 'Benvenuto nei Giochi Strategici! 🎯',
          content: 'Scopriamo insieme il mondo affascinante della teoria dei giochi!',
          type: SlideType.intro,
          iconData: 'games',
          bulletPoints: [
            'I giochi sono ovunque nella vita quotidiana',
            'Non solo videogame o giochi da tavolo',
            'Anche le decisioni di tutti i giorni!',
          ],
        ),
        LearningSlide(
          id: 'strategic-everyday',
          title: 'Giochi nella Vita Quotidiana 🌟',
          content: 'Ti sei mai chiesto perché certe situazioni sembrano così complicate?',
          type: SlideType.concept,
          iconData: 'psychology',
          bulletPoints: [
            '🚗 Scegliere quale strada prendere nel traffico',
            '🍕 Decidere cosa ordinare quando siete in gruppo',
            '📱 Comprare il nuovo telefono: aspetto o compro ora?',
            '⚽ Durante una partita: passare o tirare?',
          ],
        ),
        LearningSlide(
          id: 'strategic-definition',
          title: 'Elementi di un Gioco Strategico �',
          content: 'Ogni gioco strategico ha sempre questi 4 elementi fondamentali:',
          type: SlideType.concept,
          iconData: 'list',
          bulletPoints: [
            '👥 **Giocatori**: Chi prende le decisioni',
            '🎯 **Strategie**: Le scelte disponibili',
            '🏆 **Payoff**: I risultati che ottieni',
            '📋 **Regole**: Come interagiscono le decisioni',
          ],
        ),
        LearningSlide(
          id: 'strategic-players',
          title: 'Chi Sono i Giocatori? 👥',
          content: 'I giocatori possono essere chiunque prenda decisioni strategiche',
          type: SlideType.concept,
          iconData: 'people',
          bulletPoints: [
            '🧒 Individui: tu, i tuoi amici, la famiglia',
            '� Aziende: che competono per i clienti',
            '🏛️ Governi: che prendono decisioni politiche',
            '🤖 Algoritmi: nei sistemi automatici',
          ],
          example: 'In una partita di calcio, i giocatori sono le due squadre che decidono la strategia di gioco',
        ),
        LearningSlide(
          id: 'strategic-strategies',
          title: 'Cosa Sono le Strategie? �',
          content: 'Le strategie sono tutte le azioni possibili che un giocatore può scegliere',
          type: SlideType.concept,
          iconData: 'route',
          bulletPoints: [
            '📝 Piano completo di azione',
            '🔄 Può cambiare durante il gioco',
            '🤝 Può essere cooperativa o competitiva',
            '🎲 Può includere elementi casuali',
          ],
          example: 'Nel calcio: attaccare, difendere, contropiede sono strategie diverse',
        ),
        LearningSlide(
          id: 'strategic-payoffs',
          title: 'I Payoff: Cosa Ottieni? 🏆',
          content: 'I payoff rappresentano i risultati che ogni giocatore ottiene',
          type: SlideType.concept,
          iconData: 'emoji_events',
          bulletPoints: [
            '💰 Non sempre denaro: può essere soddisfazione, tempo, punti',
            '📊 Possono essere misurati in diversi modi',
            '⚖️ Spesso ci sono trade-off: per vincere qualcosa, perdi altro',
            '🎯 L\'obiettivo è massimizzare il proprio payoff',
          ],
        ),
        LearningSlide(
          id: 'strategic-example-rps',
          title: 'Esempio Classico: Sasso, Carta, Forbici ✂️',
          content: 'Analizziamo il gioco più famoso usando i nostri elementi!',
          type: SlideType.example,
          iconData: 'back_hand',
          example: '''
👥 **Giocatori**: Tu e un avversario

🎯 **Strategie**: 
• Sasso 🪨 (vince su Forbici)
• Carta 📄 (vince su Sasso)  
• Forbici ✂️ (vince su Carta)

🏆 **Payoff**: 
• Vinci = +1 punto 😊
• Pareggi = 0 punti 😐  
• Perdi = -1 punto 😞

📋 **Regole**: Scelta simultanea, nessuno sa cosa fa l'altro
          ''',
        ),
        LearningSlide(
          id: 'strategic-example-traffic',
          title: 'Esempio Reale: Il Traffico 🚗',
          content: 'Anche scegliere la strada è un gioco strategico!',
          type: SlideType.example,
          iconData: 'traffic',
          example: '''
👥 **Giocatori**: Tutti gli automobilisti

🎯 **Strategie**: 
• Strada principale (più diretta ma può essere congestionata)
• Strada alternativa (più lunga ma meno traffico)

🏆 **Payoff**: 
• Tempo di percorrenza minimizzato
• Stress ridotto
• Carburante risparmiato

📋 **Regole**: Ognuno sceglie la sua strada, ma le scelte si influenzano a vicenda
          ''',
        ),
        LearningSlide(
          id: 'strategic-example-restaurant',
          title: 'Esempio Quotidiano: Scegliere il Ristorante 🍽️',
          content: 'Decidere dove mangiare con gli amici è più complesso di quanto pensi!',
          type: SlideType.example,
          iconData: 'restaurant',
          example: '''
👥 **Giocatori**: Tu e i tuoi amici

🎯 **Strategie**: 
• Pizza 🍕 (veloce, economico)
• Sushi 🍣 (costoso, trendy)
• Hamburger 🍔 (via di mezzo)

🏆 **Payoff**: 
• Soddisfazione del cibo
• Costo sostenibile  
• Tempo disponibile
• Approvazione del gruppo

📋 **Regole**: Si decide insieme, tutti devono essere d'accordo
          ''',
        ),
        LearningSlide(
          id: 'strategic-summary',
          title: 'Riassunto: Hai Imparato a Riconoscere i Giochi! 🌟',
          content: 'Ora sai identificare i giochi strategici ovunque nella vita quotidiana.',
          type: SlideType.summary,
          iconData: 'lightbulb',
          quote: '"Ogni volta che la tua decisione dipende da quella di qualcun altro, stai giocando un gioco strategico!"',
          bulletPoints: [
            '✅ Conosci i 4 elementi fondamentali di ogni gioco',
            '✅ Sai riconoscere giocatori, strategie e payoff',
            '✅ Hai visto esempi dalla vita reale',
            '✅ Sei pronto per approfondire giochi più complessi!',
            '🚀 Il prossimo passo: il famoso Dilemma del Prigioniero',
          ],
        ),
      ],
    ),

    // MODULO 2: Il Dilemma del Prigioniero
    LearningModule(
      id: 'prisoner-dilemma',
      title: 'Il Dilemma del Prigioniero',
      description: 'Il gioco più famoso della teoria dei giochi',
      iconData: 'balance',
      color: 'purple',
      estimatedMinutes: 18,
      difficulty: 'Medio',
      slides: [
        LearningSlide(
          id: 'prisoner-intro',
          title: 'La Storia che Ha Cambiato Tutto 📖',
          content: 'Benvenuto nel gioco più famoso e studiato della teoria dei giochi!',
          type: SlideType.intro,
          iconData: 'auto_stories',
          bulletPoints: [
            '📅 Inventato nel 1950 alla RAND Corporation',
            '🏆 Il gioco più analizzato nella storia',
            '🤝 Spiega il conflitto tra interesse individuale e collettivo',
            '🌍 Applicabile a tantissime situazioni reali',
          ],
        ),
        LearningSlide(
          id: 'prisoner-story-original',
          title: 'La Storia Originale: Due Prigionieri 👮‍♂️',
          content: 'Immagina questa situazione drammatica...',
          type: SlideType.concept,
          iconData: 'account_balance',
          example: '''
**La Situazione**: 
Due complici vengono arrestati per un crimine. La polizia li interroga separatamente e non possono comunicare.

**L'Offerta del Procuratore**:
"Abbiamo prove sufficienti per condannarvi a 1 anno. Ma se collabori..."

**Le Opzioni**:
• Stare zitto (Cooperare con il complice)
• Testimoniare contro l'altro (Tradire il complice)
          ''',
        ),
        LearningSlide(
          id: 'prisoner-payoffs',
          title: 'I Possibili Risultati 📊',
          content: 'Vediamo cosa succede in ogni scenario:',
          type: SlideType.concept,
          iconData: 'gavel',
          bulletPoints: [
            '🤐🤐 **Entrambi stanno zitti**: 1 anno di prigione ciascuno',
            '🤐😠 **Uno zitto, uno parla**: 0 anni per chi parla, 3 anni per l\'altro',
            '😠🤐 **Uno parla, uno zitto**: 3 anni per chi sta zitto, 0 anni per chi parla',
            '😠😠 **Entrambi parlano**: 2 anni di prigione ciascuno',
          ],
        ),
        LearningSlide(
          id: 'prisoner-matrix',
          title: 'La Matrice del Dilemma 🎯',
          content: 'Organizziamo tutti i risultati in una tabella per vedere meglio!',
          type: SlideType.interactive,
          iconData: 'table_chart',
          example: '''
                 | Complice: Tace | Complice: Parla
Tu: Taci       |    (-1, -1)    |    (-3, 0)
Tu: Parli      |    (0, -3)     |    (-2, -2)

Legenda: (Anni di prigione per te, Anni per il complice)
          ''',
        ),
        LearningSlide(
          id: 'prisoner-dilemma-core',
          title: 'Dov\'è il Dilemma? 🤔',
          content: 'Ecco il problema fondamentale che rende questo gioco così interessante:',
          type: SlideType.concept,
          iconData: 'psychology',
          bulletPoints: [
            '🧠 **Ragionamento individuale**: "Meglio parlare, così al massimo prendo 2 anni"',
            '🤝 **Ragionamento collettivo**: "Se stiamo entrambi zitti, prendiamo solo 1 anno"',
            '⚖️ **Il paradosso**: La scelta "logica" porta al risultato peggiore per tutti!',
            '💡 **Il dilemma**: Fidarsi dell\'altro o pensare solo a sé?',
          ],
        ),
        LearningSlide(
          id: 'prisoner-school-example',
          title: 'Esempio Scolastico: Il Compito in Classe 📚',
          content: 'Il dilemma del prigioniero nella vita di tutti i giorni!',
          type: SlideType.example,
          iconData: 'school',
          example: '''
**Situazione**: Tu e il tuo amico durante un compito difficile

**Le Strategie**:
• Cooperare = Non copiare, studiare onestamente
• Tradire = Copiare/far copiare

**I Risultati**:
• Entrambi onesti = Voti giusti, prof contenta 😊
• Tu onesto, lui copia = Lui ha voto alto, tu normale 😐
• Tu copi, lui onesto = Tu hai voto alto, lui normale 😐  
• Entrambi copiate = Rischio di essere scoperti! 😰
          ''',
        ),
        LearningSlide(
          id: 'prisoner-environmental',
          title: 'Esempio Globale: L\'Ambiente 🌍',
          content: 'Il cambiamento climatico è un gigantesco dilemma del prigioniero!',
          type: SlideType.example,
          iconData: 'public',
          example: '''
**Giocatori**: Tutti i paesi del mondo

**Strategie**:
• Cooperare = Ridurre le emissioni (costa soldi)
• Tradire = Continuare a inquinare (risparmi soldi)

**Risultati**:
• Tutti riducono = Pianeta salvato! 🌱
• Alcuni riducono, altri no = Sacrificio inutile 😤
• Nessuno riduce = Disastro ambientale per tutti �

**Il Dilemma**: Perché dovrei sacrificarmi se gli altri non lo fanno?
          ''',
        ),
        LearningSlide(
          id: 'prisoner-social-media',
          title: 'Esempio Digitale: I Social Media 📱',
          content: 'Anche online incontriamo questo dilemma ogni giorno!',
          type: SlideType.example,
          iconData: 'smartphone',
          example: '''
**Situazione**: Condividere informazioni personali online

**Strategie**:
• Cooperare = Condividere responsabilmente, rispettare la privacy
• Tradire = Condividere tutto per likes, gossip, visibilità

**Risultati**:
• Tutti responsabili = Internet sicuro e piacevole 😊
• Alcuni responsabili, altri no = Ambiente tossico 😕
• Nessuno responsabile = Cyberbullismo e problemi per tutti 😰

**Il Dilemma**: "Se non posto tutto della mia vita, avrò meno followers!"
          ''',
        ),
        LearningSlide(
          id: 'prisoner-sports',
          title: 'Esempio Sportivo: Il Doping 🏃‍♂️',
          content: 'Lo sport ci mostra chiaramente come funziona questo dilemma',
          type: SlideType.example,
          iconData: 'directions_run',
          example: '''
**Giocatori**: Tutti gli atleti di uno sport

**Strategie**:
• Cooperare = Gareggiare pulito, senza doping
• Tradire = Usare sostanze per avere vantaggi

**Risultati**:
• Tutti puliti = Competizione equa e sport sano 🏆
• Alcuni puliti, altri no = Gara ingiusta 😠
• Tutti "sporchi" = Sport rovinato, rischi per la salute ⚠️

**Il Dilemma**: "Se non mi dopo, come posso competere con chi lo fa?"
          ''',
        ),
        LearningSlide(
          id: 'prisoner-summary',
          title: 'Riassunto: Il Cuore del Conflitto Umano 💫',
          content: 'Hai scoperto uno dei meccanismi più profondi delle relazioni umane!',
          type: SlideType.summary,
          iconData: 'favorite',
          quote: '"Il dilemma del prigioniero ci insegna che quello che è razionale per l\'individuo può essere irrazionale per il gruppo."',
          bulletPoints: [
            '✅ Hai capito la storia originale e la sua logica',
            '✅ Hai visto la matrice dei payoff e il paradosso',
            '✅ Hai riconosciuto il dilemma in scuola, ambiente, sport, web',
            '✅ Capisci perché la cooperazione è difficile ma importante',
            '🔍 Prossimo step: scoprire le strategie per risolverlo!',
          ],
        ),
      ],
    ),

    // MODULO 3: Strategia Dominante
    LearningModule(
      id: 'dominant-strategy',
      title: 'Strategia Dominante',
      description: 'Quando una strategia è sempre la migliore',
      iconData: 'trending_up',
      color: 'green',
      estimatedMinutes: 15,
      difficulty: 'Medio',
      slides: [
        LearningSlide(
          id: 'dominant-intro',
          title: 'La Strategia Imbattibile! 🏆',
          content: 'Ti piacerebbe avere una strategia che vince sempre, qualunque cosa facciano gli altri?',
          type: SlideType.intro,
          iconData: 'emoji_events',
          bulletPoints: [
            '💪 Scopri le strategie super-potenti',
            '🎯 Quando una scelta batte tutte le altre',
            '🔍 Come riconoscerle nei tuoi giochi',
            '⚡ Il potere di semplificare le decisioni',
          ],
        ),
        LearningSlide(
          id: 'dominant-definition',
          title: 'Che cos\'è una Strategia Dominante? 🎯',
          content: 'È una strategia che ti dà sempre il risultato migliore, indipendentemente da quello che fanno gli altri!',
          type: SlideType.concept,
          iconData: 'star',
          bulletPoints: [
            '🥇 **Sempre vincente**: Batte ogni altra tua strategia',
            '🤷‍♀️ **Indipendente**: Non importa cosa fanno gli avversari',
            '🧠 **Semplifica**: Rende la scelta ovvia',
            '💎 **Rara**: Non esiste sempre, ma quando c\'è è preziosa',
          ],
        ),
        LearningSlide(
          id: 'dominant-types',
          title: 'Due Tipi di Dominanza 📊',
          content: 'Esistono due livelli di "potenza" per le strategie dominanti:',
          type: SlideType.concept,
          iconData: 'assessment',
          bulletPoints: [
            '💯 **Strettamente Dominante**: Sempre rigorosamente migliore',
            '📈 **Debolmente Dominante**: Sempre almeno uguale, a volte migliore',
            '🔄 **Dominata**: Una strategia sempre peggiore di un\'altra',
            '❌ **Irrazionale**: Giocare una strategia dominata non ha senso',
          ],
        ),
        LearningSlide(
          id: 'dominant-example-simple',
          title: 'Esempio Semplicissimo: 1€ vs 2€ 💰',
          content: 'Il caso più ovvio di strategia dominante!',
          type: SlideType.example,
          iconData: 'euro',
          example: '''
**Situazione**: Ti offrono di scegliere tra 1€ o 2€

**Le tue strategie**:
• Prendere 1€
• Prendere 2€

**Analisi**:
Non importa cosa fanno gli altri, cosa pensa il pubblico, che giorno è...
2€ > 1€ SEMPRE!

**Conclusione**: Prendere 2€ è una strategia strettamente dominante
          ''',
        ),
        LearningSlide(
          id: 'dominant-example-prisoner',
          title: 'Esempio: Il Dilemma del Prigioniero 🤖',
          content: 'Nel famoso dilemma, tradire è spesso una strategia dominante!',
          type: SlideType.example,
          iconData: 'smart_toy',
          example: '''
**Se l'altro coopera**: 
• Tu cooperi = 3 punti (bene)
• Tu tradisci = 5 punti (meglio!) ✅

**Se l'altro tradisce**:
• Tu cooperi = 0 punti (male)
• Tu tradisci = 1 punto (meglio!) ✅

**Conclusione**: Tradire vince sempre dal punto di vista individuale
**Ma attenzione**: Porta al risultato peggiore per entrambi!
          ''',
        ),
        LearningSlide(
          id: 'dominant-example-auction',
          title: 'Esempio: L\'Asta Sigillata 📮',
          content: 'Nelle aste c\'è una strategia dominante sorprendente!',
          type: SlideType.example,
          iconData: 'gavel',
          example: '''
**Situazione**: Asta per un oggetto che vale 100€ per te

**Strategie possibili**:
• Offrire meno di 100€ (es. 50€, 80€, 90€)
• Offrire esattamente 100€
• Offrire più di 100€ (es. 120€)

**Strategia dominante**: Offrire esattamente quello che vale per te (100€)
• Se vinci pagando meno = profitto!
• Se vinci pagando uguale = nessuna perdita
• Se perdi = almeno non hai pagato troppo
          ''',
        ),
        LearningSlide(
          id: 'dominant-example-school',
          title: 'Esempio Scolastico: La Preparazione 📚',
          content: 'A scuola trovi spesso strategie dominanti!',
          type: SlideType.example,
          iconData: 'school',
          example: '''
**Situazione**: Domani c\'è il compito in classe

**Le tue strategie**:
• Non studiare affatto 😴
• Studiare un po\' 📖  
• Studiare molto 📚💪

**Analisi**:
• Studiare di più = sempre voto migliore (o almeno uguale)
• Non importa quanto difficili sono le domande
• Non importa quanto studiano gli altri

**Strategia dominante**: Studiare il più possibile!
          ''',
        ),
        LearningSlide(
          id: 'dominant-elimination',
          title: 'Eliminazione delle Strategie Dominate 🗑️',
          content: 'Un trucco potente: elimina le strategie stupide per semplificare il gioco!',
          type: SlideType.concept,
          iconData: 'delete_sweep',
          bulletPoints: [
            '❌ **Passo 1**: Trova strategie dominate (sempre peggiori)',
            '🗑️ **Passo 2**: Eliminale dal gioco (nessuno le userebbe)',
            '🔄 **Passo 3**: Ripeti il processo nel gioco semplificato',
            '🎯 **Risultato**: Arrivi alla soluzione per eliminazione!',
          ],
        ),
        LearningSlide(
          id: 'dominant-limitations',
          title: 'Quando NON Esiste la Strategia Dominante ❓',
          content: 'Purtroppo non sempre c\'è una strategia che vince sempre...',
          type: SlideType.concept,
          iconData: 'help_outline',
          bulletPoints: [
            '🪨📄✂️ **Sasso-Carta-Forbici**: Ogni strategia ha punti deboli',
            '⚽ **Calcio**: Attaccare o difendere dipende dall\'avversario',
            '🎵 **Musica**: Il genere migliore dipende dai gusti',
            '🤝 **In questi casi**: Servono strategie più sofisticate',
          ],
        ),
        LearningSlide(
          id: 'dominant-summary',
          title: 'Riassunto: Il Potere della Semplicità ⚡',
          content: 'Hai imparato a riconoscere e usare le strategie più potenti!',
          type: SlideType.summary,
          iconData: 'military_tech',
          quote: '"Una strategia dominante è come avere un superpotere: vinci sempre!"',
          bulletPoints: [
            '✅ Conosci i due tipi di dominanza: stretta e debole',
            '✅ Sai riconoscere le strategie dominate da eliminare',
            '✅ Hai visto esempi da soldi, prigioni, aste, scuola',
            '✅ Capisci quando non esistono strategie dominanti',
            '🎯 Prossimo livello: Equilibrio di Nash per i giochi complessi!',
          ],
        ),
      ],
    ),

    // MODULO 4: Equilibrio di Nash
    LearningModule(
      id: 'nash-equilibrium',
      title: 'Equilibrio di Nash',
      description: 'Quando nessun giocatore vuole cambiare strategia',
      iconData: 'center_focus_strong',
      color: 'orange',
      estimatedMinutes: 12,
      difficulty: 'Difficile',
      slides: [
        LearningSlide(
          id: 'nash-intro',
          title: 'Il Genio John Nash 🧠',
          content: 'Scopri l\'idea che ha vinto il Premio Nobel e rivoluzionato la matematica!',
          type: SlideType.intro,
          iconData: 'school',
          bulletPoints: [
            'John Nash: matematico geniale',
            'Ha inventato un concetto rivoluzionario',
            'Usato in economia, politica, biologia',
            'Hai visto il film "A Beautiful Mind"?',
          ],
        ),
        LearningSlide(
          id: 'nash-definition',
          title: 'Che cos\'è l\'Equilibrio di Nash? ⚖️',
          content: 'È quando tutti i giocatori hanno scelto la strategia migliore data la scelta degli altri.',
          type: SlideType.concept,
          iconData: 'balance',
          example: '''
**L'idea principale**:
Nessuno vuole cambiare la sua strategia se tutti gli altri mantengono la loro.

**Come una danza perfetta**: 
Ogni ballerino fa la mossa giusta per non pestare i piedi agli altri!
          ''',
        ),
        LearningSlide(
          id: 'nash-traffic',
          title: 'Esempio: Il Traffico 🚗',
          content: 'Tutti i giorni vivi un equilibrio di Nash andando a scuola!',
          type: SlideType.example,
          iconData: 'traffic',
          example: '''
**La Situazione**:
Tutti devono scegliere che strada fare per andare a scuola.

**L'Equilibrio**:
Quando il traffico si stabilizza, nessuno vuole cambiare strada, perché le altre sono altrettanto trafficate!

Se cambiassi strada, non andresti più veloce.
          ''',
        ),
        LearningSlide(
          id: 'nash-prisoner',
          title: 'Nash nel Dilemma del Prigioniero 🔒',
          content: 'Il dilemma ha un equilibrio di Nash, ma non è il migliore per tutti!',
          type: SlideType.interactive,
          iconData: 'quiz',
          interactiveData: {
            'question': 'Qual è l\'equilibrio di Nash nel Dilemma del Prigioniero?',
            'options': [
              'Entrambi cooperano',
              'Entrambi tradiscono', 
              'Uno coopera, uno tradisce',
              'Non c\'è equilibrio'
            ],
            'correct': 1,
            'explanation': 'Entrambi tradiscono! Nessuno vuole cambiare perché cooperare sarebbe peggio.'
          },
        ),
        LearningSlide(
          id: 'nash-summary',
          title: 'Complimenti, Matematico! 🎓',
          content: 'Hai capito uno dei concetti più importanti della matematica moderna!',
          type: SlideType.summary,
          iconData: 'celebration',
          quote: '"L\'equilibrio di Nash ci aiuta a capire perché il mondo funziona come funziona."',
          bulletPoints: [
            'Conosci John Nash e la sua grande idea',
            'Sai riconoscere un equilibrio di Nash',
            'Hai visto esempi dalla vita reale',
            'Capisci che non sempre è il meglio per tutti',
          ],
        ),
      ],
    ),

    // MODULO 5: Giochi Ripetuti e Fiducia
    LearningModule(
      id: 'repeated-games',
      title: 'Giochi Ripetuti e Fiducia',
      description: 'Come la reputazione cambia tutto',
      iconData: 'repeat',
      color: 'red',
      estimatedMinutes: 8,
      difficulty: 'Medio',
      slides: [
        LearningSlide(
          id: 'repeated-intro',
          title: 'Quando Giochi Ancora e Ancora... 🔄',
          content: 'Cosa succede quando incontri la stessa persona molte volte? Tutto cambia!',
          type: SlideType.intro,
          iconData: 'refresh',
          bulletPoints: [
            'I giochi una tantum vs giochi ripetuti',
            'Perché la reputazione conta',
            'Il potere della cooperazione',
          ],
        ),
        LearningSlide(
          id: 'repeated-friendship',
          title: 'Esempio: L\'Amicizia 👫',
          content: 'L\'amicizia è un gioco ripetuto dove la fiducia cresce nel tempo!',
          type: SlideType.example,
          iconData: 'favorite',
          example: '''
**Gioco una tantum**: 
Incontri qualcuno per la prima volta. Forse ti comporti male perché non lo rivedrai mai.

**Gioco ripetuto**:
Vai a scuola con la stessa persona ogni giorno. Se ti comporti male, lei se lo ricorderà domani!

La **reputazione** diventa importante.
          ''',
        ),
        LearningSlide(
          id: 'repeated-titfortat',
          title: 'La Strategia "Tit-for-Tat" 🤝',
          content: 'La strategia più vincente nei giochi ripetuti!',
          type: SlideType.concept,
          iconData: 'handshake',
          example: '''
**Come funziona Tit-for-Tat**:
1. **Primo turno**: Sempre coopera
2. **Turni successivi**: Fai quello che ha fatto l'altro nell'ultimo turno

**Esempio**:
• Turno 1: Tu cooperi
• Turno 2: Se lui ha cooperato, tu cooperi
• Turno 3: Se lui ha tradito, tu tradisci
• Turno 4: Se lui torna a cooperare, tu cooperi

È **gentile**, **vendicativa** e **clemente**!
          ''',
        ),
        LearningSlide(
          id: 'repeated-summary',
          title: 'La Magia della Ripetizione! ✨',
          content: 'Hai scoperto perché la fiducia e la reputazione sono così importanti!',
          type: SlideType.summary,
          iconData: 'auto_awesome',
          quote: '"Nei giochi ripetuti, essere gentili ma non ingenui è la strategia vincente!"',
          bulletPoints: [
            'I giochi ripetuti cambiano tutto',
            'La reputazione diventa un\'arma potente',
            'Tit-for-Tat è spesso la strategia migliore',
            'La cooperazione può emergere naturalmente',
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