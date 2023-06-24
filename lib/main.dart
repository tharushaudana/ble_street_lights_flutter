import 'package:ble_street_lights/screens/home/home.dart';
import 'package:ble_street_lights/screens/splash.dart';
import 'package:ble_street_lights/screens/scan/scan.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Street Lights',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: SplashScreen(),
      home: ScanScreen(),
      routes: {
        '/home': (context) => HomeScreen(title: "title")
      },
      /*onGenerateRoute: (settings) {
        
      },*/
    );
  }
}
