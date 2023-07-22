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
        SwipeCardSwitch(
          p: v,
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
