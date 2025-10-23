import 'dart:math';
import 'package:flutter/material.dart';

enum CoopPlayer { none, team, enemy }
enum CoopGameStatus { humanTurn, enemyAiTurn, friendlyAiTurn, teamWon, enemyWon, tie }

class CoopTicTacToeGame {
  final List<CoopPlayer> board;
  final CoopGameStatus status;
  final List<int>? winningLine;
  final String lastMoveDescription;

  const CoopTicTacToeGame({
    required this.board,
    required this.status,
    this.winningLine,
    this.lastMoveDescription = '',
  });

  factory CoopTicTacToeGame.initial() {
    return const CoopTicTacToeGame(
      board: [
        CoopPlayer.none, CoopPlayer.none, CoopPlayer.none,
        CoopPlayer.none, CoopPlayer.none, CoopPlayer.none,
        CoopPlayer.none, CoopPlayer.none, CoopPlayer.none,
      ],
      status: CoopGameStatus.humanTurn,
      winningLine: null,
      lastMoveDescription: 'È il tuo turno! Inizia la cooperazione con la tua AI amica.',
    );
  }

  CoopTicTacToeGame copyWith({
    List<CoopPlayer>? board,
    CoopGameStatus? status,
    List<int>? winningLine,
    String? lastMoveDescription,
  }) {
    return CoopTicTacToeGame(
      board: board ?? this.board,
      status: status ?? this.status,
      winningLine: winningLine ?? this.winningLine,
      lastMoveDescription: lastMoveDescription ?? this.lastMoveDescription,
    );
  }

