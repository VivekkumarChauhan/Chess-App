import 'package:flutter/material.dart';

class PlayerInfo extends StatelessWidget {
  final bool isWhite;
  final bool isCurrentTurn;
  final int timeLeftInSeconds;
  final bool isHuman;
  final bool isGameActive;
  
  const PlayerInfo({
    super.key,
    required this.isWhite,
    required this.isCurrentTurn,
    required this.timeLeftInSeconds,
    required this.isHuman,
    required this.isGameActive,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentTurn && isGameActive
            ? isWhite ? Colors.black12 : Colors.black26
            : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isWhite ? Colors.white : Colors.black,
              shape: BoxShape.circle,
              border: Border.all(
                color: isWhite ? Colors.black : Colors.white,
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isHuman ? 'Player' : 'Computer',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isWhite ? Colors.black87 : Colors.black,
            ),
          ),
          const Spacer(),
          if (timeLeftInSeconds > 0)
            Text(
              _formatTime(timeLeftInSeconds),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: timeLeftInSeconds < 30 ? Colors.red : Colors.black87,
              ),
            ),
        ],
      ),
    );
  }
  
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}