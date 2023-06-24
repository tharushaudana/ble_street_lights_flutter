import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  openHomeScreen() {
    Navigator.popAndPushNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(),
            const Spacer(),
            Container(
              width: 200,
              height: 200,
              child: const Image(image: AssetImage("assets/images/logo.png")),
            )
                .animate(
                  onComplete: (controller) => openHomeScreen(),
                )
                .fade(duration: 500.ms)
                .move(duration: 600.ms)
                //.shimmer(delay: 1500.ms, duration: 400.ms)
                .fadeOut(delay: 2500.ms, duration: 200.ms),
            const Spacer(),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  const Text(
                    "BLE APP",
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'LexendPeta',
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  )
                      .animate()
                      .fade(duration: 500.ms)
                      .shimmer(delay: 1500.ms, duration: 400.ms, color: Colors.blue)
                      .fadeOut(delay: 2500.ms, duration: 200.ms),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    "version 1.0",
                    style: TextStyle(color: Colors.grey),
                  )
                      .animate()
                      .fade(duration: 500.ms)
                      .fadeOut(delay: 2500.ms, duration: 200.ms)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
