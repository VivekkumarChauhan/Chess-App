import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/difficulty.dart';
import '../models/game_mode.dart' as game_mode; // Added prefix
import '../models/chess_piece.dart';
import '../models/chess_board_state.dart';
import '../widgets/chess_board.dart';
import '../widgets/captured_pieces.dart';
import '../widgets/player_info.dart';
import '../logic/chess_engine.dart';
import 'package:chess_app/logic/chess_engine.dart' as engine;
//import 'package:chess_app/models/chess_board_state.dart';

class GameScreen extends StatefulWidget {
  final game_mode.GameMode gameMode; // Updated to use prefix
  final Difficulty difficulty;
  final bool playAsWhite;
  final int timeControl;

  const GameScreen({
    super.key,
    required this.gameMode,
    required this.difficulty,
    required this.playAsWhite,
    required this.timeControl,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Difficulty>('difficulty', difficulty));
    // Removed duplicate property
  }
}

class _GameScreenState extends State<GameScreen> {
  late ChessBoardState _boardState;
  late ChessEngine _engine;
  bool _whiteToMove = true;
  List<ChessPiece> _capturedWhitePieces = [];
  List<ChessPiece> _capturedBlackPieces = [];
  ChessPiece? _selectedPiece;
  List<Position> _legalMoves = [];
  Position? _lastMoveFrom;
  Position? _lastMoveTo;
  bool _gameOver = false;
  String _gameResult = '';
  
  // Time control variables
  late int _whiteTimeLeftInSeconds;
  late int _blackTimeLeftInSeconds;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _boardState = ChessBoardState.initial();
    _engine = ChessEngine(difficulty: widget.difficulty);
    
    // Initialize time control
    if (widget.timeControl > 0) {
      _whiteTimeLeftInSeconds = widget.timeControl * 60;
      _blackTimeLeftInSeconds = widget.timeControl * 60;
      _startTimer();
    } else {
      _whiteTimeLeftInSeconds = 0;
      _blackTimeLeftInSeconds = 0;
    }
    
