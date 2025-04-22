import 'dart:math';
//import 'package:chess_app/models/game_mode.dart' as game_mode;
import 'package:chess_app/models/difficulty.dart' as difficulty_model;

import '../models/chess_piece.dart';
import '../models/chess_board_state.dart';

class ChessEngine {
  
  final difficulty_model.Difficulty difficulty;
  final Random _random = Random();
  
  ChessEngine({required this.difficulty});
  
  List<Position> getLegalMoves(ChessBoardState boardState, Position position) {
    final piece = boardState.getPieceAt(position);
    if (piece == null) return [];
    
    List<Position> candidateMoves = [];
    
    switch (piece.type) {
      case PieceType.pawn:
        _addPawnMoves(boardState, piece, candidateMoves);
        break;
      case PieceType.knight:
        _addKnightMoves(boardState, piece, candidateMoves);
        break;
      case PieceType.bishop:
        _addBishopMoves(boardState, piece, candidateMoves);
        break;
      case PieceType.rook:
        _addRookMoves(boardState, piece, candidateMoves);
        break;
      case PieceType.queen:
        _addQueenMoves(boardState, piece, candidateMoves);
        break;
      case PieceType.king:
        _addKingMoves(boardState, piece, candidateMoves);
        break;
    }
    
    // Filter out moves that would leave the king in check
    List<Position> legalMoves = [];
    for (var move in candidateMoves) {
      if (_isLegalMove(boardState, piece.position, move)) {
        legalMoves.add(move);
      }
    }
    
    return legalMoves;
  }
  
  void _addPawnMoves(ChessBoardState boardState, ChessPiece pawn, List<Position> moves) {
    final direction = pawn.isWhite ? -1 : 1;
    final startRank = pawn.isWhite ? 6 : 1;
    
    // Forward one square
    final forwardOne = Position(pawn.position.x, pawn.position.y + direction);
    if (_isInBounds(forwardOne) && boardState.getPieceAt(forwardOne) == null) {
      moves.add(forwardOne);
      
      // Forward two squares from starting position
      if (pawn.position.y == startRank) {
        final forwardTwo = Position(pawn.position.x, pawn.position.y + 2 * direction);
        if (boardState.getPieceAt(forwardTwo) == null) {
          moves.add(forwardTwo);
        }
      }
    }
    
    // Diagonal captures
    final diagLeft = Position(pawn.position.x - 1, pawn.position.y + direction);
    final diagRight = Position(pawn.position.x + 1, pawn.position.y + direction);
    
    if (_isInBounds(diagLeft)) {
      final pieceAtDiagLeft = boardState.getPieceAt(diagLeft);
      if (pieceAtDiagLeft != null && pieceAtDiagLeft.isWhite != pawn.isWhite) {
        moves.add(diagLeft);
      }
      // En passant capture
      if (boardState.enPassantTarget != null && 
          diagLeft.x == boardState.enPassantTarget!.x && 
          diagLeft.y == boardState.enPassantTarget!.y) {
        moves.add(diagLeft);
      }
    }
    
    if (_isInBounds(diagRight)) {
      final pieceAtDiagRight = boardState.getPieceAt(diagRight);
      if (pieceAtDiagRight != null && pieceAtDiagRight.isWhite != pawn.isWhite) {
        moves.add(diagRight);
      }
      // En passant capture
      if (boardState.enPassantTarget != null && 
          diagRight.x == boardState.enPassantTarget!.x && 
          diagRight.y == boardState.enPassantTarget!.y) {
        moves.add(diagRight);
      }
    }
  }
  
  void _addKnightMoves(ChessBoardState boardState, ChessPiece knight, List<Position> moves) {
    final knightMoves = [
      Position(knight.position.x + 1, knight.position.y + 2),
      Position(knight.position.x + 2, knight.position.y + 1),
      Position(knight.position.x + 2, knight.position.y - 1),
      Position(knight.position.x + 1, knight.position.y - 2),
      Position(knight.position.x - 1, knight.position.y - 2),
      Position(knight.position.x - 2, knight.position.y - 1),
      Position(knight.position.x - 2, knight.position.y + 1),
      Position(knight.position.x - 1, knight.position.y + 2),
    ];
    
    for (var move in knightMoves) {
      if (_isInBounds(move)) {
        final pieceAtTarget = boardState.getPieceAt(move);
        if (pieceAtTarget == null || pieceAtTarget.isWhite != knight.isWhite) {
          moves.add(move);
        }
      }
    }
  }
  