  // Controlla se c'è un vincitore
  CoopGameStatus _checkGameStatus(List<CoopPlayer> newBoard) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Righe
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonne
      [0, 4, 8], [2, 4, 6] // Diagonali
    ];

    for (final pattern in winPatterns) {
      final [a, b, c] = pattern;
      if (newBoard[a] != CoopPlayer.none &&
          newBoard[a] == newBoard[b] &&
          newBoard[b] == newBoard[c]) {
        return newBoard[a] == CoopPlayer.team 
            ? CoopGameStatus.teamWon 
            : CoopGameStatus.enemyWon;
      }
    }

    // Controlla pareggio
    if (newBoard.every((cell) => cell != CoopPlayer.none)) {
      return CoopGameStatus.tie;
    }

    // Il gioco continua
    return status;
  }

  // Trova la linea vincente
  List<int>? _findWinningLine(List<CoopPlayer> board) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Righe
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonne
      [0, 4, 8], [2, 4, 6] // Diagonali
    ];

    for (final pattern in winPatterns) {
      final [a, b, c] = pattern;
      if (board[a] != CoopPlayer.none &&
          board[a] == board[b] &&
          board[b] == board[c]) {
        return pattern;
      }
    }
    return null;
  }

  // Mossa del giocatore umano
  CoopTicTacToeGame makeHumanMove(int index) {
    if (status != CoopGameStatus.humanTurn || 
        board[index] != CoopPlayer.none) {
      return this;
    }

    final newBoard = List<CoopPlayer>.from(board);
    newBoard[index] = CoopPlayer.team;
    
    final newStatus = _checkGameStatus(newBoard);
    final winningLine = _findWinningLine(newBoard);

    if (newStatus == CoopGameStatus.teamWon || 
        newStatus == CoopGameStatus.enemyWon || 
        newStatus == CoopGameStatus.tie) {
      return copyWith(
        board: newBoard,
        status: newStatus,
        winningLine: winningLine,
        lastMoveDescription: 'Hai fatto una mossa ottima!',
      );
    }

    return copyWith(
      board: newBoard,
      status: CoopGameStatus.enemyAiTurn,
      winningLine: winningLine,
      lastMoveDescription: 'Hai fatto una mossa ottima! Ora tocca all\'AI nemica.',
    );
  }

  // Mossa dell'AI amica (strategica - cerca di vincere o bloccare)
  CoopTicTacToeGame makeFriendlyAIMove() {
    if (status != CoopGameStatus.friendlyAiTurn) {
      return this;
    }

    final availableMoves = <int>[];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == CoopPlayer.none) {
        availableMoves.add(i);
      }
    }

    if (availableMoves.isEmpty) {
      return this;
    }

    int aiMove = _findBestFriendlyMove(availableMoves);

    final newBoard = List<CoopPlayer>.from(board);
    newBoard[aiMove] = CoopPlayer.team;

    final newStatus = _checkGameStatus(newBoard);
    final winningLine = _findWinningLine(newBoard);

    if (newStatus == CoopGameStatus.teamWon || 
        newStatus == CoopGameStatus.enemyWon || 
        newStatus == CoopGameStatus.tie) {
      return copyWith(
        board: newBoard,
        status: newStatus,
        winningLine: winningLine,
        lastMoveDescription: 'La tua AI amica ha fatto una mossa intelligente!',
      );
    }

    return copyWith(
      board: newBoard,
      status: CoopGameStatus.humanTurn,
      winningLine: winningLine,
      lastMoveDescription: 'La tua AI amica ti ha aiutato! Il tuo turno.',
    );
  }

  // Mossa dell'AI nemica (anche lei strategica)
  CoopTicTacToeGame makeEnemyAIMove() {
    if (status != CoopGameStatus.enemyAiTurn) {
      return this;
    }

    final availableMoves = <int>[];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == CoopPlayer.none) {
        availableMoves.add(i);
      }
    }

    if (availableMoves.isEmpty) {
      return this;
    }

    int aiMove = _findBestEnemyMove(availableMoves);

    final newBoard = List<CoopPlayer>.from(board);
    newBoard[aiMove] = CoopPlayer.enemy;

    final newStatus = _checkGameStatus(newBoard);
    final winningLine = _findWinningLine(newBoard);

    if (newStatus == CoopGameStatus.teamWon || 
        newStatus == CoopGameStatus.enemyWon || 
        newStatus == CoopGameStatus.tie) {
      return copyWith(
        board: newBoard,
        status: newStatus,
        winningLine: winningLine,
        lastMoveDescription: 'L\'AI nemica ha giocato!',
      );
    }

    return copyWith(
      board: newBoard,
      status: CoopGameStatus.friendlyAiTurn,
      winningLine: winningLine,
      lastMoveDescription: 'L\'AI nemica ha giocato. Ora tocca alla tua AI amica.',
    );
  }

  // Strategia per l'AI amica - cerca prima di vincere, poi di bloccare l'AI nemica
  int _findBestFriendlyMove(List<int> availableMoves) {
    // 1. Cerca di vincere
    for (int move in availableMoves) {
      if (_wouldWin(move, CoopPlayer.team)) {
        return move;
      }
    }

    // 2. Blocca l'AI nemica se sta per vincere
    for (int move in availableMoves) {
      if (_wouldWin(move, CoopPlayer.enemy)) {
        return move;
      }
    }

    // 3. Prende il centro se disponibile
    if (availableMoves.contains(4)) {
      return 4;
    }

    // 4. Prende gli angoli
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((corner) => availableMoves.contains(corner)).toList();
    if (availableCorners.isNotEmpty) {
      return availableCorners[Random().nextInt(availableCorners.length)];
    }

    // 5. Mossa casuale
    return availableMoves[Random().nextInt(availableMoves.length)];
  }

  // Strategia per l'AI nemica - cerca di vincere o bloccare il team
  int _findBestEnemyMove(List<int> availableMoves) {
    // 1. Cerca di vincere
    for (int move in availableMoves) {
      if (_wouldWin(move, CoopPlayer.enemy)) {
        return move;
      }
    }

    // 2. Blocca il team se sta per vincere
    for (int move in availableMoves) {
      if (_wouldWin(move, CoopPlayer.team)) {
        return move;
      }
    }

    // 3. Strategia simile all'AI amica
    if (availableMoves.contains(4)) {
      return 4;
    }

    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((corner) => availableMoves.contains(corner)).toList();
    if (availableCorners.isNotEmpty) {
      return availableCorners[Random().nextInt(availableCorners.length)];
    }

    return availableMoves[Random().nextInt(availableMoves.length)];
  }

  // Controlla se una mossa porterebbe alla vittoria
  bool _wouldWin(int move, CoopPlayer player) {
    final testBoard = List<CoopPlayer>.from(board);
    testBoard[move] = player;
    
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Righe
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonne
      [0, 4, 8], [2, 4, 6] // Diagonali
    ];

    for (final pattern in winPatterns) {
      final [a, b, c] = pattern;
      if (testBoard[a] == player &&
          testBoard[a] == testBoard[b] &&
          testBoard[b] == testBoard[c]) {
        return true;
      }
    }
    return false;
  }

  // Reset del gioco
  CoopTicTacToeGame reset() {
    return CoopTicTacToeGame.initial();
  }

  // Helper per ottenere il simbolo da visualizzare
  String getSymbol(int index) {
    switch (board[index]) {
      case CoopPlayer.team:
        return 'X';
      case CoopPlayer.enemy:
        return 'O';
      case CoopPlayer.none:
        return '';
    }
  }

  // Helper per sapere se una cella è nella linea vincente
  bool isWinningCell(int index) {
    return winningLine?.contains(index) ?? false;
  }

  // Helper per ottenere il colore del simbolo
  Color getSymbolColor(int index) {
    switch (board[index]) {
      case CoopPlayer.team:
        return const Color(0xFF4CAF50); // Verde per il team
      case CoopPlayer.enemy:
        return const Color(0xFFE91E63); // Rosa per il nemico
      case CoopPlayer.none:
        return Colors.transparent;
    }
  }
}