    // If player is black and playing against computer, make computer's first move
    if (!widget.playAsWhite && widget.gameMode == game_mode.GameMode.vsComputer) {
      _makeComputerMove();
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  void _startTimer() {
    if (widget.timeControl <= 0) return;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_whiteToMove) {
          _whiteTimeLeftInSeconds--;
          if (_whiteTimeLeftInSeconds <= 0) {
            _endGame('Black wins by timeout');
          }
        } else {
          _blackTimeLeftInSeconds--;
          if (_blackTimeLeftInSeconds <= 0) {
            _endGame('White wins by timeout');
          }
        }
      });
    });
  }
  
  void _endGame(String result) {
    _timer?.cancel();
    setState(() {
      _gameOver = true;
      _gameResult = result;
    });
  }
  
  bool _isPlayerTurn() {
    if (widget.gameMode == game_mode.GameMode.vsHuman) return true;
    return widget.playAsWhite == _whiteToMove;
  }
  
  void _onSquareTapped(Position position) {
    if (_gameOver || !_isPlayerTurn()) return;
    
    final piece = _boardState.getPieceAt(position);
    
    // If no piece is selected and the tapped square has a piece of the current player's color
    if (_selectedPiece == null && piece != null && piece.isWhite == _whiteToMove) {
      setState(() {
        _selectedPiece = piece;
        _legalMoves = _engine.getLegalMoves(_boardState, position);
      });
      return;
    }
    
    // If a piece is already selected
    if (_selectedPiece != null) {
      // If tapping the same piece, deselect it
      if (piece == _selectedPiece) {
        setState(() {
          _selectedPiece = null;
          _legalMoves = [];
        });
        return;
      }
      
      // If tapping another piece of the same color, select that piece instead
      if (piece != null && piece.isWhite == _selectedPiece!.isWhite) {
        setState(() {
          _selectedPiece = piece;
          _legalMoves = _engine.getLegalMoves(_boardState, position);
        });
        return;
      }
      
      // If tapping a valid destination square, move the piece
      if (_legalMoves.any((pos) => pos.x == position.x && pos.y == position.y)) {
        _movePiece(_selectedPiece!.position, position);
      }
    }
  }
  
  void _movePiece(Position from, Position to) {
    final capturedPiece = _boardState.getPieceAt(to);
    
    setState(() {
      // Update last move indicators
      _lastMoveFrom = from;
      _lastMoveTo = to;
      
      // Record captured piece if any
      if (capturedPiece != null) {
        if (capturedPiece.isWhite) {
          _capturedWhitePieces.add(capturedPiece);
        } else {
          _capturedBlackPieces.add(capturedPiece);
        }
      }
      
      // Execute the move
      _boardState = _engine.makeMove(_boardState, from, to);
      
      // Check game state
      final gameState = _engine.checkGameState(_boardState, !_whiteToMove);
      if (gameState == engine.GameState.checkmate) {
        _endGame(_whiteToMove ? 'White wins by checkmate' : 'Black wins by checkmate');
      } else if (gameState == engine.GameState.stalemate) {
        _endGame('Draw by stalemate');
      } else if (gameState == engine.GameState.insufficientMaterial) {
        _endGame('Draw by insufficient material');
      } else if (gameState == engine.GameState.fiftyMoveRule) {
        _endGame('Draw by fifty-move rule');
      } else if (gameState == engine.GameState.threefoldRepetition) {
        _endGame('Draw by threefold repetition');
      }
      
      // Reset selection
      _selectedPiece = null;
      _legalMoves = [];
      
      // Switch turns
      _whiteToMove = !_whiteToMove;
    });
    
    // Make computer move if playing against computer and it's computer's turn
    if (!_gameOver && widget.gameMode == game_mode.GameMode.vsComputer && !_isPlayerTurn()) {
      Future.delayed(const Duration(milliseconds: 500), _makeComputerMove);
    }
  }
  
  void _makeComputerMove() {
    final move = _engine.calculateBestMove(_boardState, _whiteToMove);
    if (move != null) {
      _movePiece(move.from, move.to);
    }
  }
  
  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text(_gameResult),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back to Setup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }
  
  void _resetGame() {
    setState(() {
      _boardState = ChessBoardState.initial();
      _whiteToMove = true;
      _capturedWhitePieces = [];
      _capturedBlackPieces = [];
      _selectedPiece = null;
      _legalMoves = [];
      _lastMoveFrom = null;
      _lastMoveTo = null;
      _gameOver = false;
      _gameResult = '';
      
      // Reset timers
      if (widget.timeControl > 0) {
        _whiteTimeLeftInSeconds = widget.timeControl * 60;
        _blackTimeLeftInSeconds = widget.timeControl * 60;
        _timer?.cancel();
        _startTimer();
      }
    });
    
    // If player is black and playing against computer, make computer's first move
    if (!widget.playAsWhite && widget.gameMode == game_mode.GameMode.vsComputer) {
      Future.delayed(const Duration(milliseconds: 500), _makeComputerMove);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_gameOver) {
      Future.microtask(_showGameOverDialog);
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameMode == game_mode.GameMode.vsComputer 
          ? 'vs Computer (${widget.difficulty.name})' 
          : 'vs Friend'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Black player info
            PlayerInfo(
              isWhite: false,
              isCurrentTurn: !_whiteToMove,
              timeLeftInSeconds: _blackTimeLeftInSeconds,
              isHuman: widget.gameMode == game_mode.GameMode.vsHuman || !widget.playAsWhite,
              isGameActive: !_gameOver,
            ),
            
            // Captured white pieces
            CapturedPieces(
              pieces: _capturedWhitePieces,
              isWhite: true,
            ),
            
            // Chess board
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ChessBoard(
                    boardState: _boardState,
                    selectedPiece: _selectedPiece,
                    legalMoves: _legalMoves,
                    lastMoveFrom: _lastMoveFrom,
                    lastMoveTo: _lastMoveTo,
                    flipped: !widget.playAsWhite,
                    onSquareTapped: _onSquareTapped,
                  ),
                ),
              ),
            ),
            
            // Captured black pieces
            CapturedPieces(
              pieces: _capturedBlackPieces,
              isWhite: false,
            ),
            
            // White player info
            PlayerInfo(
              isWhite: true,
              isCurrentTurn: _whiteToMove,
              timeLeftInSeconds: _whiteTimeLeftInSeconds,
              isHuman: widget.gameMode == game_mode.GameMode.vsHuman || widget.playAsWhite,
              isGameActive: !_gameOver,
            ),
          ],
        ),
      ),
    );
  }
}