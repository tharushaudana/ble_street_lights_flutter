import 'dart:async';
import 'dart:developer';
import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:ble_street_lights/bledevice/request.dart';
import 'package:ble_street_lights/components/celluarbar/celluarbar.dart';
import 'package:ble_street_lights/components/wastyleappbar/wastyleappbar.dart';
import 'package:ble_street_lights/screens/device/screens/profile/locationviewer.dart';
import 'package:ble_street_lights/screens/device/screens/profile/syncdialog.dart';
import 'package:ble_street_lights/time/time.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class DeviceProfileScreen extends StatefulWidget {
  const DeviceProfileScreen({super.key, required this.deviceData});

  final List deviceData;

  @override
  State<StatefulWidget> createState() => _DeviceProfileScreenState();
}

class _DeviceProfileScreenState extends State<DeviceProfileScreen> {
  late Timer timerSystemTimeUpdate;

  String systemTimeStr = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      timerSystemTimeUpdate = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          setState(() {
            systemTimeStr = Time.dateTimeToString(Time.now());
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BLEDeviceConnectionProvider>(
      builder: (
        context,
        provider,
        _,
      ) {
        bool isConnected = provider.deviceData.isConnected;
        Map? currentValues = provider.deviceData.currentValues;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              WaStyleAppBar(
                title: Text(widget.deviceData[0]),
                extendHeight: 125,
                extendedScale: 1.1,
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
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Column(
                    children: [
                      Table(
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
                            detail: Text(
                              isConnected ? "Connected" : "Disconnected",
                              style: TextStyle(
                                color: isConnected ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _TableRowDeviceDetail(
                            title: "RTC",
                            detail: Text(
                              currentValues?['t'] ?? "...",
                              style: TextStyle(
                                color: Colors.amber[900],
                              ),
                            ),
                          ),
                          _TableRowDeviceDetail(
                            title: "System Time",
                            detail: Text(systemTimeStr),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          FilledButton(
                            onPressed: () {
                              DateTime now = Time.now();

                              BLEDeviceRequest request = BLEDeviceRequest('set')
                                ..subject('rtc')
                                ..data(
                                  {
                                    's': now.second,
                                    'm': now.minute,
                                    'h': now.hour,
                                    'w': now.weekday,
                                    'd': now.day,
                                    'n': now.month,
                                    'y': int.parse(now.year.toString().substring(1)),
                                  },
                                );

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => DeviceSyncDialog(
                                  title: "Syncing time to RTC...",
                                  doSync: (dialog) {
                                    request.listen(
                                      onSuccess: (_) => dialog.completed(),
                                      onTimeOut: () => dialog.timeout(),
                                    );
                                    provider.makeRequest(request);
                                  },
                                ),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.watch_later_rounded),
                                SizedBox(width: 5),
                                Text("SYNC TIME"),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {},
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_on_rounded),
                                  SizedBox(width: 5),
                                  Text("SYNC LOCATION"),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(
                            top: 10,
                            bottom: 15,
                          ),
                          child: DeviceLocationViewer(
                            isPreview: true,
                            deviceName: widget.deviceData[0],
                            position: LatLng(
                              37.42796133580664,
                              -122.085749655962,
                            ),
                            onEditClick: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DeviceLocationViewer(
                                    deviceName: widget.deviceData[0],
                                    position: LatLng(
                                      37.42796133580664,
                                      -122.085749655962,
                                    ),
                                    onEditClick: () {},
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    timerSystemTimeUpdate.cancel();
    super.dispose();
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
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            alignment: Alignment.centerLeft,
            height: 40,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Nunito',
                //color: Colors.blueAccent,
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
