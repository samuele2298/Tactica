import 'dart:math';

enum SimultaneousPlayer { none, human, ai }
enum SimultaneousGameStatus { selectingMoves, revealing, humanWon, aiWon, tie }

class SimultaneousTicTacToeGame {
  final List<SimultaneousPlayer> board;
  final SimultaneousGameStatus status;
  final List<int>? winningLine;
  final int? humanSelectedMove;
  final int? aiSelectedMove;
  final bool isRevealingMoves;

  const SimultaneousTicTacToeGame({
    required this.board,
    required this.status,
    this.winningLine,
    this.humanSelectedMove,
    this.aiSelectedMove,
    this.isRevealingMoves = false,
  });

  factory SimultaneousTicTacToeGame.initial() {
    return const SimultaneousTicTacToeGame(
      board: [
        SimultaneousPlayer.none, SimultaneousPlayer.none, SimultaneousPlayer.none,
        SimultaneousPlayer.none, SimultaneousPlayer.none, SimultaneousPlayer.none,
        SimultaneousPlayer.none, SimultaneousPlayer.none, SimultaneousPlayer.none,
      ],
      status: SimultaneousGameStatus.selectingMoves,
      winningLine: null,
    );
  }

  SimultaneousTicTacToeGame copyWith({
    List<SimultaneousPlayer>? board,
    SimultaneousGameStatus? status,
    List<int>? winningLine,
    int? humanSelectedMove,
    int? aiSelectedMove,
    bool? isRevealingMoves,
  }) {
    return SimultaneousTicTacToeGame(
      board: board ?? this.board,
      status: status ?? this.status,
      winningLine: winningLine ?? this.winningLine,
      humanSelectedMove: humanSelectedMove ?? this.humanSelectedMove,
      aiSelectedMove: aiSelectedMove ?? this.aiSelectedMove,
      isRevealingMoves: isRevealingMoves ?? this.isRevealingMoves,
    );
  }

