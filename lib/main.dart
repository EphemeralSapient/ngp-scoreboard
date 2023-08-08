import 'dart:async';
import 'dart:typed_data';
import 'package:control_app/led.dart';
import 'package:control_app/login.dart';
import 'package:control_app/options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';

bool askedOnce = false;
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Function to define the fade-in and zoom-in animation for the route transition
  PageRouteBuilder _fadeZoomTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(seconds: 1),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        final curve =
            Curves.ease; // You can choose a different easing curve if needed

        // Fade animation
        final fadeTween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final fadeAnimation = animation.drive(fadeTween);

        // Zoom animation
        final zoomTween =
            Tween(begin: 0.8, end: 1.0).chain(CurveTween(curve: curve));
        final zoomAnimation = animation.drive(zoomTween);

        return ScaleTransition(
          scale: zoomAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/splash",
      routes: {
        "/splash": (context) => MyHomePage(),
        "/login": (context) => LoginPage(),
        "/options": (context) => Options(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 2),
        () => Navigator.pushReplacement(
            context,
            PageRouteBuilder(
                pageBuilder: (c, a1, a2) => LoginPage(),
                transitionsBuilder: (context, animation, secondaryAnimation,
                        child) =>
                    FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                            scale: animation.drive(Tween(begin: 1.5, end: 1.0)
                                .chain(CurveTween(curve: Curves.easeOutCubic))),
                            child: child)),
                transitionDuration: const Duration(seconds: 1))));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Image.asset(
          'assets/logo.png',
          height: MediaQuery.of(context).size.height *
              0.23, // You can adjust the height as needed
          fit: BoxFit
              .contain, // Choose the appropriate BoxFit based on how you want the image to fit
        ),
      ),
    );
  }
}
