import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:control_app/counter.dart';
import 'package:control_app/old.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'global.dart';
import 'global.dart' as global;

List<int> convertStringToASCII(String inputString) {
  List<int> asciiCodes = [];
  for (int i = 0; i < inputString.length; i++) {
    int asciiCode = inputString.codeUnitAt(i);
    asciiCodes.add(asciiCode);
  }
  return asciiCodes;
}

bool askedOnce = false;

Uint8List? sendString;
bool didSend = false;

dynamic sub;

void updateLed(Uint8List s) {
  sendString = s;
  connection?.output.add(s);
  didSend = true;
}

class Led extends StatefulWidget {
  const Led({super.key});

  @override
  State<Led> createState() => _LedState();
}

class _LedState extends State<Led> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    debugPrint("inited led control ui");
    global.connectionChangeFnNotify = () {
      setState(() {});
    };

    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    try {
      sub.cancel();
      sub = null;
    } catch (e) {
      debugPrint("Failed on disposing the sub");
    }
    super.dispose();
  }

  List<String> teamNames = ["Team A", "Team B", "Welcome to NGPiTECH"];
  List<int> scoreValue = [0, 0];
  List<int> winningSet = [0, 0];
  List<int> foul = [0, 0];
  List<int> timeout = [1, 1];
  bool _showText = true;
  bool _showTextField = false;
  int changingTeam = 0;
  String textToShow = "Welcome to Dr N.G.P College's tournament.";
  final TextEditingController _textController = TextEditingController();

  int _seconds = 0;
  bool _isRunning = false;
  late Timer _timer;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds += 1;
      });
    });
  }

  void _stopTimer() {
    _timer.cancel();
  }

  void _resetTimer() {
    connection!.output.add(Uint8List.fromList([88]));
    _timer.cancel();
    _isRunning = false;
    setState(() {
      _seconds = 0;
    });
  }

  void _toggleTimer() {
    setState(() {
      if (_isRunning) {
        debugPrint("Stopping");
        connection!.output.add(Uint8List.fromList([90]));
        _stopTimer();
      } else {
        debugPrint("Resuming");
        connection!.output.add(Uint8List.fromList([89]));
        _startTimer();
      }
      _isRunning = !_isRunning;
    });
  }

  String _formatTime() {
    int minutes = _seconds ~/ 60;
    int seconds = (_seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    void stuff(dynamic event) {
      String output = utf8.decode(event).replaceAll(RegExp(r'\d+'), '');
      if (output == "") return;
      if (output.trim() == utf8.decode(sendString!).trim()) {
        connection!.output.add(Uint8List.fromList([97]));
      } else {
        debugPrint(
            "Meant: ${utf8.decode(sendString!).trim()} | Displaying: ${output.trim()}");
        updateLed(sendString!);
      }
    }

    global.callback = stuff;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.bluetooth),
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                  pageBuilder: (c, a1, a2) => const Home(),
                  transitionsBuilder: (context, animation, secondaryAnimation,
                          child) =>
                      FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                              scale: animation.drive(Tween(begin: 1.5, end: 1.0)
                                  .chain(
                                      CurveTween(curve: Curves.easeOutCubic))),
                              child: child)),
                  transitionDuration: const Duration(seconds: 1)),
            );
          }),
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
              Colors.black
                  .withOpacity(0.5), // Adjust opacity and darkness level
              BlendMode.darken,
            ),

            image: AssetImage(global.bg ??
                "assets/controllerBG.jpg"), // Replace with your background image path
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          blendMode: BlendMode.srcIn,
          filter: ImageFilter.blur(
              sigmaX: 5.0, sigmaY: 5.0), // Adjust the blur intensity
          child: AnimatedCrossFade(
            sizeCurve: Curves.easeInOutExpo,
            crossFadeState: global.isConnected == true
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 750),
            secondChild: Center(
                child: SizedBox(
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
                child: AnimatedTextKit(
                  repeatForever: true,
                  pause: const Duration(milliseconds: 500),
                  animatedTexts: [
                    FadeAnimatedText('Bluetooth device is not connected'),
                    FadeAnimatedText('Please connect HC-05 device first'),
                    FadeAnimatedText(
                        'HC-05 pin is 1234 , connect with bluetooth to proceed'),
                  ],
                  onTap: () {
                    print("Tap Event");
                  },
                ),
              ),
            )),
            firstChild: SingleChildScrollView(
              // ignore: avoid_unnecessary_containers
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 600),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 150.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AnimatedSwitcher(
                        duration: const Duration(
                            milliseconds: 500), // Animation duration
                        child: _showTextField
                            ? InkWell(
                                onTap: () {
                                  setState(() {
                                    _showText = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.transparent,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: SizedBox(
                                    height: 50,
                                    width: double.infinity,
                                    child: TextField(
                                      controller: _textController,
                                      onSubmitted: (value) {
                                        try {
                                          setState(() {
                                            updateLed(Uint8List.fromList(
                                                convertStringToASCII(
                                                    "${changingTeam == 1 ? "T" : (changingTeam == 0 ? "S" : "U")}${_textController.text}")));
                                            teamNames[changingTeam] = value;
                                            _textController.clear();
                                            _showTextField = false;
                                          });
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "Failed : ${e.toString()}")));
                                        }
                                      },
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 24),
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter text',
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                key:
                                    UniqueKey(), // Required to identify the widget changes
                                children: [
                                  Text(
                                    textToShow,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 24),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildTeamSection(0),
                        ),
                        Expanded(
                          flex: 1,
                          child: _buildTeamSection(1),
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildIconButton(
                                  !_isRunning
                                      ? Icons.play_circle
                                      : Icons.stop_circle, () {
                                try {
                                  _toggleTimer();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Failed : ${e.toString()}")));
                                }
                              }),
                              const SizedBox(
                                width: 30,
                              ),
                              _buildIconButton(Icons.restart_alt_outlined, () {
                                try {
                                  _resetTimer();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Failed : ${e.toString()}")));
                                }
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildIconButton(Icons.flash_on, () {
                          try {
                            connection!.output.add(Uint8List.fromList([(97)]));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Failed : ${e.toString()}")));
                          }
                        }),
                        const SizedBox(
                          width: 30,
                        ),
                        _buildIconButton(Icons.reset_tv, () {
                          try {
                            connection!.output.add(Uint8List.fromList([(99)]));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Failed : ${e.toString()}")));
                          }
                        }),
                        const SizedBox(
                          width: 30,
                        ),
                        _buildIconButton(Icons.score, () {
                          try {
                            connection!.output.add(Uint8List.fromList([(117)]));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Failed : ${e.toString()}")));
                          }
                        })
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (_textController.text == "") {
                              changingTeam = 2;
                              _showText = true;
                              _showTextField = !_showTextField;
                            } else {
                              teamNames[2] = _textController.text;
                              _textController.clear();
                              _showTextField = false;
                            }
                          });
                        },
                        child: Text(
                          teamNames[2],
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 28,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamSection(int i) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (_textController.text == "") {
                changingTeam = i;
                _showText = true;
                _showTextField = !_showTextField;
              } else {
                teamNames[i] = _textController.text;
                _textController.clear();
                _showTextField = false;
              }
            });
          },
          child: Text(
            teamNames[i],
            style: const TextStyle(
              color: Colors.green,
              fontSize: 28,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                "Score",
                style: TextStyle(
                  color: Colors.white, // Set the color to white for contrast
                  fontSize: 28,
                  fontFamily: 'Helvetica Neue', // Use Helvetica Neue or Arial
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50,
                  child: StepperTouch(
                      initialValue: 0,
                      withSpring: true,
                      onChanged: (int? value) {
                        try {
                          int plusOrMinus = scoreValue[i] - (value ?? 0);

                          bool isMinus = plusOrMinus == 1;

                          connection!.output.add(Uint8List.fromList(
                              [(isMinus ? 66 : 65) + (i * 2)]));
                          scoreValue[i] =
                              scoreValue[i] + (isMinus == true ? -1 : 1);

                          setState(() {});
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Failed : ${e.toString()}")));
                        }
                      }),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: Colors
              .grey[700], // You can adjust the color here to your preference
        ),
        if (global.winSet)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 65,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StepperTouch(
                    initialValue: 0,
                    withSpring: true,
                    onChanged: (int? value) {
                      try {
                        int plusOrMinus = winningSet[i] - (value ?? 0);

                        bool isMinus = plusOrMinus == 1;
                        connection!.output.add(Uint8List.fromList(
                            [(isMinus ? 70 : 69) + (i * 2)]));
                        winningSet[i] =
                            winningSet[i] + (isMinus == true ? -1 : 1);

                        setState(() {});
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Failed : ${e.toString()}")));
                      }
                    },
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(18.0),
                child: Text(
                  "Winning Set",
                  style: TextStyle(
                    color:
                        Colors.redAccent, // Set the color to white for contrast
                    fontSize: 28,
                    fontFamily: 'Helvetica Neue', // Use Helvetica Neue or Arial
                  ),
                ),
              ),
            ],
          ),
        if (global.foul)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 65,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StepperTouch(
                    initialValue: 0,
                    withSpring: true,
                    onChanged: (int? value) {
                      try {
                        int plusOrMinus = foul[i] - (value ?? 0);

                        bool isMinus = plusOrMinus == 1;
                        connection!.output.add(Uint8List.fromList(
                            [(isMinus ? 102 : 104) + (i * 2)]));
                        foul[i] = foul[i] + (isMinus == true ? -1 : 1);

                        setState(() {});
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Failed : ${e.toString()}")));
                      }
                    },
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(18.0),
                child: Text(
                  "Foul",
                  style: TextStyle(
                    color:
                        Colors.redAccent, // Set the color to white for contrast
                    fontSize: 28,
                    fontFamily: 'Helvetica Neue', // Use Helvetica Neue or Arial
                  ),
                ),
              ),
            ],
          ),
        if (global.foul)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(18.0),
                child: Text(
                  "Timeout",
                  style: TextStyle(
                    color:
                        Colors.redAccent, // Set the color to white for contrast
                    fontSize: 28,
                    fontFamily: 'Helvetica Neue', // Use Helvetica Neue or Arial
                  ),
                ),
              ),
              SizedBox(
                height: 65,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StepperTouch(
                    initialValue: 1,
                    withSpring: true,
                    onChanged: (int? value) {
                      try {
                        int plusOrMinus = timeout[i] - (value ?? 0);

                        bool isMinus = plusOrMinus == 1;
                        connection!.output.add(Uint8List.fromList(
                            [(isMinus ? 49 : 51) + (i * 2)]));
                        timeout[i] = timeout[i] + (isMinus == true ? -1 : 1);

                        setState(() {});
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Failed : ${e.toString()}")));
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
        elevation: 4,
      ),
      child: Icon(icon, size: 25, color: Colors.green),
    );
  }
}
