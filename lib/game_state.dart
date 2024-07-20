class GameState {
  final int playerTwoScore;
  final int playerOneScore;
  final bool playerOneServing;
  final int servingTurns;

  GameState({
    required this.playerOneScore,
    required this.playerTwoScore,
    required this.playerOneServing,
    required this.servingTurns,
  });
}
