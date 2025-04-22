enum GameMode {
  vsComputer,
  vsHuman
}

enum Difficulty {
  beginner,
  easy,
  medium,
  hard,
  expert
}

extension DifficultyExtension on Difficulty {
  String get name {
    switch (this) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.expert:
        return 'Expert';
      // ignore: unreachable_switch_default
      default:
        return toString().split('.').last;
    }
  }
}