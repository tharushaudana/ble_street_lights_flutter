import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' as foundation;
import 'package:ble_street_lights/screens/home/home.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

/*void main() {
  runApp(const MyApp());
}*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  ui.PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  foundation.PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

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
      //home: ScanScreen(),
      home: HomeScreen(title: "BLE Street Lights"),
      //home: DeviceScreen(),
      routes: {
        '/home': (context) => HomeScreen(title: "title"),
        //'/device': (context) => DeviceScreen(),
      },
      /*onGenerateRoute: (settings) {
        
      },*/
    );
  }
}
