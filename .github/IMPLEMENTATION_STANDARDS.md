# Tacticafé - Standard di Implementazione

## Panoramica
Questo documento definisce gli standard di implementazione per il progetto Tacticafé, un'applicazione Flutter Web che presenta diverse modalità di gioco del Tic Tac Toe per insegnare concetti di teoria dei giochi.

## Architettura delle Modalità di Gioco

### Struttura Standard per Modalità
Ogni modalità di gioco deve seguire il pattern architetturale unificato:

```
lib/
├── screens/game_modes/
│   └── {mode}_screen.dart          # Screen principale della modalità
├── providers/
│   └── {mode}_provider.dart        # State management con Riverpod
├── models/
│   ├── {mode}_game.dart           # Logica di gioco
│   └── {mode}_strategy_progress.dart  # Tracking progresso strategie
├── strategies/{mode}/
│   └── {mode}_ai_strategy.dart    # Implementazioni AI strategie
└── widgets/
    └── {mode}_strategy_drawer.dart # Drawer per selezione strategie
```

### Modalità Implementate
- **Classic**: Gioco tradizionale 1v1 contro AI
- **Simultaneous**: Entrambi i giocatori fanno la mossa simultaneamente
- **Cooperative**: Team (Umano + AI amica) vs AI nemica

## Standard per Strategie AI

### Struttura a 3 Livelli di Difficoltà
Ogni modalità deve implementare **esattamente 3 strategie per livello**:

#### Livello Easy (Facile)
- 3 strategie con comportamenti semplici e prevedibili
- Nomi generici finché non sconfitte
- Esempio: "Strategia Facile A", "Strategia Facile B", "Strategia Facile C"

#### Livello Medium (Medio) 
- 3 strategie con logica intermedia
- Bilanciamento tra predicibilità e sfida
- Esempio: "Strategia Media A", "Strategia Media B", "Strategia Media C"

#### Livello Hard (Difficile)
- 3 strategie con AI avanzata
- Comportamenti ottimali o semi-ottimali
- Esempio: "Strategia Difficile A", "Strategia Difficile B", "Strategia Difficile C"

### Requisiti per Implementazione Strategie

```dart
enum {Mode}AIStrategy {
  // Easy strategies (3)
  strategy1, strategy2, strategy3,
  // Medium strategies (3)  
  strategy4, strategy5, strategy6,
  // Hard strategies (3)
  strategy7, strategy8, strategy9
}

abstract class {Mode}AIStrategyImplementation {
  String get displayName;
  String get description;
  AIDifficulty get difficulty;
  
  // Metodi specifici per la modalità
  int selectMove(GameState state, ...);
}
```

## Sistema Drawer Unificato

### BaseStrategyDrawer
Tutte le modalità devono utilizzare il componente `BaseStrategyDrawer` con configurazioni specifiche:

```dart
class BaseStrategyDrawer<T extends GenericStrategy> extends StatelessWidget {
  final T currentStrategy;
  final GenericProgress progress;
  final Function(T) onStrategySelected;
  final DrawerConfig config;
  // ...
}
```

### Configurazioni DrawerConfig Standard

```dart
class DrawerConfig {
  // Classic Mode - Blu/Viola
  static const classic = DrawerConfig(
    primaryColor: Colors.blue,
    secondaryColor: Colors.purple,
    icon: Icons.psychology,
    title: 'Strategie AI'
  );
  
  // Simultaneous Mode - Arancione  
  static const simultaneous = DrawerConfig(
    primaryColor: Colors.orange,
    secondaryColor: Colors.deepOrange,
    icon: Icons.flash_on,
    title: 'Strategie Simultanee'
  );
  
  // Cooperative Mode - Verde
  static const coop = DrawerConfig(
    primaryColor: Colors.green,
    secondaryColor: Colors.teal,
    icon: Icons.group,
    title: 'Strategie Cooperative'
  );
}
```

## Standard Grafici

