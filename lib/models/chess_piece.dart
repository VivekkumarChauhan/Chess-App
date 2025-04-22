
class Position {
  final int x;
  final int y;
  
  const Position(this.x, this.y);
  
  String toAlgebraic() {
    return '${String.fromCharCode('a'.codeUnitAt(0) + x)}${8 - y}';
  }
  
  @override
  bool operator ==(Object other) {
    return other is Position && other.x == x && other.y == y;
  }
  
  @override
  int get hashCode => Object.hash(x, y);
  
  @override
  String toString() => 'Position($x, $y)';
}

enum PieceType {
  pawn,
  knight,
  bishop,
  rook,
  queen,
  king
}

class ChessPiece {
  final PieceType type;
  final bool isWhite;
  Position position;
  bool hasMoved;
  
  ChessPiece({
    required this.type,
    required this.isWhite,
    required this.position,
    this.hasMoved = false,
  });
  
  ChessPiece copyWith({
    PieceType? type,
    bool? isWhite,
    Position? position,
    bool? hasMoved,
  }) {
    return ChessPiece(
      type: type ?? this.type,
      isWhite: isWhite ?? this.isWhite,
      position: position ?? this.position,
      hasMoved: hasMoved ?? this.hasMoved,
    );
  }

  String get symbol {
    switch (type) {
      case PieceType.pawn:
        return isWhite ? '♙' : '♟';
      case PieceType.knight:
        return isWhite ? '♘' : '♞';
      case PieceType.bishop:
        return isWhite ? '♗' : '♝';
      case PieceType.rook:
        return isWhite ? '♖' : '♜';
      case PieceType.queen:
        return isWhite ? '♕' : '♛';
      case PieceType.king:
        return isWhite ? '♔' : '♚';
    }
  }
  
  int get value {
    switch (type) {
      case PieceType.pawn:
        return 1;
      case PieceType.knight:
      case PieceType.bishop:
        return 3;
      case PieceType.rook:
        return 5;
      case PieceType.queen:
        return 9;
      case PieceType.king:
        return 0; // King's value is infinite in practice
    }
  }
}

class Move {
  final Position from;
  final Position to;
  final PieceType? promotion;
  
  const Move(this.from, this.to, {this.promotion});
  
  @override
  String toString() {
    String moveStr = '${from.toAlgebraic()}-${to.toAlgebraic()}';
    if (promotion != null) {
      moveStr += '=${promotion.toString().split('.').last[0].toUpperCase()}';
    }
    return moveStr;
  }
}