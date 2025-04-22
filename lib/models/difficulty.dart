/// Defines the available difficulty levels for AI opponents in the Chess game.
enum Difficulty {
  /// Easy difficulty - suitable for beginners
  easy,

  /// Medium difficulty - balanced challenge
  medium,

  /// Hard difficulty - challenging for experienced players
  hard,

  /// Expert difficulty - very challenging even for advanced players
  expert;

  /// Returns a descriptive name for the difficulty level
  String get name {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.expert:
        return 'Expert';
    }
  }

  /// Returns a brief description of the difficulty level
  String get description {
    switch (this) {
      case Difficulty.easy:
        return 'Perfect for beginners learning chess basics';
      case Difficulty.medium:
        return 'Balanced challenge for casual players';
      case Difficulty.hard:
        return 'Challenging gameplay for experienced players';
      case Difficulty.expert:
        return 'Advanced tactics and deep thinking required';
    }
  }

  /// Returns the estimated ELO rating range for this difficulty level
  String get eloRange {
    switch (this) {
      case Difficulty.easy:
        return '800-1000';
      case Difficulty.medium:
        return '1000-1400';
      case Difficulty.hard:
        return '1400-1800';
      case Difficulty.expert:
        return '1800+';
    }
  }

  /// Returns the recommended thinking time in seconds for the AI at this difficulty
  int get recommendedThinkingTimeSeconds {
    switch (this) {
      case Difficulty.easy:
        return 1;
      case Difficulty.medium:
        return 2;
      case Difficulty.hard:
        return 4;
      case Difficulty.expert:
        return 6;
    }
  }

  /// Returns the search depth for the chess engine at this difficulty
  int get searchDepth {
    switch (this) {
      case Difficulty.easy:
        return 2;
      case Difficulty.medium:
        return 4;
      case Difficulty.hard:
        return 6;
      case Difficulty.expert:
        return 8;
    }
  }
}