  void _addBishopMoves(ChessBoardState boardState, ChessPiece bishop, List<Position> moves) {
    final directions = [
      [1, 1],   // Up-right
      [1, -1],  // Down-right
      [-1, -1], // Down-left
      [-1, 1],  // Up-left
    ];
    
    for (var dir in directions) {
      _addSlidingMoves(boardState, bishop, moves, dir[0], dir[1]);
    }
  }
  
  void _addRookMoves(ChessBoardState boardState, ChessPiece rook, List<Position> moves) {
    final directions = [
      [0, 1],   // Up
      [1, 0],   // Right
      [0, -1],  // Down
      [-1, 0],  // Left
    ];
    
    for (var dir in directions) {
      _addSlidingMoves(boardState, rook, moves, dir[0], dir[1]);
    }
  }
  
  void _addQueenMoves(ChessBoardState boardState, ChessPiece queen, List<Position> moves) {
    _addBishopMoves(boardState, queen, moves);
    _addRookMoves(boardState, queen, moves);
  }
  
  void _addKingMoves(ChessBoardState boardState, ChessPiece king, List<Position> moves) {
    final directions = [
      [0, 1],    // Up
      [1, 1],    // Up-right
      [1, 0],    // Right
      [1, -1],   // Down-right
      [0, -1],   // Down
      [-1, -1],  // Down-left
      [-1, 0],   // Left
      [-1, 1],   // Up-left
    ];
    
    for (var dir in directions) {
      final targetX = king.position.x + dir[0];
      final targetY = king.position.y + dir[1];
      final target = Position(targetX, targetY);
      
      if (_isInBounds(target)) {
        final pieceAtTarget = boardState.getPieceAt(target);
        if (pieceAtTarget == null || pieceAtTarget.isWhite != king.isWhite) {
          // Also check if the square is not under attack
          if (!boardState.isSquareAttacked(target, !king.isWhite)) {
            moves.add(target);
          }
        }
      }
    }
    
    // Castling
    _addCastlingMoves(boardState, king, moves);
  }
  
  void _addCastlingMoves(ChessBoardState boardState, ChessPiece king, List<Position> moves) {
    if (king.hasMoved) return;
    if (_isInCheck(boardState, king.isWhite)) return;
    
    final y = king.position.y;
    final isWhite = king.isWhite;
    
    // Kingside castling
    if ((isWhite && boardState.castlingRights.contains(CastlingRights.whiteKingside)) ||
        (!isWhite && boardState.castlingRights.contains(CastlingRights.blackKingside))) {
      
      if (boardState.getPieceAt(Position(5, y)) == null &&
          boardState.getPieceAt(Position(6, y)) == null &&
          !boardState.isSquareAttacked(Position(5, y), !isWhite) &&
          !boardState.isSquareAttacked(Position(6, y), !isWhite)) {
        
        final rook = boardState.getPieceAt(Position(7, y));
        if (rook != null && rook.type == PieceType.rook && !rook.hasMoved) {
          moves.add(Position(6, y)); // King's target square for kingside castling
        }
      }
    }
    
    // Queenside castling
    if ((isWhite && boardState.castlingRights.contains(CastlingRights.whiteQueenside)) ||
        (!isWhite && boardState.castlingRights.contains(CastlingRights.blackQueenside))) {
      
      if (boardState.getPieceAt(Position(3, y)) == null &&
          boardState.getPieceAt(Position(2, y)) == null &&
          boardState.getPieceAt(Position(1, y)) == null &&
          !boardState.isSquareAttacked(Position(3, y), !isWhite) &&
          !boardState.isSquareAttacked(Position(2, y), !isWhite)) {
        
        final rook = boardState.getPieceAt(Position(0, y));
        if (rook != null && rook.type == PieceType.rook && !rook.hasMoved) {
          moves.add(Position(2, y)); // King's target square for queenside castling
        }
      }
    }
  }
  
