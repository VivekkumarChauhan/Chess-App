import 'package:flutter/material.dart';
import '../screens/game_setup_screen.dart';
import '../models/game_mode.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Master'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF5F5F5)],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/chess_logo.png',
                      width: 150,
                      height: 150,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.check,
                          size: 150,
                          color: Colors.black,
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Chess Master',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Play chess offline against AI or friends',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 60),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GameSetupScreen(
                              gameMode: GameMode.vsComputer,
                            ),
                          ),
                        );
                      },
                      child: const Text('Play vs Computer'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GameSetupScreen(
                              gameMode: GameMode.vsHuman,
                            ),
                          ),
                        );
                      },
                      child: const Text('Play vs Friend'),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('How to Play'),
                            content: const SingleChildScrollView(
                              child: Text(
                                'Standard chess rules apply. Tap a piece to select it and tap again on a valid square to move.\n\n'
                                'In computer mode, choose difficulty from beginner to expert.\n\n'
                                'In two-player mode, take turns using the same device.\nMade by github.com/VivekkumarChauhan',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('How to Play'),
                    ),
                    const SizedBox(height: 80), // Extra space for the credit
                  ],
                ),
              ),
            ),
            // Made by credit at the bottom
            const Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Made by github.com/VivekkumarChauhan',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}