import 'dart:math';

enum GuessPlayer { ai1, ai2, none }
enum GuessGameStatus { waitingForBet, ai1Turn, ai2Turn, gameOver }

class GuessTicTacToeGame {
  final List<GuessPlayer> board;
  final GuessPlayer currentPlayer;
  final GuessGameStatus status;
  final int currentTurn;
  final int userBet; // -1 = no bet, altro = indice della cella su cui scommette
  final List<int> userBets; // Storico delle scommesse per turni AI1
  final List<int> ai1Moves; // Mosse effettive di AI1
  final int correctBets;
  final GuessPlayer? winner;
  final List<int>? winningLine;

  const GuessTicTacToeGame({
    required this.board,
    required this.currentPlayer,
    required this.status,
    required this.currentTurn,
    required this.userBet,
    required this.userBets,
    required this.ai1Moves,
    required this.correctBets,
    this.winner,
    this.winningLine,
  });

  factory GuessTicTacToeGame.initial() {
    return GuessTicTacToeGame(
      board: List.filled(9, GuessPlayer.none),
      currentPlayer: GuessPlayer.ai1, // AI1 inizia sempre (X)
      status: GuessGameStatus.waitingForBet,
      currentTurn: 1,
      userBet: -1,
      userBets: [],
      ai1Moves: [],
      correctBets: 0,
    );
  }

  GuessTicTacToeGame copyWith({
    List<GuessPlayer>? board,
    GuessPlayer? currentPlayer,
    GuessGameStatus? status,
    int? currentTurn,
    int? userBet,
    List<int>? userBets,
    List<int>? ai1Moves,
    int? correctBets,
    GuessPlayer? winner,
    List<int>? winningLine,
  }) {
    return GuessTicTacToeGame(
      board: board ?? List.from(this.board),
      currentPlayer: currentPlayer ?? this.currentPlayer,
      status: status ?? this.status,
      currentTurn: currentTurn ?? this.currentTurn,
      userBet: userBet ?? this.userBet,
      userBets: userBets ?? List.from(this.userBets),
      ai1Moves: ai1Moves ?? List.from(this.ai1Moves),
      correctBets: correctBets ?? this.correctBets,
      winner: winner ?? this.winner,
      winningLine: winningLine ?? this.winningLine,
    );
  }

  // L'utente piazza la scommessa per la prossima mossa di AI1
  GuessTicTacToeGame placeBet(int cellIndex) {
    if (status != GuessGameStatus.waitingForBet || 
        board[cellIndex] != GuessPlayer.none) {
      return this;
    }

    return copyWith(
      userBet: cellIndex,
      status: GuessGameStatus.ai1Turn,
    );
  }