  void _addSlidingMoves(
    ChessBoardState boardState, 
    ChessPiece piece, 
    List<Position> moves, 
    int dirX, 
    int dirY
  ) {
    int x = piece.position.x + dirX;
    int y = piece.position.y + dirY;
    
    while (_isInBounds(Position(x, y))) {
      final pieceAtTarget = boardState.getPieceAt(Position(x, y));
      
      if (pieceAtTarget == null) {
        // Square is empty, add move and continue sliding
        moves.add(Position(x, y));
      } else {
        // Square is occupied
        if (pieceAtTarget.isWhite != piece.isWhite) {
          // Can capture opponent's piece
          moves.add(Position(x, y));
        }
        // Stop sliding in this direction
        break;
      }
      
      x += dirX;
      y += dirY;
    }
  }
  
  bool _isInBounds(Position position) {
    return position.x >= 0 && position.x < 8 && position.y >= 0 && position.y < 8;
  }
  
  bool _isLegalMove(ChessBoardState boardState, Position from, Position to) {
    // Check if move would leave or put the king in check
    final piece = boardState.getPieceAt(from);
    if (piece == null) return false;
    
    // Make the move on a temporary board
    final tempBoard = _simulateMove(boardState, from, to);
    
    // Check if the king of the moving side is in check after the move
    return !_isInCheck(tempBoard, piece.isWhite);
  }
  
  ChessBoardState _simulateMove(ChessBoardState boardState, Position from, Position to) {
    // Create a deep copy of the board state
    List<ChessPiece> newPieces = [];
    for (var piece in boardState.pieces) {
      newPieces.add(piece.copyWith());
    }
    
    // Find the piece being moved
    int? pieceIndex;
    for (int i = 0; i < newPieces.length; i++) {
      if (newPieces[i].position.x == from.x && newPieces[i].position.y == from.y) {
        pieceIndex = i;
        break;
      }
    }
    
    if (pieceIndex == null) return boardState;
    
    // Remove captured piece if any
    newPieces.removeWhere((p) => p.position.x == to.x && p.position.y == to.y);
    
    // Move the piece
    newPieces[pieceIndex] = newPieces[pieceIndex].copyWith(
      position: to,
      hasMoved: true,
    );
    
    // Return the new board state
    return ChessBoardState(
      pieces: newPieces,
      whiteToMove: !boardState.whiteToMove,
      castlingRights: Set.from(boardState.castlingRights),
    );
  }
  
  bool _isInCheck(ChessBoardState boardState, bool isWhiteKing) {
    // Find the king
    ChessPiece? king;
    for (var piece in boardState.pieces) {
      if (piece.type == PieceType.king && piece.isWhite == isWhiteKing) {
        king = piece;
        break;
      }
    }
    
    if (king == null) return false; // Should never happen in a valid game
    
    // Check if any opponent's piece attacks the king
    return boardState.isSquareAttacked(king.position, !isWhiteKing);
  }
  
