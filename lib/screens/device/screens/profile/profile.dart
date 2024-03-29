import 'dart:async';
import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:ble_street_lights/bledevice/request.dart';
import 'package:ble_street_lights/components/celluarbar/celluarbar.dart';
import 'package:ble_street_lights/components/wastyleappbar/wastyleappbar.dart';
import 'package:ble_street_lights/screens/device/devicesyncer.dart';
import 'package:ble_street_lights/screens/device/screens/profile/locationviewer.dart';
import 'package:ble_street_lights/screens/device/dialogs/syncdialog.dart';
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
          zoom: 18,
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
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    //### for remove unwanted space
                    border: Border.all(
                      width: 0,
                      color: Colors.blue,
                    ),
                  ),
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
                              columnWidths: const {
                                0: FlexColumnWidth(1),
                                1: FlexColumnWidth(2),
                              },
                              children: [
                                _TableRowDeviceDetail(
                                  title: "BLE Signal",
                                  detail: isConnected
                                      ? Stack(
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
                                              margin: const EdgeInsets.only(
                                                  top: 10),
                                              width: 40,
                                              height: 38,
                                              alignment: Alignment.centerRight,
                                              child: CelluarBar(
                                                width: 27,
                                                rssi: widget.deviceData[2],
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Icon(
                                          Icons.signal_cellular_off_rounded,
                                          size: 30,
                                          color: Colors.red,
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
                                SizedBox(
                                  height: 35,
                                  child: FilledButton(
                                    onPressed: () {
                                      DateTime now = Time.now();
                                
                                      showDeviceSyncDialog(
                                        context: context,
                                        provider: provider,
                                        action: "set",
                                        subject: "rtc",
                                        data: {
                                          's': now.second,
                                          'm': now.minute,
                                          'h': now.hour,
                                          'w': now.weekday,
                                          'd': now.day,
                                          'n': now.month,
                                          'y': int.parse(
                                              now.year.toString().substring(1)),
                                        },
                                        initialText: "Syncing time to RTC...",
                                        closeOnSuccess: false,
                                        doSync: (
                                          dialogController,
                                          sendNow,
                                        ) {
                                          sendNow();
                                        },
                                      );
                                    },
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.watch_later_rounded, size: 20,),
                                        SizedBox(width: 5),
                                        Text(
                                          "SYNC TIME",
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SizedBox(
                                    height: 35,
                                    child: FilledButton(
                                      onPressed: () async {
                                        LatLng? cpos;
                                    
                                        bool b = await showDeviceSyncDialog(
                                          context: context,
                                          provider: provider,
                                          action: "set",
                                          subject: "loc",
                                          initialText: "Getting Location...",
                                          closeOnSuccess: false,
                                          doSync: (
                                            dialogController,
                                            sendNow,
                                          ) async {
                                            cpos = await getCurrentLocation();
                                    
                                            if (cpos == null) {
                                              dialogController.failed();
                                              dialogController
                                                  .changeTitle("Failed to Get!");
                                              return;
                                            }
                                    
                                            Future.delayed(
                                                const Duration(seconds: 2), () {
                                              dialogController.changeTitle(
                                                  "Syncing Location...");
                                              sendNow(d: {
                                                't': cpos!.latitude,
                                                'n': cpos!.longitude,
                                              });
                                            });
                                          },
                                        );
                                    
                                        if (b) {
                                          updateDeviceLocationInMap(cpos!);
                                        }
                                      },
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(Icons.location_on_rounded, size: 20,),
                                          SizedBox(width: 5),
                                          Text(
                                            "SYNC LOCATION",
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
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
              style: const TextStyle(
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
        left: 8,
        right: 8,
        bottom: activeBottomMargin ? 10 : 0,
      ),
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            offset: const Offset(0, 1.5),
            blurRadius: 2,
            //spreadRadius: 2,
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
