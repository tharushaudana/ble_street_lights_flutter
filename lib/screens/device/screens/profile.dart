import 'dart:developer';
import 'package:ble_street_lights/components/wastyleappbar/wastyleappbar.dart';
import 'package:flutter/material.dart';

class DeviceProfileScreen extends StatefulWidget {
  const DeviceProfileScreen({super.key, required this.deviceData});

  final List deviceData;

  @override
  State<StatefulWidget> createState() => _DeviceProfileScreenState();
}

class _DeviceProfileScreenState extends State<DeviceProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          WaStyleAppBar(
            title: Text(widget.deviceData[0]),
            extendHeight: 160,
            logoChild: Hero(
              tag: 'img_profile',
              child: Image(
                image: AssetImage("assets/images/device_icon.png"),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.blue,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.deviceData[0],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                    Text(
                    widget.deviceData[1],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 400,
                  color: Colors.deepPurple[200],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 400,
                  color: Colors.deepPurple[200],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 400,
                  color: Colors.deepPurple[200],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