  ChessBoardState makeMove(ChessBoardState boardState, Position from, Position to) {
    final piece = boardState.getPieceAt(from);
    if (piece == null) return boardState;
    
    // Create new list of pieces
    List<ChessPiece> newPieces = [];
    for (var p in boardState.pieces) {
      // Skip the moving piece and captured piece, we'll add the updated piece later
      if (p.position.x == from.x && p.position.y == from.y ||
          p.position.x == to.x && p.position.y == to.y) {
        continue;
      }
      
      // Handle en passant capture
      if (piece.type == PieceType.pawn && 
          boardState.enPassantTarget != null &&
          to.x == boardState.enPassantTarget!.x && 
          to.y == boardState.enPassantTarget!.y) {
        // Skip the pawn being captured by en passant
        if (p.position.x == to.x && p.position.y == from.y) {
          continue;
        }
      }
      
      newPieces.add(p.copyWith());
    }
    
    // Add moved piece with updated position
    final newPiece = piece.copyWith(
      position: to,
      hasMoved: true,
    );
    newPieces.add(newPiece);
    
    // Handle special moves
    Position? newEnPassantTarget;
    Set<CastlingRights> newCastlingRights = Set.from(boardState.castlingRights);
    
    // Update castling rights if a king or rook moves
    if (piece.type == PieceType.king) {
      if (piece.isWhite) {
        newCastlingRights.remove(CastlingRights.whiteKingside);
        newCastlingRights.remove(CastlingRights.whiteQueenside);
      } else {
        newCastlingRights.remove(CastlingRights.blackKingside);
        newCastlingRights.remove(CastlingRights.blackQueenside);
      }
      
      // Handle castling
      if ((from.x - to.x).abs() == 2) {
        // Kingside or queenside castling
        final rookFromX = to.x > from.x ? 7 : 0;
        final rookToX = to.x > from.x ? 5 : 3;
        
        // Find the rook
        ChessPiece? rook;
        int? rookIndex;
        for (int i = 0; i < newPieces.length; i++) {
          if (newPieces[i].position.x == rookFromX && 
              newPieces[i].position.y == from.y &&
              newPieces[i].type == PieceType.rook) {
            rook = newPieces[i];
            rookIndex = i;
            break;
          }
        }
        
        if (rook != null && rookIndex != null) {
          // Move the rook
          newPieces[rookIndex] = rook.copyWith(
            position: Position(rookToX, from.y),
            hasMoved: true,
          );
        }
      }
    } else if (piece.type == PieceType.rook) {
      // Remove castling rights for the rook that moved
      if (from.x == 0 && from.y == 7) {
        newCastlingRights.remove(CastlingRights.whiteQueenside);
      } else if (from.x == 7 && from.y == 7) {
        newCastlingRights.remove(CastlingRights.whiteKingside);
      } else if (from.x == 0 && from.y == 0) {
        newCastlingRights.remove(CastlingRights.blackQueenside);
      } else if (from.x == 7 && from.y == 0) {
        newCastlingRights.remove(CastlingRights.blackKingside);
      }
    } else if (piece.type == PieceType.pawn) {
      // Set en passant target if pawn moves two squares
      if ((from.y - to.y).abs() == 2) {
        newEnPassantTarget = Position(from.x, (from.y + to.y) ~/ 2);
      }
      
      // Handle pawn promotion
      if (to.y == 0 || to.y == 7) {
        // Promote to queen by default
        // In a real implementation, you'd want to show UI to let the player choose
        newPieces.removeLast(); // Remove the pawn we just added
        newPieces.add(ChessPiece(
          type: PieceType.queen,
          isWhite: piece.isWhite,
          position: to,
          hasMoved: true,
        ));
      }
    }
    
    // Update halfmove clock
    int newHalfMoveClock = boardState.halfMoveClock + 1;
    if (piece.type == PieceType.pawn || boardState.getPieceAt(to) != null) {
      newHalfMoveClock = 0; // Reset on pawn move or capture
    }
    
    // Update fullmove number
    int newFullMoveNumber = boardState.fullMoveNumber;
    if (!boardState.whiteToMove) {
      newFullMoveNumber++; // Increment after black's move
    }
    
    // Generate position key for repetition detection
    String positionKey = _generatePositionKey(newPieces, !boardState.whiteToMove);
    List<String> newPositionHistory = List.from(boardState.positionHistory);
    newPositionHistory.add(positionKey);
    
    return ChessBoardState(
      pieces: newPieces,
      whiteToMove: !boardState.whiteToMove,
      castlingRights: newCastlingRights,
      enPassantTarget: newEnPassantTarget,
      halfMoveClock: newHalfMoveClock,
      fullMoveNumber: newFullMoveNumber,
      positionHistory: newPositionHistory,
    );
  }
  
