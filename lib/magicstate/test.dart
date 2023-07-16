import 'package:ble_street_lights/magicstate/magicstate.dart';
import 'package:flutter/material.dart';

class Test extends StatefulWidget {

  Test() {

  }
  @override
  State<StatefulWidget> createState() =>_TestState();
}

class _TestState extends MagicState<Test> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text("data");
  }
}