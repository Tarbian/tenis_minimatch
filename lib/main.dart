import 'package:flutter/material.dart';
import 'dart:math';
import 'package:wakelock/wakelock.dart';
import 'game_state.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TennisScoreApp(),
    );
  }
}

class TennisScoreApp extends StatefulWidget {
  const TennisScoreApp({super.key});

  @override
  State<TennisScoreApp> createState() => _TennisScoreAppState();
}

class _TennisScoreAppState extends State<TennisScoreApp> {
  int playerOneScore = 0;
  int playerTwoScore = 0;
  bool playerOneServing = Random().nextBool();
  int servingTurns = 0;
  List<GameState> gameStateHistory = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<String> _soundFiles = [
    'sound/audience-applause-clapping-soundroll-1-00-10.mp3',
    'sound/nice-impressed-female-smartsound-fx-1-00-01.mp3',
    'sound/we-ve-got-a-winner-carnival-speaker-voice-dan-barracuda-1-00-02.mp3',
    'sound/mixkit-achievement-bell-600.wav',
    'sound/mixkit-ethereal-fairy-win-sound-2019.wav'
  ];
  @override
  void initState() {
    super.initState();
    Wakelock.enable();
  }

  @override
  void dispose() {
    Wakelock.disable();
    super.dispose();
  }

  void undoLastScore() {
    setState(() {
      if (gameStateHistory.isNotEmpty) {
        GameState lastState = gameStateHistory.removeLast();
        playerOneScore = lastState.playerOneScore;
        playerTwoScore = lastState.playerTwoScore;
        playerOneServing = lastState.playerOneServing;
        servingTurns = lastState.servingTurns;
      }
    });
  }

  void checkScore() {
    setState(() {
      if (playerOneScore >= 11 && playerOneScore >= playerTwoScore + 2) {
        showWinnerDialog('Left', playerOneScore, playerTwoScore);
        resetGame();
      } else if (playerTwoScore >= 11 && playerTwoScore >= playerOneScore + 2) {
        showWinnerDialog('Right', playerOneScore, playerTwoScore);
        resetGame();
      } else {
        changeServer();
      }
    });
  }

  void changeServer() {
    servingTurns++;
    if (servingTurns >= 2) {
      setState(() {
        playerOneServing = !playerOneServing;
        servingTurns = 0;
      });
    }
  }

  void incrementPlayerOneScore() {
    setState(() {
      gameStateHistory.add(GameState(
        playerOneScore: playerOneScore,
        playerTwoScore: playerTwoScore,
        playerOneServing: playerOneServing,
        servingTurns: servingTurns,
      ));
      playerOneScore++;
      checkScore();
    });
  }

  void incrementPlayerTwoScore() {
    setState(() {
      gameStateHistory.add(GameState(
        playerOneScore: playerOneScore,
        playerTwoScore: playerTwoScore,
        playerOneServing: playerOneServing,
        servingTurns: servingTurns,
      ));
      playerTwoScore++;
      checkScore();
    });
  }

  void showWinnerDialog(
      String winner, int playerOneScore, int playerTwoScore) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Winner'),
          content:
              Text('$winner wins!\nScore: $playerOneScore : $playerTwoScore'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
    await playRandomSound();
  }

  Future<void> playRandomSound() async {
    final random = Random();
    String soundFile = _soundFiles[random.nextInt(_soundFiles.length)];
    await _audioPlayer.play(AssetSource(soundFile));
  }

  void resetGame() {
    setState(() {
      playerOneScore = 0;
      playerTwoScore = 0;
      playerOneServing = Random().nextBool();
      servingTurns = 0;
      gameStateHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: OrientationBuilder(
          builder: (context, orientation) {
            return orientation == Orientation.portrait
                ? Column(
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: GestureDetector(
                                onTap: incrementPlayerOneScore,
                                child: Container(
                                  color: Colors.green,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$playerOneScore',
                                        style: const TextStyle(
                                          fontSize: 32.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (playerOneServing)
                                        const Text(
                                          'Serves',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: incrementPlayerTwoScore,
                                child: Container(
                                  color: Colors.blue,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$playerTwoScore',
                                        style: const TextStyle(
                                          fontSize: 32.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (!playerOneServing)
                                        const Text(
                                          'Serves',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: undoLastScore,
                            child: const Text('Undo'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onLongPress: resetGame,
                            onPressed: null,
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: GestureDetector(
                                onTap: incrementPlayerOneScore,
                                child: Container(
                                  color: Colors.green,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$playerOneScore',
                                        style: const TextStyle(
                                          fontSize: 32.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (playerOneServing)
                                        const Text(
                                          'Serves',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: incrementPlayerTwoScore,
                                child: Container(
                                  color: Colors.blue,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$playerTwoScore',
                                        style: const TextStyle(
                                          fontSize: 32.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (!playerOneServing)
                                        const Text(
                                          'Serves',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: undoLastScore,
                            child: const Text('Undo'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onLongPress: resetGame,
                            onPressed: null,
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