### Palette Colori per Modalità
- **Classic**: Blu primario (#2196F3), Viola secondario (#9C27B0)
- **Simultaneous**: Arancione primario (#FF9800), Arancione scuro (#FF5722)
- **Cooperative**: Verde primario (#4CAF50), Teal secondario (#009688)

### Layout Drawer
Ogni drawer deve implementare:
1. **Header**: Icona modalità + titolo + colore tematico
2. **Sezione per Difficoltà**: Easy, Medium, Hard raggruppate
3. **Progress Indicators**: Cerchi concentrici per vittorie consecutive (0/3, 1/3, 2/3, 3/3)
4. **Pulsante Info**: Solo per strategie sconfitte (3/3 vittorie)
5. **Selezione Attiva**: Highlight strategia corrente

### Elementi UI Unificati
- **Bordi arrotondati**: 15px per container principali, 10px per elementi interni
- **Ombre**: `BoxShadow` con opacità 0.1-0.3 del colore tematico
- **Spaziature**: 16px tra sezioni, 8px tra elementi
- **Font**: `FontWeight.bold` per titoli, regular per descrizioni

## Sistema Progress Tracking

### Meccanica Vittorie Consecutive
- **3 vittorie consecutive** per sconfiggere una strategia
- **Reset a 0** dopo qualsiasi sconfitta
- **Nomi generici** finché non sconfitta
- **Nome reale + info button** dopo sconfitta

### Counter-Strategies Multiple
Ogni strategia sconfitta deve fornire 2+ counter-strategies:

```dart
List<String> getMultipleCounterStrategies(AIStrategy strategy) {
  return [
    "Counter-strategia 1: Breve spiegazione tattica specifica",
    "Counter-strategia 2: Altro approccio con dettagli tattici",
    // Opzionale: più counter-strategies per strategie complesse
  ];
}
```

## Dialog System

### DialogUtils Standard
Utilizzo centralizzato di `DialogUtils.showStrategyRevealDialog`:

```dart
DialogUtils.showStrategyRevealDialog(
  context: context,
  strategyName: "Nome Reale Strategia",
  strategyDescription: "Descrizione dettagliata comportamento",
  counterStrategy: "", // Ignorato se multipleCounterStrategies fornito
  themeColor: modalityThemeColor,
  onReplay: () => resetGame(),
  onChangeStrategy: () => openDrawer(),
  gameMode: "Nome Modalità",
  multipleCounterStrategies: progress.getMultipleCounterStrategies(strategy),
);
```

### Trigger Dialog
- **Vittoria**: Mostra dialog strategia automaticamente
- **Info Button**: Mostra dialog per strategia sconfitta selezionata
- **Sequenza**: Dialog strategia → (opzionale) Dialog vittoria

## Provider Pattern (Riverpod)

### Struttura StateNotifier Standard
```dart
class {Mode}Notifier extends StateNotifier<{Mode}Game> {
  final {Mode}StrategyProgress _strategyProgress = {Mode}StrategyProgress();
  {Mode}AIStrategy _currentStrategy = {Mode}AIStrategy.defaultEasy;
  
  // Getters
  {Mode}StrategyProgress get strategyProgress => _strategyProgress;
  {Mode}AIStrategy get currentStrategy => _currentStrategy;
  
  // Actions
  void changeStrategy({Mode}AIStrategy strategy) { ... }
  void resetGame() { ... }
  void processGameResult(GameStatus status) { ... }
}
```

## Convenzioni Naming

### File e Classi
- **Screen**: `{mode}_screen.dart` → `{Mode}Screen`
- **Provider**: `{mode}_provider.dart` → `{Mode}Notifier` 
- **Game Model**: `{mode}_game.dart` → `{Mode}TicTacToeGame`
- **Progress**: `{mode}_strategy_progress.dart` → `{Mode}StrategyProgress`
- **Strategies**: `{mode}_ai_strategy.dart` → `{Mode}AIStrategy`
- **Drawer**: `{mode}_strategy_drawer.dart` → `{Mode}StrategyDrawer`

### Enum Values
```dart
enum {Mode}AIStrategy {
  // Descrittivi ma generici finché possibile
  supportive, defensive, random,        // Easy
  coordinated, aggressive, balanced,    // Medium  
  tactical, adaptive, optimal          // Hard
}
```

## Testing e Quality Assurance

### Checklist Pre-Release
- [ ] Build web success senza errori critici
- [ ] Drawer responsive su diverse dimensioni schermo  
- [ ] Tutte le strategie implementate (9 totali)
- [ ] Progress tracking funzionante
- [ ] Dialog strategie con counter-strategies multiple
- [ ] Colori tematici coerenti
- [ ] Nomi generici → reali dopo sconfitta
- [ ] Info button solo per strategie sconfitte

### Performance Standards
- **Build time**: < 30 secondi per `flutter build web`
- **Bundle size**: Ottimizzazione tree-shaking attiva
- **Responsiveness**: UI fluida su dispositivi mobile e desktop

## Estensibilità

### Aggiunta Nuova Modalità
1. Creare struttura file seguendo il pattern
2. Implementare 9 strategie AI (3 per difficoltà)  
3. Definire DrawerConfig con colori unici
4. Integrare BaseStrategyDrawer
5. Implementare DialogUtils per counter-strategies
6. Aggiornare routing in `main.dart`
7. Aggiungere entry in main menu

### Modifiche ai Standard
Qualsiasi modifica a questi standard deve:
1. Essere documentata in questo file
2. Essere applicata retroattivamente a tutte le modalità esistenti
3. Mantenere compatibilità con la struttura unificata

---

**Nota**: Questi standard garantiscono coerenza, manutenibilità e scalabilità del progetto Tacticafé. L'aderenza a questi pattern è essenziale per l'integrità dell'architettura dell'applicazione.