  String _generatePositionKey(List<ChessPiece> pieces, bool whiteToMove) {
    // Simple implementation - in a real chess engine this would be more sophisticated
    List<String> parts = [];
    
    // Sort pieces for consistent representation
    pieces.sort((a, b) {
      if (a.isWhite != b.isWhite) return a.isWhite ? 1 : -1;
      if (a.type.index != b.type.index) return a.type.index - b.type.index;
      if (a.position.y != b.position.y) return a.position.y - b.position.y;
      return a.position.x - b.position.x;
    });
    
    // Add piece positions
    for (var piece in pieces) {
      parts.add('${piece.isWhite ? 'W' : 'B'}${piece.type.index}${piece.position.x}${piece.position.y}');
    }
    
    // Add side to move
    parts.add(whiteToMove ? 'w' : 'b');
    
    return parts.join('-');
  }
  
  GameState checkGameState(ChessBoardState boardState, bool sideToMove) {
    // Check for checkmate or stalemate
    bool hasLegalMoves = false;
    bool isInCheck = _isInCheck(boardState, sideToMove);
    
    // Check if the side to move has any legal moves
    for (var piece in boardState.pieces) {
      if (piece.isWhite == sideToMove) {
        List<Position> legalMoves = getLegalMoves(boardState, piece.position);
        if (legalMoves.isNotEmpty) {
          hasLegalMoves = true;
          break;
        }
      }
    }
    
    if (!hasLegalMoves) {
      return isInCheck ? GameState.checkmate : GameState.stalemate;
    }
    
    // Check for threefold repetition
    Map<String, int> positionCount = {};
    for (var posKey in boardState.positionHistory) {
      positionCount[posKey] = (positionCount[posKey] ?? 0) + 1;
      if (positionCount[posKey]! >= 3) {
        return GameState.threefoldRepetition;
      }
    }
    
    // Check for fifty-move rule
    if (boardState.halfMoveClock >= 100) { // 50 full moves = 100 half moves
      return GameState.fiftyMoveRule;
    }
    
    // Check for insufficient material
    if (_hasInsufficientMaterial(boardState)) {
      return GameState.insufficientMaterial;
    }
    
    return isInCheck ? GameState.check : GameState.ongoing;
  }
  
  bool _hasInsufficientMaterial(ChessBoardState boardState) {
    // Count pieces
    int whiteBishops = 0, whiteKnights = 0, blackBishops = 0, blackKnights = 0;
    List<ChessPiece> otherPieces = [];
    
    for (var piece in boardState.pieces) {
      switch (piece.type) {
        case PieceType.king:
          // Kings are always present
          break;
        case PieceType.bishop:
          if (piece.isWhite) {
            whiteBishops++;
          } else {
            blackBishops++;
          }
          break;
        case PieceType.knight:
          if (piece.isWhite) {
            whiteKnights++;
          } else {
            blackKnights++;
          }
          break;
        default:
          otherPieces.add(piece);
          break;
      }
    }
    
    // If there are any pawns, rooks, or queens, sufficient material exists
    if (otherPieces.isNotEmpty) return false;
    
    // King vs King
    if (whiteBishops == 0 && whiteKnights == 0 && blackBishops == 0 && blackKnights == 0) {
      return true;
    }
    
    // King + Bishop vs King or King + Knight vs King
    if ((whiteBishops == 1 && whiteKnights == 0 && blackBishops == 0 && blackKnights == 0) ||
        (whiteBishops == 0 && whiteKnights == 1 && blackBishops == 0 && blackKnights == 0) ||
        (whiteBishops == 0 && whiteKnights == 0 && blackBishops == 1 && blackKnights == 0) ||
        (whiteBishops == 0 && whiteKnights == 0 && blackBishops == 0 && blackKnights == 1)) {
      return true;
    }
    
    // Other cases could be implemented (e.g., K+B vs K+B with same colored bishops)
    
    return false;
  }
  
