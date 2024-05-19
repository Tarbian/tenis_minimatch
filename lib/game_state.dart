class GameState {
  int playerOneScore;
  int playerTwoScore;
  bool playerOneServing;
  int servingTurns;

  GameState({
    required this.playerOneScore,
    required this.playerTwoScore,
    required this.playerOneServing,
    required this.servingTurns,
  });
}
