import 'dart:async';
import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:ble_street_lights/bledevice/request.dart';
import 'package:ble_street_lights/components/celluarbar/celluarbar.dart';
import 'package:ble_street_lights/components/wastyleappbar/wastyleappbar.dart';
import 'package:ble_street_lights/screens/device/screens/profile/locationviewer.dart';
import 'package:ble_street_lights/screens/device/screens/dialogs/syncdialog.dart';
import 'package:ble_street_lights/time/time.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

class DeviceProfileScreen extends StatefulWidget {
  const DeviceProfileScreen({super.key, required this.deviceData});

  final List deviceData;

  @override
  State<StatefulWidget> createState() => _DeviceProfileScreenState();
}

class _DeviceProfileScreenState extends State<DeviceProfileScreen> {
  late Timer timerSystemTimeUpdate;

  GoogleMapController? mapController;

  bool shouldMoveCameraWhenInitialized = false;

  String systemTimeStr = "";

  LatLng position = const LatLng(0, 0);

  Future<LatLng?> getCurrentLocation() async {
    await Geolocator.requestPermission();

    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      return null;
    }
  }

  updateDeviceLocationInMap(LatLng newPosition) {
    setState(() {
      position = newPosition;
    });
    moveCameraToCurrentPosition();
  }

  moveCameraToCurrentPosition() {
    if (mapController == null) {
      shouldMoveCameraWhenInitialized = true;
      return;
    }

    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 14.5,
        ),
      ),
    );
  }

  parseToDouble(dynamic value) {
    return double.tryParse(value.toString());
  }

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

        //### update device location
        if (currentValues != null) {
          try {
            double lat = parseToDouble(currentValues['l']['t']);
            double lng = parseToDouble(currentValues['l']['n']);
            if (lat != position.latitude || lng != position.longitude) {
              position = LatLng(lat, lng);
              moveCameraToCurrentPosition();
            }
          // ignore: empty_catches
          } catch (e) {}
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              WaStyleAppBar(
                title: Text(widget.deviceData[0]),
                //extendHeight: 125,
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
                  //margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Column(
                    children: [
                      _ContentCard(
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
                                      color: isConnected
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _TableRowDeviceDetail(
                                  title: "RTC",
                                  detail: Text(
                                    currentValues?['t'] ?? "[Not Received Yet]",
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
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                FilledButton(
                                  onPressed: () {
                                    DateTime now = Time.now();

                                    BLEDeviceRequest request = BLEDeviceRequest(
                                        'set')
                                      ..subject('rtc')
                                      ..data(
                                        {
                                          's': now.second,
                                          'm': now.minute,
                                          'h': now.hour,
                                          'w': now.weekday,
                                          'd': now.day,
                                          'n': now.month,
                                          'y': int.parse(
                                              now.year.toString().substring(1)),
                                        },
                                      );

                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => DeviceSyncDialog(
                                        title: "Syncing time to RTC...",
                                        doSync: (dialog) {
                                          request.listen(
                                            onSuccess: (_) {
                                              dialog.completed();
                                              dialog.changeTitle(
                                                  "Sync Completed.");
                                            },
                                            onTimeOut: () {
                                              dialog.failed();
                                              dialog
                                                  .changeTitle("Sync Failed!");
                                            },
                                          );
                                          provider.makeRequest(request);
                                        },
                                      ),
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => DeviceSyncDialog(
                                          title: "Getting Location...",
                                          doSync: (dialog) async {
                                            LatLng? cpos =
                                                await getCurrentLocation();

                                            if (cpos == null) {
                                              dialog.failed();
                                              dialog.changeTitle(
                                                  "Failed to Get!");
                                              return;
                                            }

                                            dialog.changeTitle(
                                                "Syncing Location...");

                                            Future.delayed(
                                              const Duration(seconds: 2),
                                              () {
                                                BLEDeviceRequest request =
                                                    BLEDeviceRequest('set')
                                                      ..subject('loc')
                                                      ..data(
                                                        {
                                                          't': cpos.latitude,
                                                          'n': cpos.longitude,
                                                        },
                                                      );

                                                request.listen(
                                                  onSuccess: (_) {
                                                    dialog.completed();
                                                    dialog.changeTitle(
                                                        "Sync Completed.");
                                                    updateDeviceLocationInMap(
                                                        cpos);
                                                  },
                                                  onTimeOut: () {
                                                    dialog.failed();
                                                    dialog.changeTitle(
                                                        "Sync Failed!");
                                                  },
                                                );
                                                provider.makeRequest(request);
                                              },
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                          ],
                        ),
                      ),
                      Expanded(
                        child: _ContentCard(
                          /*margin: const EdgeInsets.only(
                            top: 0,
                            bottom: 15,
                          ),*/
                          padding: const EdgeInsets.all(0),
                          activeBottomMargin: true,
                          child: DeviceLocationViewer(
                            isPreview: true,
                            deviceName: widget.deviceData[0],
                            position: position,
                            onFullscreenClick: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DeviceLocationViewer(
                                    deviceName: widget.deviceData[0],
                                    position: position,
                                    onFullscreenClick: () {},
                                    onCreated: (controller) {},
                                  ),
                                ),
                              );
                            },
                            onCreated: (controller) {
                              mapController = controller;

                              if (shouldMoveCameraWhenInitialized) {
                                moveCameraToCurrentPosition();
                                shouldMoveCameraWhenInitialized = false;
                              }
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
    this.padding = const EdgeInsets.symmetric(
      horizontal: 15,
      vertical: 10,
    ),
    this.activeBottomMargin = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool activeBottomMargin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 10,
        bottom: activeBottomMargin ? 10 : 0,
      ),
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, 1),
            blurRadius: 3,
            //spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}
