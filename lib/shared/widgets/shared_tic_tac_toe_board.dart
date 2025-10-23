/// Shared tic tac toe board widget
/// Reusable grid component for all game modes

import 'package:flutter/material.dart';
import '../../core/constants/game_constants.dart';
import '../../core/utils/game_logic.dart';

/// Represents the state of a cell in the tic tac toe board
enum CellState { empty, x, o, hidden, bet }

/// Cell decoration options
class CellDecoration {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final double borderWidth;
  final bool isHighlighted;
  final bool isWinning;
  final Widget? overlay;

  const CellDecoration({
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.grey,
    this.textColor = Colors.black,
    this.borderWidth = 2.0,
    this.isHighlighted = false,
    this.isWinning = false,
    this.overlay,
  });

  CellDecoration copyWith({
    Color? backgroundColor,
    Color? borderColor,
    Color? textColor,
    double? borderWidth,
    bool? isHighlighted,
    bool? isWinning,
    Widget? overlay,
  }) {
    return CellDecoration(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      textColor: textColor ?? this.textColor,
      borderWidth: borderWidth ?? this.borderWidth,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isWinning: isWinning ?? this.isWinning,
      overlay: overlay ?? this.overlay,
    );
  }
}

/// Shared tic tac toe board widget
class SharedTicTacToeBoard extends StatelessWidget {
  /// Board state (9 elements representing the 3x3 grid)
  final List<CellState> board;
  
  /// Winning line indices (if game is won)
  final List<int>? winningLine;
  
  /// Callback when a cell is tapped
  final void Function(int index)? onCellTap;
  
  /// Custom cell decorations (optional, uses defaults if null)
  final List<CellDecoration>? cellDecorations;
  
  /// Overall board theme color
  final Color themeColor;
  
  /// Whether the board is interactive
  final bool isInteractive;
  
  /// Animation duration for cell changes
  final Duration animationDuration;

  const SharedTicTacToeBoard({
    super.key,
    required this.board,
    this.winningLine,
    this.onCellTap,
    this.cellDecorations,
    this.themeColor = Colors.blue,
    this.isInteractive = true,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : assert(board.length == 9, 'Board must have exactly 9 cells');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GridConstants.gridPadding),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: GridConstants.gridSize,
            childAspectRatio: GridConstants.cellAspectRatio,
            crossAxisSpacing: GridConstants.cellSpacing,
            mainAxisSpacing: GridConstants.cellSpacing,
          ),
          itemCount: GridConstants.totalCells,
          itemBuilder: (context, index) {
            return _buildCell(context, index);
          },
        ),
      ),
    );
  }

  Widget _buildCell(BuildContext context, int index) {
    final cellState = board[index];
    final isWinningCell = winningLine?.contains(index) ?? false;
    final decoration = cellDecorations?[index] ?? _getDefaultDecoration(cellState, isWinningCell);
    
    return AnimatedContainer(
      duration: animationDuration,
      decoration: BoxDecoration(
        color: decoration.backgroundColor,
        border: Border.all(
          color: decoration.borderColor,
          width: decoration.borderWidth,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: decoration.isHighlighted ? [
          BoxShadow(
            color: themeColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isInteractive && onCellTap != null ? () => onCellTap!(index) : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            child: Stack(
              children: [
                Center(child: _buildCellContent(cellState, decoration)),
                if (decoration.overlay != null) decoration.overlay!,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCellContent(CellState cellState, CellDecoration decoration) {
    switch (cellState) {
      case CellState.empty:
        return const SizedBox.shrink();
        
      case CellState.x:
        return Icon(
          Icons.close,
          size: 48,
          color: decoration.textColor,
          weight: 800,
        );
        
      case CellState.o:
        return Icon(
          Icons.circle_outlined,
          size: 42,
          color: decoration.textColor,
        );
        
      case CellState.hidden:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.help_outline,
            color: Colors.grey.shade600,
            size: 24,
          ),
        );
        
      case CellState.bet:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.star,
            color: Colors.white,
            size: 20,
          ),
        );
    }
  }

  CellDecoration _getDefaultDecoration(CellState cellState, bool isWinningCell) {
    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    Color textColor = Colors.black87;
    
    if (isWinningCell) {
      backgroundColor = themeColor.withOpacity(0.1);
      borderColor = themeColor;
    }
    
    switch (cellState) {
      case CellState.x:
        textColor = Colors.red.shade700;
        break;
      case CellState.o:
        textColor = Colors.blue.shade700;
        break;
      case CellState.bet:
        backgroundColor = Colors.amber.withOpacity(0.1);
        borderColor = Colors.amber;
        break;
      case CellState.hidden:
        backgroundColor = Colors.grey.shade100;
        borderColor = Colors.grey.shade400;
        break;
      case CellState.empty:
        break;
    }
    
    return CellDecoration(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      textColor: textColor,
      isWinning: isWinningCell,
    );
  }
}