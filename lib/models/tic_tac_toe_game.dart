import 'enums.dart';
import '../strategies/ai_strategy.dart';

enum Player { none, human, ai }
enum GameStatus { playing, humanWon, aiWon, tie }

class TicTacToeGame {
  final List<Player> board;
  final Player currentPlayer;
  final GameStatus status;
  final AIStrategy aiStrategy;

  const TicTacToeGame({
    required this.board,
    required this.currentPlayer,
    required this.status,
    this.aiStrategy = AIStrategy.classic_easy1,
  });

  factory TicTacToeGame.initial({AIStrategy aiStrategy = AIStrategy.classic_easy1}) {
    return TicTacToeGame(
      board: List.filled(9, Player.none),
      currentPlayer: Player.human,
      status: GameStatus.playing,
      aiStrategy: aiStrategy,
    );
  }

  TicTacToeGame copyWith({
    List<Player>? board,
    Player? currentPlayer,
    GameStatus? status,
    AIStrategy? aiStrategy,
  }) {
    return TicTacToeGame(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      status: status ?? this.status,
      aiStrategy: aiStrategy ?? this.aiStrategy,
    );
  }

  /// Controlla lo stato del gioco
  GameStatus _checkGameStatus(List<Player> newBoard) {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (final pattern in winPatterns) {
      final [a, b, c] = pattern;
      if (newBoard[a] != Player.none &&
          newBoard[a] == newBoard[b] &&
          newBoard[b] == newBoard[c]) {
        return newBoard[a] == Player.human ? GameStatus.humanWon : GameStatus.aiWon;
      }
    }

    if (newBoard.every((cell) => cell != Player.none)) {
      return GameStatus.tie;
    }

    return GameStatus.playing;
  }

  /// Mossa dell'umano
  TicTacToeGame makeHumanMove(int index) {
    if (status != GameStatus.playing || board[index] != Player.none || currentPlayer != Player.human) {
      return this;
    }

    final newBoard = List<Player>.from(board);
    newBoard[index] = Player.human;

    final newStatus = _checkGameStatus(newBoard);

    return copyWith(
      board: newBoard,
      currentPlayer: newStatus == GameStatus.playing ? Player.ai : currentPlayer,
      status: newStatus,
    );
  }

  /// Mossa dell'AI
  TicTacToeGame makeAIMove() {
    if (status != GameStatus.playing || currentPlayer != Player.ai) return this;

    final availableMoves = [for (int i = 0; i < 9; i++) if (board[i] == Player.none) i];
    if (availableMoves.isEmpty) return this;

    final strategy = AIStrategyFactory.createStrategy(aiStrategy);
    final aiMove = strategy.inferMove(this);

    final newBoard = List<Player>.from(board);
    newBoard[aiMove] = Player.ai;

    final newStatus = _checkGameStatus(newBoard);

    return copyWith(
      board: newBoard,
      currentPlayer: newStatus == GameStatus.playing ? Player.human : currentPlayer,
      status: newStatus,
    );
  }

  /// Reset del gioco
  TicTacToeGame reset({AIStrategy? aiStrategy}) {
    return TicTacToeGame.initial(aiStrategy: aiStrategy ?? this.aiStrategy);
  }

  /// Controlla se la cella fa parte di una combinazione vincente (non modifica lo stato)
  bool isWinningCell(int index) {
    if (status == GameStatus.playing || status == GameStatus.tie) return false;

    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (final pattern in winPatterns) {
      final [a, b, c] = pattern;
      if (board[a] != Player.none &&
          board[a] == board[b] &&
          board[b] == board[c] &&
          pattern.contains(index)) {
        return true;
      }
    }
    return false;
  }

  /// Helper per simboli da visualizzare
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

  /// Restituisce gli indici delle celle disponibili
  List<int> getAvailableCells() {
    final available = <int>[];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == Player.none) available.add(i);
    }
    return available;
  }
}
