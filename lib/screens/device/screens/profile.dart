import 'dart:developer';
import 'package:ble_street_lights/components/celluarbar/celluarbar.dart';
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
            extendHeight: 145,
            extendedScale: 1.5,
            logoChild: const Hero(
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.deviceData[1],
                    style: const TextStyle(
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
              child: _ContentCard(
                child: Table(
                  children: [
                    _TableRowDeviceDetail(
                      title: "BLE Signal",
                      detail: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            width: 33,
                            height: 15,
                            alignment: Alignment.centerRight,
                            child: Text(
                              "${widget.deviceData[2]} dBm",
                              style: const TextStyle(
                                fontSize: 7,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            width: 40,
                            height: 38,
                            alignment: Alignment.centerRight,
                            child: CelluarBar(
                              width: 27,
                              rssi: widget.deviceData[2],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _TableRowDeviceDetail(
                      title: "Device Status",
                      detail: Text("Connected"),
                    ),
                    _TableRowDeviceDetail(
                      title: "RTC",
                      detail: Text("......."),
                    ),
                    _TableRowDeviceDetail(
                      title: "System Time",
                      detail: Text("......."),
                    ),
                  ],
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

class _TableRowDeviceDetail extends TableRow {
  const _TableRowDeviceDetail({
    super.key,
    required this.title,
    required this.detail,
  });

  final String title;
  final Widget detail;

  @override
  List<Widget> get children => [
        TableCell(
          child: Container(
            alignment: Alignment.centerLeft,
            height: 60,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Nunito',
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Row(
            children: [
              const Spacer(),
              detail,
            ],
          ),
        ),
      ];
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: Colors.blue.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            offset: const Offset(1, 1),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Theme.of(context).scaffoldBackgroundColor,
            offset: const Offset(-4, -4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}
