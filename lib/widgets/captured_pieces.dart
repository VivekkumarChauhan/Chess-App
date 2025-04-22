import 'package:flutter/material.dart';
import '../models/chess_piece.dart';

class CapturedPieces extends StatelessWidget {
  final List<ChessPiece> pieces;
  final bool isWhite;
  
  const CapturedPieces({
    super.key,
    required this.pieces,
    required this.isWhite,
  });
  
  @override
  Widget build(BuildContext context) {
    if (pieces.isEmpty) {
      return const SizedBox(height: 24);
    }
    
    // Sort pieces by value
    final sortedPieces = List<ChessPiece>.from(pieces)
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (var piece in sortedPieces)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                piece.symbol,
                style: const TextStyle(
                  fontSize: 18, 
                ),
              ),
            ),
        ],
      ),
    );
  }
}