import 'ai_difficulty.dart';
import '../strategies/ai_strategy.dart';

enum Player { none, human, ai }
enum GameStatus { playing, humanWon, aiWon, tie }

class TicTacToeGame {
  final List<Player> board;
  final Player currentPlayer;
  final GameStatus status;
  final List<int>? winningLine;
  final AIStrategy aiStrategy;

  const TicTacToeGame({
    required this.board,
    required this.currentPlayer,
    required this.status,
    this.winningLine,
    this.aiStrategy = AIStrategy.medium1,
  });

  factory TicTacToeGame.initial({AIStrategy aiStrategy = AIStrategy.medium1}) {
    return TicTacToeGame(
      board: List.filled(9, Player.none),
      currentPlayer: Player.human,
      status: GameStatus.playing,
      winningLine: null,
      aiStrategy: aiStrategy,
    );
  }

  TicTacToeGame copyWith({
    List<Player>? board,
    Player? currentPlayer,
    GameStatus? status,
    List<int>? winningLine,
    AIStrategy? aiStrategy,
  }) {
    return TicTacToeGame(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      status: status ?? this.status,
      winningLine: winningLine ?? this.winningLine,
      aiStrategy: aiStrategy ?? this.aiStrategy,
    );
  }

  // Controlla se c'è un vincitore
  GameStatus _checkGameStatus(List<Player> newBoard) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Righe
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonne
      [0, 4, 8], [2, 4, 6] // Diagonali
    ];

    for (final pattern in winPatterns) {
      final [a, b, c] = pattern;
      if (newBoard[a] != Player.none &&
          newBoard[a] == newBoard[b] &&
          newBoard[b] == newBoard[c]) {
        return newBoard[a] == Player.human ? GameStatus.humanWon : GameStatus.aiWon;
      }
    }

    // Controlla pareggio
    if (newBoard.every((cell) => cell != Player.none)) {
      return GameStatus.tie;
    }

    return GameStatus.playing;
  }

  // Trova la linea vincente
  List<int>? _findWinningLine(List<Player> board) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Righe
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Colonne
      [0, 4, 8], [2, 4, 6] // Diagonali
    ];

    for (final pattern in winPatterns) {
      final [a, b, c] = pattern;
      if (board[a] != Player.none &&
          board[a] == board[b] &&
          board[b] == board[c]) {
        return pattern;
      }
    }
    return null;
  }

  // Mossa del giocatore umano
  TicTacToeGame makeHumanMove(int index) {
    if (status != GameStatus.playing || 
        board[index] != Player.none || 
        currentPlayer != Player.human) {
      return this;
    }

    final newBoard = List<Player>.from(board);
    newBoard[index] = Player.human;
    
    final newStatus = _checkGameStatus(newBoard);
    final winningLine = _findWinningLine(newBoard);

    return copyWith(
      board: newBoard,
      currentPlayer: newStatus == GameStatus.playing ? Player.ai : currentPlayer,
      status: newStatus,
      winningLine: winningLine,
    );
  }

  // Mossa dell'AI usando la strategia scelta
  TicTacToeGame makeAIMove() {
    if (status != GameStatus.playing || currentPlayer != Player.ai) {
      return this;
    }

    final availableMoves = <int>[];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == Player.none) {
        availableMoves.add(i);
      }
    }

    if (availableMoves.isEmpty) {
      return this;
    }

    // Usa la strategia AI specifica
    final strategy = AIStrategyFactory.createStrategy(aiStrategy);
    final aiMove = strategy.findBestMove(this);

    final newBoard = List<Player>.from(board);
    newBoard[aiMove] = Player.ai;

    final newStatus = _checkGameStatus(newBoard);
    final winningLine = _findWinningLine(newBoard);

    return copyWith(
      board: newBoard,
      currentPlayer: newStatus == GameStatus.playing ? Player.human : currentPlayer,
      status: newStatus,
      winningLine: winningLine,
    );
  }

  // Reset del gioco
  TicTacToeGame reset({AIStrategy? aiStrategy}) {
    return TicTacToeGame.initial(aiStrategy: aiStrategy ?? this.aiStrategy);
  }

  // Helper per ottenere il simbolo da visualizzare
  String getSymbol(int index) {
    switch (board[index]) {
      case Player.human:
        return 'X';
      case Player.ai:
        return 'O';
      case Player.none:
        return '';
    }
  }

  // Helper per sapere se una cella è nella linea vincente
  bool isWinningCell(int index) {
    return winningLine?.contains(index) ?? false;
  }
}