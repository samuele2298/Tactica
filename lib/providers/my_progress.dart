import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';

/// Stato di progresso di una singola strategia
class Progress {
  final int consecutiveWins;
  final int winsNeeded;
  final bool isDefeated;

  const Progress({
    required this.consecutiveWins,
    required this.winsNeeded,
    required this.isDefeated,
  });
}

/// Stato globale semplificato del giocatore
class GlobalProgressState {
  /// Map<gameMode, Map<strategyName, consecutiveWins>>
  final Map<AIMode, Map<String, int>> _wins = {};
  /// Map<gameMode, Map<strategyName, isDefeated>>
  final Map<AIMode, Map<String, bool>> _defeated = {};

  GlobalProgressState();

  GlobalProgressState copyWith({
    Map<AIMode, Map<String, int>>? wins,
    Map<AIMode, Map<String, bool>>? defeated,
  }) {
    return GlobalProgressState()
      .._wins.addAll(wins ?? _wins)
      .._defeated.addAll(defeated ?? _defeated);
  }
}

/// Provider semplificato per gestire progresso
class GlobalProgressNotifier extends StateNotifier<GlobalProgressState> {
  GlobalProgressNotifier() : super(GlobalProgressState());

  /// Registra una vittoria contro una strategia specifica
  void addWin(AIStrategy strategy) {
    final mode = strategy.mode;
    final key = strategy.toString();

    state._wins[mode] ??= {};
    state._defeated[mode] ??= {};

    final currentWins = state._wins[mode]![key] ?? 0;
    final newWins = currentWins + 1;
    state._wins[mode]![key] = newWins;

    if (newWins >= 3) {
      state._defeated[mode]![key] = true;
    }

    state = state; // trigger update
  }

  /// Registra una sconfitta (reset contatore vittorie consecutive)
  void addLoss(AIStrategy strategy) {
    final mode = strategy.mode;
    final key = strategy.toString();

    state._wins[mode] ??= {};
    state._wins[mode]![key] = 0;

    state = state; // trigger update
  }

  /// Ottieni lo stato di progresso di una strategia
  Progress getProgress(AIStrategy strategy) {
    final mode = strategy.mode;
    final key = strategy.toString();

    final wins = state._wins[mode]?[key] ?? 0;
    final defeated = state._defeated[mode]?[key] ?? false;

    return Progress(
      consecutiveWins: wins,
      winsNeeded: defeated ? 0 : 3 - wins,
      isDefeated: defeated,
    );
  }

  /// Resetta tutto
  void reset() {
    state = GlobalProgressState();
  }
}

/// Provider globale
final globalProgressProvider =
    StateNotifierProvider<GlobalProgressNotifier, GlobalProgressState>(
  (ref) => GlobalProgressNotifier(),
);