  Move? calculateBestMove(ChessBoardState boardState, bool isWhite) {
    // Get all legal moves for the current player
    List<Move> allLegalMoves = [];
    for (var piece in boardState.pieces) {
      if (piece.isWhite == isWhite) {
        List<Position> legalMoves = getLegalMoves(boardState, piece.position);
        for (var target in legalMoves) {
          allLegalMoves.add(Move(piece.position, target));
        }
      }
    }
    
    if (allLegalMoves.isEmpty) return null;
    
    // For beginner level, just pick a random move
    if (difficulty == difficulty_model.Difficulty.easy)  {
      return allLegalMoves[_random.nextInt(allLegalMoves.length)];
    }
    
    // For other difficulty levels, use minimax with different depths
    int depth;
    switch (difficulty) {
      case difficulty_model.Difficulty.easy:
        depth = 1;
        break;
      case difficulty_model.Difficulty.medium:
        depth = 2;
        break;
      case difficulty_model.Difficulty.hard:
        depth = 3;
        break;
      case difficulty_model.Difficulty.expert:
        depth = 4;
        break;
      // ignore: unreachable_switch_default
      default:
        depth = 2;
    }
    
    // Calculate best move using minimax with alpha-beta pruning
    Move? bestMove;
    int bestScore = -99999;
    
    for (var move in allLegalMoves) {
      // Make the move on a temporary board
      ChessBoardState newBoard = makeMove(boardState, move.from, move.to);
      
      // Calculate score using minimax
      int score = -_minimax(newBoard, depth - 1, -99999, 99999, !isWhite);
      
      // For medium difficulty and below, add some randomness to make it more human-like
      if (difficulty.index <= difficulty_model.Difficulty.medium.index) {
        score += _random.nextInt(21) - 10; // Add between -10 and +10
      }
      
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    
    return bestMove;
  }
  
  int _minimax(ChessBoardState boardState, int depth, int alpha, int beta, bool isMaximizingPlayer) {
    // Base case: evaluate board at leaf nodes
    if (depth == 0) {
      return _evaluateBoard(boardState);
    }
    
    // Check for game end
    GameState gameState = checkGameState(boardState, isMaximizingPlayer);
    if (gameState == GameState.checkmate) {
      return isMaximizingPlayer ? -9000 : 9000; // Winning is best, losing is worst
    } else if (gameState == GameState.stalemate || 
               gameState == GameState.insufficientMaterial ||
               gameState == GameState.threefoldRepetition ||
               gameState == GameState.fiftyMoveRule) {
      return 0; // Draw
    }
    
    // Get all legal moves for the current player
    List<Move> allLegalMoves = [];
    for (var piece in boardState.pieces) {
      if (piece.isWhite == isMaximizingPlayer) {
        List<Position> legalMoves = getLegalMoves(boardState, piece.position);
        for (var target in legalMoves) {
          allLegalMoves.add(Move(piece.position, target));
        }
      }
    }
    
    if (isMaximizingPlayer) {
      int maxEval = -99999;
      for (var move in allLegalMoves) {
        ChessBoardState newBoard = makeMove(boardState, move.from, move.to);
        int eval = _minimax(newBoard, depth - 1, alpha, beta, false);
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break; // Beta cutoff
      }
      return maxEval;
    } else {
      int minEval = 99999;
      for (var move in allLegalMoves) {
        ChessBoardState newBoard = makeMove(boardState, move.from, move.to);
        int eval = _minimax(newBoard, depth - 1, alpha, beta, true);
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break; // Alpha cutoff
      }
      return minEval;
    }
  }
  
  int _evaluateBoard(ChessBoardState boardState) {
    int score = 0;
    
    // Material value
    for (var piece in boardState.pieces) {
      int pieceValue = _getPieceValue(piece);
      score += piece.isWhite ? pieceValue : -pieceValue;
    }
    
    // Position value
    for (var piece in boardState.pieces) {
      int positionValue = _getPositionValue(piece);
      score += piece.isWhite ? positionValue : -positionValue;
    }
    
    return score;
  }
  
  int _getPieceValue(ChessPiece piece) {
    switch (piece.type) {
      case PieceType.pawn:
        return 100;
      case PieceType.knight:
        return 320;
      case PieceType.bishop:
        return 330;
      case PieceType.rook:
        return 500;
      case PieceType.queen:
        return 900;
      case PieceType.king:
        return 20000;
    }
  }
  
  int _getPositionValue(ChessPiece piece) {
    // Simple position evaluation based on piece type and position
    // For a proper chess engine, these tables would be much more sophisticated
    
    // Pawns are encouraged to advance
    if (piece.type == PieceType.pawn) {
      if (piece.isWhite) {
        return (7 - piece.position.y) * 10; // White pawns value advancing toward rank 0
      } else {
        return piece.position.y * 10; // Black pawns value advancing toward rank 7
      }
    }
    
    // Knights are more valuable in the center
    if (piece.type == PieceType.knight) {
      // Value based on distance from center
      int centerDistanceX = (piece.position.x - 3.5).abs().round();
      int centerDistanceY = (piece.position.y - 3.5).abs().round();
      return 20 - (centerDistanceX + centerDistanceY) * 5;
    }
    
    // Bishops prefer diagonals
    if (piece.type == PieceType.bishop) {
      // More open diagonals = better
      return 10 + _countDiagonalMoves(piece.position);
    }
    
    // Rooks prefer open files
    if (piece.type == PieceType.rook) {
      // More open files = better
      return 10 + _countFileMoves(piece.position);
    }
    
    // Queens combine bishop and rook mobility
    if (piece.type == PieceType.queen) {
      return 5 + _countDiagonalMoves(piece.position) + _countFileMoves(piece.position);
    }
    
    // Kings prefer safety in the early/mid game, and center control in the endgame
    if (piece.type == PieceType.king) {
      if (_isEndgame()) {
        // In endgame, kings should move toward center
        int centerDistanceX = (piece.position.x - 3.5).abs().round();
        int centerDistanceY = (piece.position.y - 3.5).abs().round();
        return 30 - (centerDistanceX + centerDistanceY) * 5;
      } else {
        // In early/mid game, kings prefer the corners and edges
        int edgeDistanceX = min(piece.position.x, 7 - piece.position.x);
        int edgeDistanceY = min(piece.position.y, 7 - piece.position.y);
        return (7 - edgeDistanceX - edgeDistanceY) * 5;
      }
    }
    
    return 0;
  }
  
  int _countDiagonalMoves(Position position) {
    // Simplified mobility count for bishops
    // In a real chess engine, this would check the actual available moves
    return 7; // Average number of diagonal moves
  }
  
  int _countFileMoves(Position position) {
    // Simplified mobility count for rooks
    // In a real chess engine, this would check the actual available moves
    return 10; // Average number of file/rank moves
  }
  
  bool _isEndgame() {
    // Simple endgame detection
    // In a real chess engine, this would be based on material count
    return true; // Simplified for this example
  }
  
  // Initialize a new chess board with standard setup
  ChessBoardState initializeNewGame() {
    List<ChessPiece> pieces = [];
    
    // Add pawns
    for (int x = 0; x < 8; x++) {
      pieces.add(ChessPiece(
        type: PieceType.pawn,
        isWhite: true,
        position: Position(x, 6),
      ));
      pieces.add(ChessPiece(
        type: PieceType.pawn,
        isWhite: false,
        position: Position(x, 1),
      ));
    }
    
    // Add rooks
    pieces.add(ChessPiece(type: PieceType.rook, isWhite: true, position: const Position(0, 7)));
    pieces.add(ChessPiece(type: PieceType.rook, isWhite: true, position: const Position(7, 7)));
    pieces.add(ChessPiece(type: PieceType.rook, isWhite: false, position: const Position(0, 0)));
    pieces.add(ChessPiece(type: PieceType.rook, isWhite: false, position: const Position(7, 0)));
    
    // Add knights
    pieces.add(ChessPiece(type: PieceType.knight, isWhite: true, position: const Position(1, 7)));
    pieces.add(ChessPiece(type: PieceType.knight, isWhite: true, position: const Position(6, 7)));
    pieces.add(ChessPiece(type: PieceType.knight, isWhite: false, position: const Position(1, 0)));
    pieces.add(ChessPiece(type: PieceType.knight, isWhite: false, position: const Position(6, 0)));
    
    // Add bishops
    pieces.add(ChessPiece(type: PieceType.bishop, isWhite: true, position: const Position(2, 7)));
    pieces.add(ChessPiece(type: PieceType.bishop, isWhite: true, position: const Position(5, 7)));
    pieces.add(ChessPiece(type: PieceType.bishop, isWhite: false, position: const Position(2, 0)));
    pieces.add(ChessPiece(type: PieceType.bishop, isWhite: false, position: const Position(5, 0)));
    
    // Add queens
    pieces.add(ChessPiece(type: PieceType.queen, isWhite: true, position: const Position(3, 7)));
    pieces.add(ChessPiece(type: PieceType.queen, isWhite: false, position: const Position(3, 0)));
    
    // Add kings
    pieces.add(ChessPiece(type: PieceType.king, isWhite: true, position: const Position(4, 7)));
    pieces.add(ChessPiece(type: PieceType.king, isWhite: false, position: const Position(4, 0)));
    
    return ChessBoardState(
      pieces: pieces,
      whiteToMove: true,
      castlingRights: {
        CastlingRights.whiteKingside,
        CastlingRights.whiteQueenside,
        CastlingRights.blackKingside,
        CastlingRights.blackQueenside,
      },
      enPassantTarget: null,
      halfMoveClock: 0,
      fullMoveNumber: 1,
      positionHistory: [],
    );
  }
  
  // Get move from algebraic notation (e.g. "e2e4")
  Move? getMoveFromAlgebraic(String algebraic, ChessBoardState boardState) {
    if (algebraic.length < 4) return null;
    
    final fromFile = algebraic[0].codeUnitAt(0) - 'a'.codeUnitAt(0);
    final fromRank = '8'.codeUnitAt(0) - algebraic[1].codeUnitAt(0);
    final toFile = algebraic[2].codeUnitAt(0) - 'a'.codeUnitAt(0);
    final toRank = '8'.codeUnitAt(0) - algebraic[3].codeUnitAt(0);
    
    if (fromFile < 0 || fromFile > 7 || fromRank < 0 || fromRank > 7 ||
        toFile < 0 || toFile > 7 || toRank < 0 || toRank > 7) {
      return null; // Invalid coordinates
    }
    
    final from = Position(fromFile, fromRank);
    final to = Position(toFile, toRank);
    
    // Check if the move is legal
    final piece = boardState.getPieceAt(from);
    if (piece == null) return null;
    
    List<Position> legalMoves = getLegalMoves(boardState, from);
    if (!legalMoves.any((pos) => pos.x == to.x && pos.y == to.y)) {
      return null; // Move is not legal
    }
    
    return Move(from, to);
  }
  
  // Convert move to algebraic notation
  String moveToAlgebraic(Move move) {
    final fromFile = String.fromCharCode('a'.codeUnitAt(0) + move.from.x);
    final fromRank = String.fromCharCode('8'.codeUnitAt(0) - move.from.y);
    final toFile = String.fromCharCode('a'.codeUnitAt(0) + move.to.x);
    final toRank = String.fromCharCode('8'.codeUnitAt(0) - move.to.y);
    
    return '$fromFile$fromRank$toFile$toRank';
  }
  
  // Generate hint for the player
  Move? generateHint(ChessBoardState boardState, bool isWhite) {
    // Use the AI to suggest a good move
    return calculateBestMove(boardState, isWhite);
  }
}

// Represents a chess move
class Move {
  final Position from;
  final Position to;
  
  Move(this.from, this.to);
  
  @override
  String toString() {
    return 'Move: (${from.x},${from.y}) to (${to.x},${to.y})';
  }
}

// Game state enumeration
enum GameState {
  ongoing,
  check,
  checkmate,
  stalemate,
  threefoldRepetition,
  fiftyMoveRule,
  insufficientMaterial,
}