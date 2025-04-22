import 'chess_piece.dart';

enum CastlingRights {
  whiteKingside,
  whiteQueenside,
  blackKingside,
  blackQueenside
}

enum GameState {
  ongoing,
  check,
  checkmate,
  stalemate,
  threefoldRepetition,
  fiftyMoveRule,
  insufficientMaterial
}

class ChessBoardState {
  List<ChessPiece> pieces;
  bool whiteToMove;
  Set<CastlingRights> castlingRights;
  Position? enPassantTarget;
  int halfMoveClock; // For fifty-move rule
  int fullMoveNumber;
  List<String> positionHistory; // For threefold repetition
  
  ChessBoardState({
    required this.pieces,
    required this.whiteToMove,
    required this.castlingRights,
    this.enPassantTarget,
    this.halfMoveClock = 0,
    this.fullMoveNumber = 1,
    List<String>? positionHistory,
  }) : positionHistory = positionHistory ?? [];
  
  ChessBoardState copyWith({
    List<ChessPiece>? pieces,
    bool? whiteToMove,
    Set<CastlingRights>? castlingRights,
    Position? enPassantTarget,
    int? halfMoveClock,
    int? fullMoveNumber,
    List<String>? positionHistory,
  }) {
    return ChessBoardState(
      pieces: pieces ?? List.from(this.pieces),
      whiteToMove: whiteToMove ?? this.whiteToMove, 
      castlingRights: castlingRights ?? Set.from(this.castlingRights),
      enPassantTarget: enPassantTarget,
      halfMoveClock: halfMoveClock ?? this.halfMoveClock,
      fullMoveNumber: fullMoveNumber ?? this.fullMoveNumber,
      positionHistory: positionHistory ?? List.from(this.positionHistory),
    );
  }
  
  ChessPiece? getPieceAt(Position position) {
    for (var piece in pieces) {
      if (piece.position.x == position.x && piece.position.y == position.y) {
        return piece;
      }
    }
    return null;
  }
  
  bool isSquareAttacked(Position position, bool byWhite) {
    for (var piece in pieces) {
      if (piece.isWhite == byWhite) {
        // Check if this piece attacks the square
        // This is a simplified version - would need more complex logic for a full implementation
        if (canPieceAttackSquare(piece, position)) {
          return true;
        }
      }
    }
    return false;
  }
  
  bool canPieceAttackSquare(ChessPiece piece, Position target) {
    // Simplified attack check - in a real implementation, this would be more sophisticated
    // and would check proper movement patterns
    switch (piece.type) {
      case PieceType.pawn:
        // Pawns attack diagonally
        final direction = piece.isWhite ? -1 : 1;
        return (piece.position.y + direction == target.y) && 
               (piece.position.x + 1 == target.x || piece.position.x - 1 == target.x);
      
      case PieceType.knight:
        // Knight's L-shaped move
        final dx = (piece.position.x - target.x).abs();
        final dy = (piece.position.y - target.y).abs();
        return (dx == 1 && dy == 2) || (dx == 2 && dy == 1);
      
      case PieceType.bishop:
        // Bishop moves diagonally
        final dx = (piece.position.x - target.x).abs();
        final dy = (piece.position.y - target.y).abs();
        if (dx != dy) return false;
        // Check if path is clear
        return isPathClear(piece.position, target);
      
      case PieceType.rook:
        // Rook moves horizontally or vertically
        if (piece.position.x != target.x && piece.position.y != target.y) return false;
        // Check if path is clear
        return isPathClear(piece.position, target);
      
      case PieceType.queen:
        // Queen combines rook and bishop moves
        final dx = (piece.position.x - target.x).abs();
        final dy = (piece.position.y - target.y).abs();
        if (piece.position.x != target.x && piece.position.y != target.y && dx != dy) return false;
        // Check if path is clear
        return isPathClear(piece.position, target);
      
      case PieceType.king:
        // King moves one square in any direction
        final dx = (piece.position.x - target.x).abs();
        final dy = (piece.position.y - target.y).abs();
        return dx <= 1 && dy <= 1;
    }
  }
  