  // Controlla se c'è un vincitore
  SimultaneousGameStatus _checkGameStatus(List<SimultaneousPlayer> newBoard) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Righe
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonne
      [0, 4, 8], [2, 4, 6] // Diagonali
    ];

    for (final pattern in winPatterns) {
      final [a, b, c] = pattern;
      if (newBoard[a] != SimultaneousPlayer.none &&
          newBoard[a] == newBoard[b] &&
          newBoard[b] == newBoard[c]) {
        return newBoard[a] == SimultaneousPlayer.human 
            ? SimultaneousGameStatus.humanWon 
            : SimultaneousGameStatus.aiWon;
      }
    }

    // Controlla pareggio
    if (newBoard.every((cell) => cell != SimultaneousPlayer.none)) {
      return SimultaneousGameStatus.tie;
    }

    return SimultaneousGameStatus.selectingMoves;
  }

  // Controlla se rimane solo una mossa disponibile
  bool _isLastMoveAvailable() {
    int emptyCells = 0;
    for (final cell in board) {
      if (cell == SimultaneousPlayer.none) {
        emptyCells++;
      }
    }
    return emptyCells == 1;
  }

  // Ottieni l'ultima cella disponibile
  int? _getLastAvailableCell() {
    for (int i = 0; i < board.length; i++) {
      if (board[i] == SimultaneousPlayer.none) {
        return i;
      }
    }
    return null;
  }

  // Trova la linea vincente
  List<int>? _findWinningLine(List<SimultaneousPlayer> board) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Righe
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonne
      [0, 4, 8], [2, 4, 6] // Diagonali
    ];

    for (final pattern in winPatterns) {
      final [a, b, c] = pattern;
      if (board[a] != SimultaneousPlayer.none &&
          board[a] == board[b] &&
          board[b] == board[c]) {
        return pattern;
      }
    }
    return null;
  }

  // Selezione mossa umana
  SimultaneousTicTacToeGame selectHumanMove(int index) {
    if (status != SimultaneousGameStatus.selectingMoves || 
        board[index] != SimultaneousPlayer.none) {
      return this;
    }

    // Se è l'ultima mossa disponibile, esegui automaticamente
    if (_isLastMoveAvailable()) {
      final newBoard = List<SimultaneousPlayer>.from(board);
      newBoard[index] = SimultaneousPlayer.human;
      
      final newStatus = _checkGameStatus(newBoard);
      final winningLine = _findWinningLine(newBoard);

      return copyWith(
        board: newBoard,
        status: newStatus,
        winningLine: winningLine,
        humanSelectedMove: index,
        isRevealingMoves: false,
      );
    }

    return copyWith(humanSelectedMove: index);
  }

  // Esecuzione turno simultaneo
  SimultaneousTicTacToeGame executeSimultaneousTurn() {
    if (status != SimultaneousGameStatus.selectingMoves || 
        humanSelectedMove == null) {
      return this;
    }

    // AI sceglie una mossa casuale tra quelle disponibili
    final availableMoves = <int>[];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == SimultaneousPlayer.none) {
        availableMoves.add(i);
      }
    }

    if (availableMoves.isEmpty) {
      return this;
    }

    final random = Random();
    final aiMove = availableMoves[random.nextInt(availableMoves.length)];

    return _executeMovesSimultaneously(aiMove);
  }

  // Esecuzione turno simultaneo con strategia specifica
  SimultaneousTicTacToeGame executeSimultaneousTurnWithStrategy(
    dynamic strategy, 
    List<int> playerMoveHistory
  ) {
    if (status != SimultaneousGameStatus.selectingMoves || 
        humanSelectedMove == null) {
      return this;
    }

    // Importa dinamicamente la strategia se necessario
    int aiMove;
    try {
      // Assumiamo che strategy sia un SimultaneousAIStrategy enum
      final strategyImpl = _createStrategyImplementation(strategy);
      aiMove = strategyImpl.selectMove(this, playerMoveHistory);
    } catch (e) {
      // Fallback alla strategia casuale
      final availableMoves = <int>[];
      for (int i = 0; i < board.length; i++) {
        if (board[i] == SimultaneousPlayer.none) {
          availableMoves.add(i);
        }
      }
      
      if (availableMoves.isEmpty) return this;
      
      final random = Random();
      aiMove = availableMoves[random.nextInt(availableMoves.length)];
    }

    return _executeMovesSimultaneously(aiMove);
  }

  // Metodo helper per eseguire le mosse simultaneamente
  SimultaneousTicTacToeGame _executeMovesSimultaneously(int aiMove) {
    final newBoard = List<SimultaneousPlayer>.from(board);
    
    // Se entrambi scelgono la stessa cella, nessuno la ottiene
    if (humanSelectedMove == aiMove) {
      // Conflitto! Nessuno ottiene la cella
    } else {
      // Applica entrambe le mosse
      newBoard[humanSelectedMove!] = SimultaneousPlayer.human;
      newBoard[aiMove] = SimultaneousPlayer.ai;
    }

    final newStatus = _checkGameStatus(newBoard);
    final winningLine = _findWinningLine(newBoard);

    return copyWith(
      board: newBoard,
      status: newStatus == SimultaneousGameStatus.selectingMoves ? SimultaneousGameStatus.revealing : newStatus,
      winningLine: winningLine,
      aiSelectedMove: aiMove,
      isRevealingMoves: true,
    );
  }

  // Factory dinamico per le strategie (importazione dinamica)
  dynamic _createStrategyImplementation(dynamic strategy) {
    // Questo sarà gestito dal provider che ha accesso alle import
    // Per ora ritorniamo null e gestiamo nel provider
    throw UnimplementedError('Strategy implementation should be handled by provider');
  }

  // Preparazione per il prossimo turno
  SimultaneousTicTacToeGame prepareNextTurn() {
    if (status == SimultaneousGameStatus.revealing) {
      return copyWith(
        status: SimultaneousGameStatus.selectingMoves,
        humanSelectedMove: null,
        aiSelectedMove: null,
        isRevealingMoves: false,
      );
    }
    return this;
  }

  // Verifica se il gioco è in uno stato finale
  bool get isGameFinished {
    return status == SimultaneousGameStatus.humanWon || 
           status == SimultaneousGameStatus.aiWon || 
           status == SimultaneousGameStatus.tie;
  }

  // Verifica se è possibile fare ancora mosse
  bool get canMakeMove {
    return status == SimultaneousGameStatus.selectingMoves && !isGameFinished;
  }

  // Reset del gioco
  SimultaneousTicTacToeGame reset() {
    return SimultaneousTicTacToeGame.initial();
  }

  // Helper per ottenere il simbolo da visualizzare
  String getSymbol(int index) {
    switch (board[index]) {
      case SimultaneousPlayer.human:
        return 'X';
      case SimultaneousPlayer.ai:
        return 'O';
      case SimultaneousPlayer.none:
        return '';
    }
  }

  // Helper per sapere se una cella è nella linea vincente
  bool isWinningCell(int index) {
    return winningLine?.contains(index) ?? false;
  }

  // Helper per sapere se una cella è stata selezionata dal giocatore
  bool isHumanSelected(int index) {
    return humanSelectedMove == index;
  }

  // Helper per sapere se una cella è stata selezionata dall'AI
  bool isAiSelected(int index) {
    return aiSelectedMove == index;
  }

  // Helper per sapere se c'è conflitto in una cella
  bool hasConflict(int index) {
    return humanSelectedMove == index && aiSelectedMove == index;
  }
}