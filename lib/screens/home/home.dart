import 'dart:developer';
import 'package:ble_street_lights/screens/scan/scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List devices = [
    //["Test Device 01"],
    //["Test Device 02"],
    //["Test Device 03"],
    //["Test Device 04"],
    //["Test Device 05"],
  ];

  openScanner() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) {
        return ScanScreen(
          onAddDeviceClicked: (List device) {
            setState(() {
              devices.add(device);
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 10),
        child: devices.isNotEmpty
            ? ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, i) {
                  return DeviceCard(name: devices[i][0])
                      .animate()
                      .fade(duration: 300.ms, delay: (100 * (i + 1)).ms)
                      .moveX(duration: 300.ms, delay: (100 * (i + 1)).ms);
                },
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.exposure_zero,
                      size: 150,
                      color: Colors.grey.withAlpha(100),
                    ),
                    Text(
                      "DEVICES",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openScanner(),
        tooltip: 'Scan',
        child: const Icon(Icons.radar),
      ),
    ).animate().move(duration: 200.ms);
  }
}

class DeviceCard extends StatefulWidget {
  DeviceCard({required this.name});

  final String name;

  @override
  State<StatefulWidget> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 22, horizontal: 18),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.grey.shade400, width: 1, style: BorderStyle.solid),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi,
            color: Colors.black,
            size: 30,
          ),
          SizedBox(
            width: 15,
          ),
          Text(
            widget.name,
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          )
        ],
      ),
    );
  }
}
