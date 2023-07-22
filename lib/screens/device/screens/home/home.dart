import 'dart:developer';

import 'package:ble_street_lights/components/swipecardswitch/swipecardswitch.dart';
import 'package:flutter/material.dart';

class DeviceHomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DeviceHomeScreenState();
}

class _DeviceHomeScreenState extends State<DeviceHomeScreen> {
  double v = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        SwipeCardSwitch(
          color: Colors.blue,
          initialSwitchedChild: 2,
          onSwitching: (willSwitchingChild) {
            log("message: " + willSwitchingChild.toString());
            return true;
          },
          child1: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "ASTRO",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                ),
              ),
              Text(
                "MODE",
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
            ],
          ),
          child2: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "MANUAL",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                ),
              ),
              Text(
                "MODE",
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Slider(
          value: v,
          min: 0,
          max: 1,
          onChanged: (value) {
            setState(() {
              v = value;
            });
          },
        ),
      ],
    );
  }
}
