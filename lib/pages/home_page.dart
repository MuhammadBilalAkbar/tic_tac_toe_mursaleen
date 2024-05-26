import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../widgets/frosted_glass.dart';
import '../constants/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> listXO = List.generate(9, (index) => emptyImage);

  bool winnerO = false;
  bool winnerX = false;
  bool isMuted = false;
  bool isOTurn = true;
  bool isPaused = false;

  int playerOScore = 0;
  int playerXScore = 0;
  int equal = 0;
  int filledBoxes = 0;

  static const maxSeconds = 15;
  int seconds = maxSeconds;
  Timer? turnTimer;

  bool playAgain = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    debugPrint('$height');
    debugPrint('$width');
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Stack(
            children: [
              Image.asset(
                backgroundImage,
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
              Container(
                color: Colors.black.withOpacity(0.65),
                height: double.infinity,
                width: double.infinity,
              ),
              buildRow(width, height),
              getScoreBoard(width, height),
              buildGridView(width, height),
              buildTimer(width, height),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRow(double width, double height) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: height * 0.83,
      child: Container(
        height: double.infinity,
        width: double.infinity,
        margin: EdgeInsets.all(width * 0.05),
        child: Row(
          children: [
            buildIconButton(
              onTap: () => pauseGame(width, height),
              // onTap: () => showWinDialog(width: width, height: height, winner: 'm'),
              image: isPaused ? resumeIcon : pauseIcon,
              width: width,
            ),
            const Spacer(),
            buildIconButton(
              onTap: toggleSound,
              image: isMuted ? musicIcon : noMusicIcon,
              width: width,
            ),
            SizedBox(width: width * 0.04),
            buildIconButton(
              onTap: () => resetGame(width, height),
              image: resetIcon,
              width: width,
            ),
          ],
        ),
      ),
    );
  }

  Widget getScoreBoard(double width, double height) {
    return Positioned(
      top: height * 0.11,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          margin: EdgeInsets.all(width * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: height * 0.065,
                    width: width * 0.35,
                    padding: EdgeInsets.symmetric(
                      vertical: width * 0.011,
                      horizontal: width * 0.03,
                    ),
                    decoration: BoxDecoration(
                      color: isOTurn ? greenColor : Colors.grey,
                      borderRadius: BorderRadius.circular(15),
                      border: isOTurn
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Player O', style: textStyle1),
                            Text('Win: $playerOScore', style: textStyle1),
                          ],
                        ),
                        const Spacer(),
                        Image.asset(
                          playerOImage,
                          height: width * 0.07,
                          width: width * 0.07,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Visibility(
                    visible: isOTurn,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: Text('Your Turn', style: textStyle2),
                  ),
                ],
              ),
              Container(
                height: height * 0.065,
                width: width * 0.15,
                margin: EdgeInsets.only(bottom: height * 0.038),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Equals', style: textStyle1),
                    Text('$equal', style: textStyle1),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    height: height * 0.065,
                    width: width * 0.35,
                    padding: EdgeInsets.symmetric(
                      vertical: width * 0.011,
                      horizontal: width * 0.03,
                    ),
                    decoration: BoxDecoration(
                      color: !isOTurn ? greenColor : Colors.grey,
                      borderRadius: BorderRadius.circular(15),
                      border: !isOTurn
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Player X', style: textStyle1),
                            Text('Win: $playerXScore', style: textStyle1),
                          ],
                        ),
                        const Spacer(),
                        Image.asset(
                          playerXImage,
                          height: width * 0.06,
                          width: width * 0.06,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Visibility(
                    visible: !isOTurn,
                    maintainAnimation: true,
                    maintainSize: true,
                    maintainState: true,
                    child: Text('Your Turn', style: textStyle2),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGridView(double width, double height) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: height * 0.425,
        width: double.infinity,
        margin: EdgeInsets.all(width * 0.05),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          // border: Border.all(color: Colors.white, width: 3),
          borderRadius: BorderRadius.circular(50),
        ),
        child: FrostedGlassBox(
          child: SizedBox(
            height: height * 0.425,
            child: GridView.builder(
              itemCount: 9,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: width * 0.3,
              ),
              itemBuilder: (context, index) {
                BorderRadius borderRadius;
                if (index == 0) {
                  borderRadius = const BorderRadius.only(
                    topLeft: Radius.circular(50),
                  );
                } else if (index == 2) {
                  borderRadius = const BorderRadius.only(
                    topRight: Radius.circular(50),
                  );
                } else if (index == 6) {
                  borderRadius = const BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                  );
                } else if (index == 8) {
                  borderRadius = const BorderRadius.only(
                    bottomRight: Radius.circular(50),
                  );
                } else {
                  borderRadius = BorderRadius.circular(0);
                }
                return GestureDetector(
                  onTap: isPaused ? () {} : () => onTap(index, width, height),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Center(
                      child: Image(
                        image: AssetImage(listXO[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTimer(double width, double height) {
    return Positioned(
      top: height * 0.8,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: width * 0.2,
          height: width * 0.2,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: 1 - seconds / maxSeconds,
                valueColor:
                    AlwaysStoppedAnimation(isOTurn ? greenColor : Colors.grey),
                strokeWidth: 8,
                backgroundColor: !isOTurn ? greenColor : Colors.grey,
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  '$seconds',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 50,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildIconButton({
    required VoidCallback onTap,
    required String image,
    required double width,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width * 0.1,
        height: width * 0.1,
        padding: EdgeInsets.all(width * 0.02),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [
            greenColor,
            Colors.green,
          ]),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Image.asset(image),
      ),
    );
  }

  Widget buildTextButton({
    required Function()? onTap,
    required double width,
    required double height,
    required String text,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width * 0.2,
        height: height * 0.05,
        padding: EdgeInsets.symmetric(horizontal: width * 0.01, vertical: height * 0.005),
        decoration: BoxDecoration(
          color: greenColor,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void checkWinner() {
    // Helper method to update the score and clear the board
    void updateScoreAndClearBoard(int index) {
      (listXO[index] == playerOImage) ? playerOScore++ : playerXScore++;
      (listXO[index] == playerOImage) ? winnerO = true : winnerX = true;
      clearBoard();
    }

    // Check 1st row
    if (listXO[0] == listXO[1] &&
        listXO[0] == listXO[2] &&
        listXO[0] != emptyImage) {
      updateScoreAndClearBoard(0);
    }
    // Check 2nd row
    else if (listXO[3] == listXO[4] &&
        listXO[3] == listXO[5] &&
        listXO[3] != emptyImage) {
      updateScoreAndClearBoard(3);
    }
    // Check 3rd row
    else if (listXO[6] == listXO[7] &&
        listXO[6] == listXO[8] &&
        listXO[6] != emptyImage) {
      updateScoreAndClearBoard(6);
    }
    // Check 1st column
    else if (listXO[0] == listXO[3] &&
        listXO[0] == listXO[6] &&
        listXO[0] != emptyImage) {
      updateScoreAndClearBoard(0);
    }
    // Check 2nd column
    else if (listXO[1] == listXO[4] &&
        listXO[1] == listXO[7] &&
        listXO[1] != emptyImage) {
      updateScoreAndClearBoard(1);
    }
    // Check 3rd column
    else if (listXO[2] == listXO[5] &&
        listXO[2] == listXO[8] &&
        listXO[2] != emptyImage) {
      updateScoreAndClearBoard(2);
    }
    // Check diagonal
    else if (listXO[0] == listXO[4] &&
        listXO[0] == listXO[8] &&
        listXO[0] != emptyImage) {
      updateScoreAndClearBoard(0);
    }
    // Check inverse diagonal
    else if (listXO[2] == listXO[4] &&
        listXO[2] == listXO[6] &&
        listXO[2] != emptyImage) {
      updateScoreAndClearBoard(2);
    }
    // If all boxes are filled and no winner, it's a draw
    else if (filledBoxes == 9) {
      equal++;
      clearBoard();
    }
  }

  void clearBoard() {
    Future.delayed(
      const Duration(seconds: 2),
      () => setState(() {
        for (int i = 0; i < listXO.length; i++) {
          listXO[i] = emptyImage;
          filledBoxes = 0;
          winnerO = false;
          winnerX = false;
        }
      }),
    );
  }

  void resetGame(double width, double height) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.all(width * 0.06),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Do you want to reset the game?', style: textStyle3),
            SizedBox(height: height * 0.01),
            Row(
              children: [
                const Spacer(),
                buildTextButton(
                  onTap: ()=> Navigator.pop(context),
                  text: 'No',
                  width: width,
                  height: height,
                ),
                SizedBox(width: width * 0.02),
                buildTextButton(
                  onTap: () {
                    setState(() {
                      for (int i = 0; i < listXO.length; i++) {
                        listXO[i] = emptyImage;
                      }
                      filledBoxes = 0;
                      winnerO = false;
                      winnerX = false;
                      playerOScore = 0;
                      playerXScore = 0;
                      equal = 0;
                      resetTimer();
                      pauseTimer();
                    });
                    playSound(resetGameSound);
                    Navigator.pop(context);
                  },
                  text: 'Yes',
                  width: width,
                  height: height,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void toggleSound() => setState(() => isMuted = !isMuted);

  void playSound(String path) {
    final player = AudioPlayer();
    if (isMuted) {
      null;
    } else {
      player.play(AssetSource(path));
    }
  }

  void pauseGame(double width, double height) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.all(width * 0.06),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isPaused
                  ? 'Do you want to resume the game?'
                  : 'Do you want to pause the game?',
              style: textStyle3,
            ),
            SizedBox(height: height * 0.01),
            Row(
              children: [
                const Spacer(),
                buildTextButton(
                  onTap: () => Navigator.pop(context),
                  text: 'No',
                  width: width,
                  height: height,
                ),
                SizedBox(width: width * 0.02),
                buildTextButton(
                  onTap: () {
                    setState(() {
                      isPaused ? startTimer() : pauseTimer();
                      isPaused = !isPaused;
                    });
                    Navigator.pop(context);
                  },
                  text: 'Yes',
                  width: width,
                  height: height,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void onTap(int index, double width, double height) {

    // void makeComputerMove(double width, double height) {
    //   List<int> emptyIndexes = [];
    //   for (int i = 0; i < listXO.length; i++) {
    //     if (listXO[i] == emptyImage) {
    //       emptyIndexes.add(i);
    //     }
    //   }
    //
    //   if (emptyIndexes.isNotEmpty) {
    //     int randomIndex = emptyIndexes[Random().nextInt(emptyIndexes.length)];
    //     onTap(randomIndex, width, height);
    //   }
    // }

    if (listXO[index] != emptyImage || winnerO || winnerX || filledBoxes == 9) {
      return;
    }
    setState(() {
      if (listXO[index] == emptyImage) {
        listXO[index] = isOTurn ? playerOImage : playerXImage;
        playSound(isOTurn ? oPlayerSound : xPlayerSound);
        startTimer();
        filledBoxes++;
        isOTurn = !isOTurn;
        checkWinner();
        resetTimer();
      }

      if (winnerO || winnerX) {
        playSound(winnerSound);
        cancelTimer();
        showWinDialog(
            winner: winnerO ? 'O!' : 'X!', width: width, height: height);
        return;
      }

      if (filledBoxes == 9) {
        playSound(equalSound);
        cancelTimer();
        showWinDialog(winner: 'Equal!', width: width, height: height);
        return;
      }

      // If it's the computer's turn, make a random move
      // if (!isOTurn) {
      //   Future.delayed(Duration(milliseconds: 500), () {
      //     makeComputerMove(width, height);
      //   });
      // }
    });
  }

  void showWinDialog({
    required String winner,
    required double width,
    required double height,
  }) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) {
                setState(() => playAgain = true);
              }
            });

            return AlertDialog(
              content: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: height * 0.08,
                    left: 0,
                    right: 0,
                    child: Image.asset(
                      winImage,
                      // scale: width / 400,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: height * 0.06),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Winner: $winner', style: textStyle3),
                        SizedBox(height: height * 0.01),
                        Container(
                          width: width * 0.33,
                          height: width * 0.11,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Center(
                            child: playAgain
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(() => playAgain = false);
                                    },
                                    child: const Text(
                                      'Play Again',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void startTimer() {
    cancelTimer();
    turnTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (seconds > 0) {
          seconds--;
        } else {
          isOTurn = !isOTurn;
          resetTimer();
        }
      });
    });
  }

  void cancelTimer() => turnTimer?.cancel();

  void resetTimer() => seconds = maxSeconds;

  void pauseTimer() {
    if (turnTimer != null && turnTimer!.isActive) {
      turnTimer?.cancel();
    }
  }

  final textStyle1 = const TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  final textStyle2 = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  final textStyle3 = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
}
