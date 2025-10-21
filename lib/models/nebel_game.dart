import 'dart:math';

enum NebelPlayer { human, ai, none }
enum NebelGameStatus { playing, humanWon, aiWon, tie }

// Risultato del click su una cella nascosta
enum NebelClickResult { 
  placedMove,      // Cella vuota, mossa piazzata
  revealedEnemy,   // Cella dell'AI rivelata
  invalid          // Click non valido
}

// Wrapper per il risultato dell'azione su una cella nascosta
class NebelTicTacToeResult {
  final NebelTicTacToeGame game;
  final NebelClickResult result;

  const NebelTicTacToeResult(this.game, this.result);
}

class NebelTicTacToeGame {
  final List<NebelPlayer> board;
  final List<bool> hiddenCells; // true = cella nascosta
  final NebelPlayer currentPlayer;
  final NebelGameStatus status;
  final List<int>? winningLine;

  const NebelTicTacToeGame({
    required this.board,
    required this.hiddenCells,
    required this.currentPlayer,
    required this.status,
    this.winningLine,
  });

  factory NebelTicTacToeGame.initial() {
    // Nascondiamo sempre 5 celle all'inizio
    final random = Random();
    final hiddenCells = List.filled(9, false);
    
    // Scegliamo casualmente 5 celle da nascondere
    final availableIndices = List.generate(9, (index) => index);
    
    for (int i = 0; i < 5; i++) {
      final randomIndex = random.nextInt(availableIndices.length);
      final cellIndex = availableIndices.removeAt(randomIndex);
      hiddenCells[cellIndex] = true;
    }

    return NebelTicTacToeGame(
      board: List.filled(9, NebelPlayer.none),
      hiddenCells: hiddenCells,
      currentPlayer: NebelPlayer.human,
      status: NebelGameStatus.playing,
      winningLine: null,
    );
  }

  NebelTicTacToeGame copyWith({
    List<NebelPlayer>? board,
    List<bool>? hiddenCells,
    NebelPlayer? currentPlayer,
    NebelGameStatus? status,
    List<int>? winningLine,
  }) {
    return NebelTicTacToeGame(
      board: board ?? this.board,
      hiddenCells: hiddenCells ?? this.hiddenCells,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      status: status ?? this.status,
      winningLine: winningLine ?? this.winningLine,
    );
  }

  // Controlla se c'è un vincitore
  NebelGameStatus _checkGameStatus(List<NebelPlayer> newBoard) {
    final winner = _hasWinner(newBoard);
    
    if (winner == NebelPlayer.human) {
      return NebelGameStatus.humanWon;
    } else if (winner == NebelPlayer.ai) {
      return NebelGameStatus.aiWon;
    }

    // Controlla pareggio
    if (newBoard.every((cell) => cell != NebelPlayer.none)) {
      return NebelGameStatus.tie;
    }

    return NebelGameStatus.playing;
  }

  // Trova la linea vincente
  List<int>? _findWinningLine(List<NebelPlayer> board) {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Righe
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonne
      [0, 4, 8], [2, 4, 6] // Diagonali
    ];