  // AI1 fa la sua mossa
  GuessTicTacToeGame makeAI1Move() {
    if (status != GuessGameStatus.ai1Turn) {
      return this;
    }

    final availableMoves = <int>[];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == GuessPlayer.none) {
        availableMoves.add(i);
      }
    }

    if (availableMoves.isEmpty) {
      return _checkGameEnd();
    }

    // Strategia AI1: moderatamente intelligente
    int ai1Move = _findAI1Move(availableMoves);

    final newBoard = List<GuessPlayer>.from(board);
    newBoard[ai1Move] = GuessPlayer.ai1;

    final newAI1Moves = List<int>.from(ai1Moves);
    newAI1Moves.add(ai1Move);

    final newUserBets = List<int>.from(userBets);
    newUserBets.add(userBet);

    int newCorrectBets = correctBets;
    if (userBet == ai1Move) {
      newCorrectBets++;
    }

    // Controlla se il gioco è finito
    final winResult = _checkWinCondition(newBoard);
    if (winResult.winner != null) {
      return copyWith(
        board: newBoard,
        ai1Moves: newAI1Moves,
        userBets: newUserBets,
        correctBets: newCorrectBets,
        winner: winResult.winner,
        winningLine: winResult.winningLine,
        status: GuessGameStatus.gameOver,
        userBet: -1,
      );
    }

    // Controlla pareggio
    if (newBoard.every((cell) => cell != GuessPlayer.none)) {
      return copyWith(
        board: newBoard,
        ai1Moves: newAI1Moves,
        userBets: newUserBets,
        correctBets: newCorrectBets,
        status: GuessGameStatus.gameOver,
        userBet: -1,
      );
    }

    // Passa il turno ad AI2
    return copyWith(
      board: newBoard,
      currentPlayer: GuessPlayer.ai2,
      ai1Moves: newAI1Moves,
      userBets: newUserBets,
      correctBets: newCorrectBets,
      status: GuessGameStatus.ai2Turn,
      userBet: -1,
    );
  }

  // AI2 fa la sua mossa
  GuessTicTacToeGame makeAI2Move() {
    if (status != GuessGameStatus.ai2Turn) {
      return this;
    }

    final availableMoves = <int>[];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == GuessPlayer.none) {
        availableMoves.add(i);
      }
    }

    if (availableMoves.isEmpty) {
      return _checkGameEnd();
    }

    // Strategia AI2: più aggressiva e intelligente
    int ai2Move = _findAI2Move(availableMoves);

    final newBoard = List<GuessPlayer>.from(board);
    newBoard[ai2Move] = GuessPlayer.ai2;

    // Controlla se il gioco è finito
    final winResult = _checkWinCondition(newBoard);
    if (winResult.winner != null) {
      return copyWith(
        board: newBoard,
        winner: winResult.winner,
        winningLine: winResult.winningLine,
        status: GuessGameStatus.gameOver,
      );
    }

    // Controlla pareggio
    if (newBoard.every((cell) => cell != GuessPlayer.none)) {
      return copyWith(
        board: newBoard,
        status: GuessGameStatus.gameOver,
      );
    }

    // Passa il turno ad AI1 e aspetta la prossima scommessa
    return copyWith(
      board: newBoard,
      currentPlayer: GuessPlayer.ai1,
      currentTurn: currentTurn + 1,
      status: GuessGameStatus.waitingForBet,
    );
  }

  // Strategia AI1 (X): mediamente intelligente
  int _findAI1Move(List<int> availableMoves) {
    final random = Random();

    // 1. Cerca di vincere (probabilità 80%)
    if (random.nextDouble() < 0.8) {
      for (int move in availableMoves) {
        if (_wouldWin(move, GuessPlayer.ai1)) {
          return move;
        }
      }
    }

    // 2. Blocca AI2 se sta per vincere (probabilità 70%)
    if (random.nextDouble() < 0.7) {
      for (int move in availableMoves) {
        if (_wouldWin(move, GuessPlayer.ai2)) {
          return move;
        }
      }
    }

    // 3. Prende il centro se disponibile (probabilità 60%)
    if (availableMoves.contains(4) && random.nextDouble() < 0.6) {
      return 4;
    }

    // 4. Prende gli angoli (probabilità 50%)
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((corner) => availableMoves.contains(corner)).toList();
    if (availableCorners.isNotEmpty && random.nextDouble() < 0.5) {
      return availableCorners[random.nextInt(availableCorners.length)];
    }

    // 5. Mossa casuale
    return availableMoves[random.nextInt(availableMoves.length)];
  }

  // Strategia AI2 (O): più intelligente e aggressiva
  int _findAI2Move(List<int> availableMoves) {
    final random = Random();

    // 1. Cerca di vincere (probabilità 95%)
    for (int move in availableMoves) {
      if (_wouldWin(move, GuessPlayer.ai2)) {
        return move;
      }
    }

    // 2. Blocca AI1 se sta per vincere (probabilità 90%)
    for (int move in availableMoves) {
      if (_wouldWin(move, GuessPlayer.ai1)) {
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
      return availableCorners[random.nextInt(availableCorners.length)];
    }

    // 5. Mossa casuale
    return availableMoves[random.nextInt(availableMoves.length)];
  }

  // Controlla se una mossa porterebbe alla vittoria
  bool _wouldWin(int index, GuessPlayer player) {
    final tempBoard = List<GuessPlayer>.from(board);
    tempBoard[index] = player;
    return _checkWinCondition(tempBoard).winner == player;
  }

  // Controlla condizioni di vittoria
  ({GuessPlayer? winner, List<int>? winningLine}) _checkWinCondition(List<GuessPlayer> gameBoard) {
    const winningPositions = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // righe
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // colonne
      [0, 4, 8], [2, 4, 6], // diagonali
    ];

    for (final positions in winningPositions) {
      final a = gameBoard[positions[0]];
      final b = gameBoard[positions[1]];
      final c = gameBoard[positions[2]];

      if (a != GuessPlayer.none && a == b && b == c) {
        return (winner: a, winningLine: positions);
      }
    }
    return (winner: null, winningLine: null);
  }

  GuessTicTacToeGame _checkGameEnd() {
    return copyWith(status: GuessGameStatus.gameOver);
  }

  // Reset del gioco
  GuessTicTacToeGame reset() {
    return GuessTicTacToeGame.initial();
  }

  // Helper per ottenere il simbolo da visualizzare
  String getSymbol(int index) {
    switch (board[index]) {
      case GuessPlayer.ai1:
        return 'X';
      case GuessPlayer.ai2:
        return 'O';
      case GuessPlayer.none:
        return '';
    }
  }

  // Helper per sapere se una cella è nella linea vincente
  bool isWinningCell(int index) {
    return winningLine?.contains(index) ?? false;
  }

  // Helper per la percentuale di scommesse corrette
  double get bettingAccuracy {
    if (userBets.isEmpty) return 0.0;
    return (correctBets / userBets.length) * 100;
  }

  // Helper per sapere se l'utente ha piazzato una scommessa su questa cella
  bool isBetCell(int index) {
    return userBet == index;
  }

  // Helper per sapere se questa cella è stata l'ultima mossa corretta
  bool isLastCorrectBet(int index) {
    if (ai1Moves.isEmpty || userBets.isEmpty) return false;
    final lastAI1Move = ai1Moves.last;
    final lastUserBet = userBets.last;
    return index == lastAI1Move && lastUserBet == lastAI1Move;
  }

  // Helper per sapere se questa cella è stata l'ultima mossa sbagliata
  bool isLastWrongBet(int index) {
    if (ai1Moves.isEmpty || userBets.isEmpty) return false;
    final lastAI1Move = ai1Moves.last;
    final lastUserBet = userBets.last;
    return index == lastUserBet && lastUserBet != lastAI1Move;
  }
}