  bool isPathClear(Position from, Position to) {
    // Simplified path checking - would be more complex in real implementation
    int dx = to.x - from.x;
    int dy = to.y - from.y;
    
    // Determine step direction
    int stepX = dx == 0 ? 0 : dx > 0 ? 1 : -1;
    int stepY = dy == 0 ? 0 : dy > 0 ? 1 : -1;
    
    int x = from.x + stepX;
    int y = from.y + stepY;
    
    // Check all squares in between (not including start and end)
    while (x != to.x || y != to.y) {
      if (getPieceAt(Position(x, y)) != null) {
        return false; // Path blocked
      }
      x += stepX;
      y += stepY;
    }
    
    return true; // Path clear
  }
  
  static ChessBoardState initial() {
    List<ChessPiece> pieces = [];
    
    // Add pawns
    for (int i = 0; i < 8; i++) {
      pieces.add(ChessPiece(
        type: PieceType.pawn,
        isWhite: true,
        position: Position(i, 6),
      ));
      
      pieces.add(ChessPiece(
        type: PieceType.pawn,
        isWhite: false,
        position: Position(i, 1),
      ));
    }
    
    // Add rooks
    pieces.add(ChessPiece(
      type: PieceType.rook,
      isWhite: true,
      position: const Position(0, 7),
    ));
    pieces.add(ChessPiece(
      type: PieceType.rook,
      isWhite: true,
      position: const Position(7, 7),
    ));
    pieces.add(ChessPiece(
      type: PieceType.rook,
      isWhite: false,
      position: const Position(0, 0),
    ));
    pieces.add(ChessPiece(
      type: PieceType.rook,
      isWhite: false,
      position: const Position(7, 0),
    ));
    
    // Add knights
    pieces.add(ChessPiece(
      type: PieceType.knight,
      isWhite: true,
      position: const Position(1, 7),
    ));
    pieces.add(ChessPiece(
      type: PieceType.knight,
      isWhite: true,
      position: const Position(6, 7),
    ));
    pieces.add(ChessPiece(
      type: PieceType.knight,
      isWhite: false,
      position: const Position(1, 0),
    ));
    pieces.add(ChessPiece(
      type: PieceType.knight,
      isWhite: false,
      position: const Position(6, 0),
    ));
    
    // Add bishops
    pieces.add(ChessPiece(
      type: PieceType.bishop,
      isWhite: true,
      position: const Position(2, 7),
    ));
    pieces.add(ChessPiece(
      type: PieceType.bishop,
      isWhite: true,
      position: const Position(5, 7),
    ));
    pieces.add(ChessPiece(
      type: PieceType.bishop,
      isWhite: false,
      position: const Position(2, 0),
    ));
    pieces.add(ChessPiece(
      type: PieceType.bishop,
      isWhite: false,
      position: const Position(5, 0),
    ));
    
    // Add queens
    pieces.add(ChessPiece(
      type: PieceType.queen,
      isWhite: true,
      position: const Position(3, 7),
    ));
    pieces.add(ChessPiece(
      type: PieceType.queen,
      isWhite: false,
      position: const Position(3, 0),
    ));
    
    // Add kings
    pieces.add(ChessPiece(
      type: PieceType.king,
      isWhite: true,
      position: const Position(4, 7),
    ));
    pieces.add(ChessPiece(
      type: PieceType.king,
      isWhite: false,
      position: const Position(4, 0),
    ));
    
    return ChessBoardState(
      pieces: pieces,
      whiteToMove: true,
      castlingRights: {
        CastlingRights.whiteKingside,
        CastlingRights.whiteQueenside,
        CastlingRights.blackKingside,
        CastlingRights.blackQueenside,
      },
    );
  }
}