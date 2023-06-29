import 'package:ble_street_lights/components/bottomnavigator/bottomnavigator.dart';
import 'package:flutter/material.dart';

class DeviceScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MyESP32"),
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(height: 50,),
          BottomNavigator(labels: [
            ["Home", Icons.home, Colors.blue.shade200],
            ["Settings", Icons.settings, Colors.red.shade200],
            ["Meter", Icons.energy_savings_leaf, Colors.green.shade200],
            ["Logs", Icons.list_alt, Colors.yellow.shade200],
          ],),
        ],
      ),
    );
  }
}
