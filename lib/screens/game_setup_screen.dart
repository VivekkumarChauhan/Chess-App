import 'package:flutter/material.dart';
import '../models/game_mode.dart' hide Difficulty;
import '../models/difficulty.dart';
import '../screens/game_screen.dart';

class GameSetupScreen extends StatefulWidget {
  final GameMode gameMode;
  
  const GameSetupScreen({super.key, required this.gameMode});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  Difficulty _difficulty = Difficulty.medium;
  bool _playAsWhite = true;
  int _timeControl = 10; // Minutes per player
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.gameMode == GameMode.vsComputer 
            ? 'Play vs Computer' 
            : 'Play vs Friend',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Game Setup',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            
            // Computer difficulty setting (only for vs Computer mode)
            if (widget.gameMode == GameMode.vsComputer) ...[
              const Text(
                'Computer Difficulty',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: Difficulty.values.map((difficulty) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildDifficultyButton(difficulty),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
            ],
            
            // Color selection
            const Text(
              'Play as',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildColorSelectionButton(true),
                const SizedBox(width: 16),
                _buildColorSelectionButton(false),
              ],
            ),
            const SizedBox(height: 32),
            
            // Time control
            const Text(
              'Time Control',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTimeControlButton(5),
                  _buildTimeControlButton(10),
                  _buildTimeControlButton(15),
                  _buildTimeControlButton(30),
                  _buildTimeControlButton(0, label: "None"),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Start game button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _startGame,
                child: const Text(
                  'Start Game',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDifficultyButton(Difficulty difficulty) {
    final isSelected = _difficulty == difficulty;
    return ChoiceChip(
      label: Text(difficulty.name),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _difficulty = difficulty);
        }
      },
    );
  }
  
  Widget _buildTimeControlButton(int minutes, {String? label}) {
    final isSelected = _timeControl == minutes;
    return ChoiceChip(
      label: Text(label ?? "$minutes min"),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _timeControl = minutes);
        }
      },
    );
  }
  
  Widget _buildColorSelectionButton(bool isWhite) {
    final isSelected = _playAsWhite == isWhite;
    return Expanded(
      child: ChoiceChip(
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isWhite ? Colors.white : Colors.black,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isWhite ? Colors.black : Colors.white,
                  width: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isWhite ? 'White' : 'Black',
              style: TextStyle(
                color: isWhite ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _playAsWhite = isWhite);
          }
        },
        backgroundColor: isWhite ? Colors.white : Colors.black,
        selectedColor: isWhite ? Colors.blue[100] : Colors.blue[900],
      ),
    );
  }
  
  void _startGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          gameMode: widget.gameMode,
          difficulty: _difficulty,
          playAsWhite: _playAsWhite,
          timeControl: _timeControl,
        ),
      ),
    );
  }
}