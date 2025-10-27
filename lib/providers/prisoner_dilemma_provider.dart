import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prisoner_dilemma_game.dart';

class PrisonerDilemmaNotifier extends StateNotifier<PrisonerDilemmaGame> {
  PrisonerDilemmaNotifier() : super(
    const PrisonerDilemmaGame(
      settings: GameSettings(
        botStrategy: BotStrategy.titForTat,
        totalRounds: 5,
      ),
    ),
  );

  final Random _random = Random();

  /// Inizia un nuovo gioco con le impostazioni specificate
  void startNewGame(GameSettings settings) {
    state = PrisonerDilemmaGame(
      settings: settings,
      rounds: [],
      currentRound: 1,
      isGameFinished: false,
      totalPlayerScore: 0,
      totalBotScore: 0,
    );
  }

  /// Gioca un round con l'azione del giocatore
  void playRound(PlayerAction playerAction) {
    if (state.isGameFinished || state.currentRound > state.settings.totalRounds) {
      return;
    }

    // Determina l'azione del bot
    final botAction = _getBotAction(playerAction);

    // Calcola i payoff
    final payoffs = PrisonerDilemmaGame.getPayoffs(playerAction, botAction);
    final playerPayoff = payoffs['player']!;
    final botPayoff = payoffs['bot']!;

    // Crea il round
    final round = GameRound(
      roundNumber: state.currentRound,
      playerAction: playerAction,
      botAction: botAction,
      playerPayoff: playerPayoff,
      botPayoff: botPayoff,
    );

    // Aggiorna lo stato
    final newRounds = [...state.rounds, round];
    final newPlayerScore = state.totalPlayerScore + playerPayoff;
    final newBotScore = state.totalBotScore + botPayoff;
    final isFinished = state.currentRound >= state.settings.totalRounds;

    state = state.copyWith(
      rounds: newRounds,
      currentRound: state.currentRound + 1,
      isGameFinished: isFinished,
      totalPlayerScore: newPlayerScore,
      totalBotScore: newBotScore,
    );
  }

  /// Determina l'azione del bot in base alla strategia
  PlayerAction _getBotAction(PlayerAction playerAction) {
    switch (state.settings.botStrategy) {
      case BotStrategy.alwaysCooperate:
        return PlayerAction.cooperate;

      case BotStrategy.alwaysBetray:
        return PlayerAction.betray;

      case BotStrategy.random:
        return _random.nextBool() ? PlayerAction.cooperate : PlayerAction.betray;

      case BotStrategy.titForTat:
        // Nel primo round, coopera
        if (state.rounds.isEmpty) {
          return PlayerAction.cooperate;
        }
        // Negli altri round, imita l'ultima mossa del giocatore
        return state.rounds.last.playerAction;
    }
  }

  /// Reset del gioco
  void resetGame() {
    state = PrisonerDilemmaGame(
      settings: state.settings,
      rounds: [],
      currentRound: 1,
      isGameFinished: false,
      totalPlayerScore: 0,
      totalBotScore: 0,
    );
  }

  /// Ottieni l'analisi del gioco corrente
  GameAnalysis getGameAnalysis() {
    return GameAnalysis.analyzeGame(state);
  }
}

/// Provider per il gioco del Dilemma del Prigioniero
final prisonerDilemmaProvider = StateNotifierProvider<PrisonerDilemmaNotifier, PrisonerDilemmaGame>((ref) {
  return PrisonerDilemmaNotifier();
});

/// Provider per l'analisi del gioco
final gameAnalysisProvider = Provider<GameAnalysis?>((ref) {
  final game = ref.watch(prisonerDilemmaProvider);
  if (game.isGameFinished && game.rounds.isNotEmpty) {
    return GameAnalysis.analyzeGame(game);
  }
  return null;
});