    for (final pattern in winPatterns) {
      final [a, b, c] = pattern;
      if (board[a] != NebelPlayer.none &&
          board[a] == board[b] &&
          board[b] == board[c]) {
        return pattern;
      }
    }
    return null;
  }

  // Mossa del giocatore umano su cella visibile
  NebelTicTacToeGame makeHumanMove(int index) {
    if (status != NebelGameStatus.playing || 
        board[index] != NebelPlayer.none || 
        currentPlayer != NebelPlayer.human ||
        hiddenCells[index]) {
      return this;
    }

    final newBoard = List<NebelPlayer>.from(board);
    newBoard[index] = NebelPlayer.human;
    
    final newStatus = _checkGameStatus(newBoard);
    final winningLine = _findWinningLine(newBoard);

    return copyWith(
      board: newBoard,
      currentPlayer: newStatus == NebelGameStatus.playing ? NebelPlayer.ai : currentPlayer,
      status: newStatus,
      winningLine: winningLine,
    );
  }

  // Click su cella nascosta - rivela se c'è qualcosa o errore se libera
  NebelTicTacToeResult revealHiddenCell(int index) {
    if (!hiddenCells[index] || status != NebelGameStatus.playing || currentPlayer != NebelPlayer.human) {
      return NebelTicTacToeResult(this, NebelClickResult.invalid);
    }

    final newHiddenCells = List<bool>.from(hiddenCells);
    newHiddenCells[index] = false;

    // Se la cella era occupata dall'AI, mostrala
    if (board[index] == NebelPlayer.ai) {
      return NebelTicTacToeResult(
        copyWith(hiddenCells: newHiddenCells),
        NebelClickResult.revealedEnemy,
      );
    } 
    // Se la cella era vuota, il giocatore può giocarci
    else if (board[index] == NebelPlayer.none) {
      final newBoard = List<NebelPlayer>.from(board);
      newBoard[index] = NebelPlayer.human;
      
      final newStatus = _checkGameStatus(newBoard);
      final winningLine = _findWinningLine(newBoard);

      return NebelTicTacToeResult(
        copyWith(
          board: newBoard,
          hiddenCells: newHiddenCells,
          currentPlayer: newStatus == NebelGameStatus.playing ? NebelPlayer.ai : currentPlayer,
          status: newStatus,
          winningLine: winningLine,
        ),
        NebelClickResult.placedMove,
      );
    }

    return NebelTicTacToeResult(this, NebelClickResult.invalid);
  }

  // Mossa dell'AI
  NebelTicTacToeGame makeAIMove() {
    if (status != NebelGameStatus.playing || currentPlayer != NebelPlayer.ai) {
      return this;
    }

    final availableMoves = <int>[];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == NebelPlayer.none) {
        availableMoves.add(i);
      }
    }

    if (availableMoves.isEmpty) {
      return this;
    }

    // L'AI può giocare su qualsiasi cella libera (anche nascoste)
    int aiMove = _findBestMove(availableMoves);

    final newBoard = List<NebelPlayer>.from(board);
    newBoard[aiMove] = NebelPlayer.ai;

    final newStatus = _checkGameStatus(newBoard);
    final winningLine = _findWinningLine(newBoard);

    return copyWith(
      board: newBoard,
      currentPlayer: newStatus == NebelGameStatus.playing ? NebelPlayer.human : currentPlayer,
      status: newStatus,
      winningLine: winningLine,
    );
  }

  // Strategia AI - gioca su qualsiasi cella libera
  int _findBestMove(List<int> availableMoves) {
    final random = Random();

    // 1. Cerca di vincere
    for (int move in availableMoves) {
      if (_wouldWin(move, NebelPlayer.ai)) {
        return move;
      }
    }

    // 2. Blocca l'umano se sta per vincere
    for (int move in availableMoves) {
      if (_wouldWin(move, NebelPlayer.human)) {
        return move;
      }
    }

    // 3. Prende il centro se disponibile
    if (availableMoves.contains(4)) {
      return 4;
    }

    // 4. Prende gli angoli se disponibili
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((corner) => availableMoves.contains(corner)).toList();
    if (availableCorners.isNotEmpty) {
      return availableCorners[random.nextInt(availableCorners.length)];
    }

    // 5. Mossa casuale
    return availableMoves[random.nextInt(availableMoves.length)];
  }

    // Controlla se una mossa porterebbe alla vittoria
  bool _wouldWin(int index, NebelPlayer player) {
    // Crea una copia del board per simulare la mossa
    final tempBoard = List<NebelPlayer?>.from(board);
    tempBoard[index] = player;
    return _hasWinner(tempBoard) == player;
  }

  // Controlla se c'è un vincitore nel board dato
  NebelPlayer? _hasWinner(List<NebelPlayer?> gameBoard) {
    const winningPositions = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // righe
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // colonne
      [0, 4, 8], [2, 4, 6], // diagonali
    ];

    for (final positions in winningPositions) {
      final a = gameBoard[positions[0]];
      final b = gameBoard[positions[1]];
      final c = gameBoard[positions[2]];

      if (a != null && a == b && b == c) {
        return a;
      }
    }
    return null;
  }

  // Getter per il vincitore
  NebelPlayer? get winner => _hasWinner(board);

  // Reset del gioco
  NebelTicTacToeGame reset() {
    return NebelTicTacToeGame.initial();
  }

  // Helper per ottenere il simbolo da visualizzare
  String getSymbol(int index) {
    if (hiddenCells[index]) {
      return '?';
    }
    
    switch (board[index]) {
      case NebelPlayer.human:
        return 'X';
      case NebelPlayer.ai:
        return 'O';
      case NebelPlayer.none:
        return '';
    }
  }

  // Helper per sapere se una cella è nascosta
  bool isCellHidden(int index) {
    return hiddenCells[index];
  }

  // Helper per sapere se una cella è nella linea vincente
  bool isWinningCell(int index) {
    return winningLine?.contains(index) ?? false;
  }

  // Helper per sapere se una cella è cliccabile
  bool isCellClickable(int index) {
    return !hiddenCells[index] && 
           board[index] == NebelPlayer.none && 
           currentPlayer == NebelPlayer.human &&
           status == NebelGameStatus.playing;
  }

  // Conta le celle ancora nascoste
  int get hiddenCellsCount {
    return hiddenCells.where((hidden) => hidden).length;
  }
}