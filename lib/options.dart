import 'package:control_app/led.dart';
import 'package:control_app/main.dart';
import 'package:flutter/material.dart';

class Options extends StatelessWidget {
  final List<String> eventNames = [
    "Football",
    "Basketball",
    "Tennis",
    "Volleyball",
    "Cricket",
    "Hockey",
    "Throwball",
    "Kho Kho"
  ];

  final List<String> imagePaths = [
    "assets/football.jpg",
    "assets/basketball.jpg",
    "assets/tennis.webp",
    "assets/volleyball.jpg",
    "assets/cricket.jpg",
    "assets/hockey.jpg",
    "assets/throwball.jpg",
    "assets/kho.jpg"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Choose the sports event")),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (int index = 0; index < eventNames.length; index++)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SportsEventButton(
                  eventName: eventNames[index],
                  imagePath: imagePaths[index],
                ),
              ),
            SizedBox(
              height: 150,
            )
          ],
        ),
      ),
    );
  }
}

class SportsEventButton extends StatelessWidget {
  final String eventName;
  final String imagePath;

  SportsEventButton({required this.eventName, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor:
            Colors.transparent, // You can change the button color here
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (c, a1, a2) => Led(),
              transitionsBuilder: (context, animation, secondaryAnimation,
                      child) =>
                  FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                          scale: animation.drive(Tween(begin: 1.5, end: 1.0)
                              .chain(CurveTween(curve: Curves.easeOutCubic))),
                          child: child)),
              transitionDuration: const Duration(milliseconds: 300)),
        );
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Text(
                eventName,
                style: TextStyle(
                    color: Colors.white, // You can change the text color here
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.25),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
