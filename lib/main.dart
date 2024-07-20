import 'package:flutter/material.dart';
import 'dart:math';
import 'package:wakelock/wakelock.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(
      MaterialApp(
        home: const TennisScoreApp(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          useMaterial3: true,
        ),
      ),
    );

class TennisScoreApp extends StatefulWidget {
  const TennisScoreApp({Key? key}) : super(key: key);

  @override
  State<TennisScoreApp> createState() => _TennisScoreAppState();
}

class _TennisScoreAppState extends State<TennisScoreApp> {
  int playerOneScore = 0, playerTwoScore = 0, servingTurns = 0;
  bool playerOneServing = Random().nextBool();
  List<Map<String, dynamic>> gameStateHistory = [];
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
    if (gameStateHistory.isNotEmpty) {
      setState(() {
        final lastState = gameStateHistory.removeLast();
        playerOneScore = lastState['playerOneScore'];
        playerTwoScore = lastState['playerTwoScore'];
        playerOneServing = lastState['playerOneServing'];
        servingTurns = lastState['servingTurns'];
      });
    }
  }

  void incrementScore(bool isPlayerOne) {
    setState(() {
      gameStateHistory.add({
        'playerOneScore': playerOneScore,
        'playerTwoScore': playerTwoScore,
        'playerOneServing': playerOneServing,
        'servingTurns': servingTurns,
      });

      if (isPlayerOne) {
        playerOneScore++;
      } else {
        playerTwoScore++;
      }

      if (checkWinner()) return;

      if (++servingTurns >= 2) {
        playerOneServing = !playerOneServing;
        servingTurns = 0;
      }
    });
  }

  bool checkWinner() {
    final winner = playerOneScore >= 11 && playerOneScore >= playerTwoScore + 2
        ? 'Left'
        : playerTwoScore >= 11 && playerTwoScore >= playerOneScore + 2
            ? 'Right'
            : null;
    if (winner != null) {
      showWinnerDialog(winner);
      resetGame();
      return true;
    }
    return false;
  }

  void showWinnerDialog(String winner) {
    final int finalPlayerOneScore = playerOneScore;
    final int finalPlayerTwoScore = playerTwoScore;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Winner'),
        content: Text(
            '$winner wins!\nScore: $finalPlayerOneScore : $finalPlayerTwoScore'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
    playRandomSound();
  }

  Future<void> playRandomSound() async {
    await _audioPlayer
        .play(AssetSource(_soundFiles[Random().nextInt(_soundFiles.length)]));
  }

  void resetGame() {
    setState(() {
      playerOneScore = playerTwoScore = servingTurns = 0;
      playerOneServing = Random().nextBool();
      gameStateHistory.clear();
    });
  }

  Widget buildScoreButton(bool isPlayerOne) {
    final color = isPlayerOne ? Colors.green : Colors.blue;
    final score = isPlayerOne ? playerOneScore : playerTwoScore;
    final isServing = isPlayerOne ? playerOneServing : !playerOneServing;

    return Expanded(
      child: GestureDetector(
        onTap: () => incrementScore(isPlayerOne),
        child: Container(
          color: color,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$score',
                style: const TextStyle(fontSize: 32.0, color: Colors.white),
              ),
              if (isServing)
                const Text(
                  'Serves',
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                buildScoreButton(true),
                buildScoreButton(false),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 235, 128, 122),
                  disabledBackgroundColor: Colors.red.shade200,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white70,
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
