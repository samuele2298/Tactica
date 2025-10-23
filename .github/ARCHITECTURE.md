# TacticaFe - File Structure Documentation

## 📁 Organized Architecture

The codebase has been restructured to promote reusability, maintainability, and consistency across all game modes.

### 🏗️ Core Structure

```
lib/
├── core/                          # Core interfaces and utilities
│   ├── interfaces/                # Common interfaces for all game modes
│   │   └── game_interfaces.dart   # GameStrategy, GameProgress, StrategyAdvice
│   ├── constants/                 # Shared constants and configurations
│   │   └── game_constants.dart    # TicTacToePatterns, GameModeColors, etc.
│   ├── utils/                     # Common utility functions
│   │   └── game_logic.dart        # TicTacToeUtils for game logic
│   └── core.dart                  # Core exports (import this for core functionality)
│
├── shared/                        # Reusable components across game modes
│   ├── widgets/                   # Shared UI widgets
│   │   ├── shared_strategy_drawer.dart      # Generic strategy drawer
│   │   └── shared_tic_tac_toe_board.dart   # Reusable tic tac toe board
│   ├── components/                # Shared UI components
│   │   └── strategy_info_dialog.dart       # Generic strategy info dialog
│   └── shared.dart                # Shared exports (import for reusable components)
│
├── strategies/                    # AI strategy implementations
│   ├── base/                      # Base strategy classes and interfaces
│   │   └── base_strategy.dart     # BaseAIStrategy, StrategicBehaviors mixin
│   ├── classic/                   # Classic mode strategies
│   ├── simultaneous/              # Simultaneous mode strategies
│   ├── coop/                      # Cooperative mode strategies
│   ├── nebel/                     # Nebel (fog of war) mode strategies
│   ├── guess/                     # Guess mode strategies
│   └── strategies.dart            # Strategy exports
│
├── models/                        # Game state models
├── providers/                     # Riverpod state management
├── screens/                       # UI screens
├── widgets/                       # Game-mode specific widgets
└── utils/                         # Utility functions
```

### 🎯 Design Principles

#### 1. **Interface-Based Design**
All game modes implement common interfaces:
- `GameStrategy`: Common strategy structure
- `GameProgress`: Progress tracking interface  
- `StrategyAdvice`: Counter-strategy advice interface
- `DrawerConfiguration`: Drawer appearance configuration

#### 2. **Shared Components**
Reusable components that work across all game modes:
- `SharedStrategyDrawer<T>`: Generic strategy drawer
- `SharedTicTacToeBoard`: Configurable game board
- `StrategyInfoDialog`: Strategy information display

#### 3. **Mixin-Based Strategy Implementation**
Common strategy behaviors are available through mixins:
```dart
class MyStrategy extends BaseAIStrategy with StrategicBehaviors {
  // Access to findWinningMoves(), findBlockingMoves(), etc.
}
```

#### 4. **Centralized Game Logic**
All tic tac toe logic is centralized in `TicTacToeUtils`:
- Win detection
- Available moves calculation
- Strategic move prioritization
- Board state utilities

### 🎨 Theme Consistency

Game modes have consistent theming through `GameModeColors`:
- **Classic**: Blue to Purple gradient
- **Simultaneous**: Orange to Deep Orange gradient  
- **Cooperative**: Green to Light Green gradient
- **Nebel**: Purple to Dark Purple gradient
- **Guess**: Orange to Deep Orange gradient

### 📦 Usage Examples

#### Using Core Functionality
```dart
import 'package:tacticafe/core/core.dart';

// Access to TicTacToeUtils, GameModeColors, etc.
final availableMoves = TicTacToeUtils.getAvailableMoves(board, emptyValue);
```

#### Using Shared Components
```dart
import 'package:tacticafe/shared/shared.dart';

// Use SharedStrategyDrawer for any game mode
SharedStrategyDrawer<MyStrategy>(
  config: StrategyDrawerConfig.forGameMode('classic'),
  // ...
)
```

#### Implementing New Strategies
```dart
import 'package:tacticafe/strategies/strategies.dart';

class NewEasyStrategy extends EasyStrategy with StrategicBehaviors {
  @override
  String get name => 'My Strategy';
  
  // Implementation...
}
```

### 🔄 Migration Benefits

1. **Reduced Code Duplication**: Common logic is shared across game modes
2. **Consistent UI**: All drawers and dialogs follow the same patterns
3. **Easy Maintenance**: Changes to shared components affect all game modes
4. **Scalability**: Adding new game modes is straightforward
5. **Type Safety**: Interfaces ensure consistent implementation

### 📚 File Organization Rules

- **`/core`**: Framework-level functionality, no UI dependencies
- **`/shared`**: Reusable UI components, depends on core
- **`/strategies`**: Game-specific strategy implementations
- **`/models`**: Game state and data structures
- **`/providers`**: Riverpod state management
- **`/screens`**: Complete screen implementations
- **`/widgets`**: Game-mode specific widgets

This structure ensures maintainable, scalable, and consistent code across the entire TacticaFe project.