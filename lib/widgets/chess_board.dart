import 'package:flutter/material.dart';
import '../models/chess_board_state.dart';
import '../models/chess_piece.dart';

class ChessBoard extends StatelessWidget {
  final ChessBoardState boardState;
  final ChessPiece? selectedPiece;
  final List<Position> legalMoves;
  final Position? lastMoveFrom;
  final Position? lastMoveTo;
  final bool flipped;
  final Function(Position) onSquareTapped;
  
  const ChessBoard({
    super.key,
    required this.boardState,
    required this.selectedPiece,
    required this.legalMoves,
    required this.lastMoveFrom,
    required this.lastMoveTo,
    required this.flipped,
    required this.onSquareTapped,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 64,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemBuilder: (context, index) {
          // Convert index to chess coordinates (0,0 to 7,7)
          final x = flipped ? 7 - (index % 8) : index % 8;
          final y = flipped ? (index ~/ 8) : 7 - (index ~/ 8);
          final position = Position(x, y);
          
          // Determine square color
          final isLightSquare = (x + y) % 2 == 0;
          final squareColor = isLightSquare 
              ? const Color(0xFFF0D9B5) // Light square color
              : const Color(0xFFB58863); // Dark square color
              
          // Get piece at this position
          final piece = boardState.getPieceAt(position);
          
          // Check if this square is highlighted
          final isSelected = selectedPiece != null && 
              selectedPiece!.position.x == x && 
              selectedPiece!.position.y == y;
              
          final isLegalMove = legalMoves.any(
            (pos) => pos.x == x && pos.y == y
          );
          
          final isLastMoveFrom = lastMoveFrom != null &&
              lastMoveFrom!.x == x && lastMoveFrom!.y == y;
              
          final isLastMoveTo = lastMoveTo != null &&
              lastMoveTo!.x == x && lastMoveTo!.y == y;
              
          Color? overlayColor;
          if (isSelected) {
            overlayColor = Colors.blue.withOpacity(0.5);
          } else if (isLastMoveFrom || isLastMoveTo) {
            overlayColor = Colors.yellow.withOpacity(0.5);
          }
          
          return GestureDetector(
            onTap: () => onSquareTapped(position),
            child: Stack(
              children: [
                // Square background
                Container(
                  color: squareColor,
                ),
                
                // Highlight overlay
                if (overlayColor != null)
                  Container(
                    color: overlayColor,
                  ),
                
                // Legal move indicator
                if (isLegalMove)
                  Center(
                    child: Container(
                      width: piece != null ? 40 : 16,
                      height: piece != null ? 40 : 16,
                      decoration: BoxDecoration(
                        color: piece != null 
                            ? Colors.red.withOpacity(0.5)
                            : Colors.green.withOpacity(0.7),
                        shape: piece != null 
                            ? BoxShape.rectangle
                            : BoxShape.circle,
                      ),
                    ),
                  ),
                
                // Chess piece
                if (piece != null)
                  Center(
                    child: _buildPieceWidget(piece),
                  ),
                  
                // Coordinate labels (optional)
                if (y == 0 && !flipped || y == 7 && flipped)
                  Positioned(
                    right: 2,
                    bottom: 1,
                    child: Text(
                      String.fromCharCode('a'.codeUnitAt(0) + x),
                      style: TextStyle(
                        fontSize: 8,
                        color: isLightSquare ? Colors.grey.shade700 : Colors.grey.shade300,
                      ),
                    ),
                  ),
                if (x == 0 && !flipped || x == 7 && flipped)
                  Positioned(
                    left: 2,
                    top: 1,
                    child: Text(
                      '${8 - y}',
                      style: TextStyle(
                        fontSize: 8,
                        color: isLightSquare ? Colors.grey.shade700 : Colors.grey.shade300,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildPieceWidget(ChessPiece piece) {
    // Use Unicode chess symbols instead of non-existent Icons
    String symbol;
    
    switch (piece.type) {
      case PieceType.pawn:
        symbol = piece.isWhite ? '♙' : '♟';
        break;
      case PieceType.knight:
        symbol = piece.isWhite ? '♘' : '♞';
        break;
      case PieceType.bishop:
        symbol = piece.isWhite ? '♗' : '♝';
        break;
      case PieceType.rook:  // Added missing case
        symbol = piece.isWhite ? '♖' : '♜';
        break;
      case PieceType.queen:
        symbol = piece.isWhite ? '♕' : '♛';
        break;
      case PieceType.king:
        symbol = piece.isWhite ? '♔' : '♚';
        break;
    }
    
    return Text(
      symbol,
      style: TextStyle(
        fontSize: 36,
        color: piece.isWhite ? Colors.white : Colors.black,
        shadows: [
          Shadow(
            blurRadius: 3,
            color: piece.isWhite ? Colors.black54 : Colors.white54,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
  }
}