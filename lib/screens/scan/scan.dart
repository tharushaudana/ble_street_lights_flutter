import 'dart:developer';
import 'dart:async';
import 'package:ble_street_lights/helpers/bluetooth.dart';
import 'package:ble_street_lights/helpers/location.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:permission_handler/permission_handler.dart';
import 'package:ble_street_lights/screens/scan/scanner.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, required this.onAddDeviceClicked});

  final onAddDeviceClicked;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool isPermissionsGranted = false;
  bool isBluetoothLocationListenerTriggered = false;
  bool isBluetoothEnabled = false;
  bool isLocationEnabled = false;

  BluetoothHelper bluetooth = BluetoothHelper();
  LocationHelper location = LocationHelper();

  checkPermissionsStates() async {
    isPermissionsGranted = (await Permission.location.status.isGranted);
    return isPermissionsGranted;
  }

  grantPermissions() async {
    var statuses = await [
      Permission.location,
    ].request();

    if (statuses[Permission.location]!.isGranted) {
      setState(() {
        isPermissionsGranted = true;
      });
    }
  }

  checkIsBluetoothAndLocationEnabled() async {
    await bluetooth.checkIsEnabled();
    await location.checkIsEnabled();
    return bluetooth.isEnabled && location.isEnabled;
  }

  listenBluetoothAndLocationServiceStatus() {
    bluetooth.listenForServiceStatusChanges(null);
    location.listenForServiceStatusChanges(null);
  }

  @override
  void initState() {
    super.initState();
    bluetooth.setStateClass(this);
    location.setStateClass(this);
    listenBluetoothAndLocationServiceStatus();
  }

  @override
  void dispose() {
    bluetooth.dispose();
    location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text(
            "SCAN",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontFamily: 'LexendPeta',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          const Spacer(),
          FutureBuilder(
            future: checkPermissionsStates(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                bool isGranted = snapshot.data as bool;

                return isGranted
                    ? FutureBuilder(
                        future: checkIsBluetoothAndLocationEnabled(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.connectionState ==
                              ConnectionState.done) {
                            bool isEnabled = snapshot.data as bool;

                            return isEnabled
                                ? ScannerLayout(
                                    onAddDeviceClicked:
                                        widget.onAddDeviceClicked,
                                  )
                                : Column(
                                    children: [
                                      const Icon(
                                        Icons.signal_wifi_0_bar_sharp,
                                        size: 70,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Please enable Bluetooth & Location.',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                    ],
                                  );
                          }

                          return const Text("Unknown Error!");
                        })
                    : Column(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 70,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Location permission is required.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            style: ButtonStyle(
                              foregroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                            ),
                            onPressed: grantPermissions,
                            child: const Text('GRANT NOW'),
                          ),
                        ],
                      );
              }

              return const Text("Unknown Error!");
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class ScannerLayout extends StatefulWidget {
  const ScannerLayout({super.key, required this.onAddDeviceClicked});

  final onAddDeviceClicked;

  @override
  State<StatefulWidget> createState() => _ScannerLayoutState();
}

class _ScannerLayoutState extends State<ScannerLayout> {
  Future<ui.Image> loadDeviceIconImage() async {
    final completer = Completer<ui.Image>();
    final imageProvider = AssetImage("assets/images/device_icon.png");
    final config = ImageConfiguration(size: Size(3, 3));

    final stream = imageProvider.resolve(config);
    final listener = ImageStreamListener((imageInfo, synchronousCall) {
      final image = imageInfo.image;
      completer.complete(image);
    });

    stream.addListener(listener);

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: loadDeviceIconImage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.connectionState == ConnectionState.done) {
            ui.Image image = snapshot.data as ui.Image;
            return Scanner(
              deviceIcon: image,
              onAddDeviceClicked: widget.onAddDeviceClicked,
            );
          }

          return Text("Unknown Error!");
        },
      ),
    );
  }
}
