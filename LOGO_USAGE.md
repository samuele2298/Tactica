# TacticaFe Logo Usage Guide

## Logo Component

The `TacticafeLogo` widget provides a consistent logo display across the application.

### Usage Examples

```dart
// Small logo (24x24) for app bars
TacticafeLogo.small()

// Medium logo (48x48) for dialogs  
TacticafeLogo.medium()

// Large animated logo (80x80) for main screens
TacticafeLogo.large(animated: true)

// Custom configuration
TacticafeLogo(
  size: LogoSize.extraLarge,
  animated: true,
  animationDuration: Duration(seconds: 2),
  colorFilter: Colors.white, // For theming
)
```

### Size Options
- `LogoSize.small` - 24x24px (for app bars, buttons)
- `LogoSize.medium` - 48x48px (for dialogs, cards)  
- `LogoSize.large` - 80x80px (for main screens)
- `LogoSize.extraLarge` - 120x120px (for splash screens)

### Animation
When `animated: true` is set, the logo will have a subtle breathing animation with:
- Scale variation: 1.0 to 1.05
- Rotation variation: 0 to 0.02 radians
- Duration: 3 seconds (customizable)
- Repeats: Infinite with reverse

## Supporting Widgets

### LoadingScreen
Full-screen loading with animated logo:
```dart
LoadingScreen(message: 'Caricamento in corso...')
```

### LoadingWidget  
Inline loading component:
```dart
LoadingWidget(message: 'Salvataggio...', size: 48)
```

### ErrorScreen
Error page with recovery options:
```dart
ErrorScreen(
  title: 'Errore di connessione',
  message: 'Verifica la tua connessione internet',
  onRetry: () => retryConnection(),
)
```

## Logo Files
- `assets/images/tacticafe_logo.svg` - Main military-themed logo (120x120)
- `assets/images/tacticafe_favicon.svg` - Military favicon (32x32)
- Both feature military shield design with tactical elements

## Design Elements
The new military logo features:
- **Shield shape**: Classic military/tactical aesthetic
- **Tactical grid**: 3x3 tic-tac-toe grid representing core gameplay
- **Military chevrons**: Rank symbols indicating hierarchy and strategy
- **Tactical crosshairs**: Precision and targeting elements
- **Strategic markers**: Side tactical marks and corner symbols

## Integration Points
The logo is integrated in:
- Main menu screen (animated large logo with military theme)
- Classic game screen app bar (small logo)
- Web favicon and manifest (military shield icon)
- Available for all other screens as needed

## Colors and Theming
The military logo uses a cohesive green color scheme:
- **Primary**: Military green gradient (#2E7D32 to #1B5E20)
- **Secondary**: Light green accents (#4CAF50, #66BB6A, #A5D6A7)
- **Background**: Dark military gray shield (#37474F to #263238)
- **Highlights**: White tactical elements with transparency