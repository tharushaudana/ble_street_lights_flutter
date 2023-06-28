import 'dart:convert';
import 'dart:developer';
import 'package:ble_street_lights/components/celluarbar/celluarbar.dart';
import 'package:ble_street_lights/screens/scan/scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SharedPreferences sharedPrefs;
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  List devices = [
    //["Test Device 01", "BE:AC:10:00:00:01", -54],
    //["Test Device 02", "BE:AC:10:00:00:02", -68],
    //["Test Device 03", "BE:AC:10:00:00:03", -75],
    //["Test Device 04"],
    //["Test Device 05"],
  ];

  List availableDeviceIds = [];

  bool isScanning = false;

  initSharedPrefs() async {
    sharedPrefs = await SharedPreferences.getInstance();

    if (!sharedPrefs.containsKey("devices")) return;

    String json = (await sharedPrefs.getString("devices")) as String;

    setState(() {
      devices = jsonDecode(json);
    });

    //devices.add(["Test Device 04", "BE:AC:10:00:00:06", -54]);

    if (devices.isNotEmpty) scanForDevices();
  }

  addDevice(List device) {
    if (devices.any((elem) => elem[1] == device[1])) return;

    setState(() {
      devices.add(device);
      availableDeviceIds.add(device[1]);
    });

    sharedPrefs.setString("devices", jsonEncode(devices));
  }

  openScanner() {
    if (isScanning) return;
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
            addDevice(device);
          },
        );
      },
    );
  }

  scanForDevices() async {
    try {
      availableDeviceIds.clear();

      flutterBlue.scanResults.listen((results) {
        for (ScanResult r in results) {
          updateDeviceDetails(r.device, r.rssi);
        }
      });

      setState(() {
        isScanning = true;
      });

      await flutterBlue
          .startScan(timeout: const Duration(seconds: 5))
          .then((value) {
        setState(() {
          isScanning = false;
        });
      });
    } catch (e) {}
  }

  updateDeviceDetails(BluetoothDevice device, int rssi) {
    if (!devices.any(
      (elem) {
        if (elem[1] == device.id.toString()) {
          setState(() {
            elem[2] = rssi;
          });
          return true;
        }
        return false;
      },
    )) return;

    if (!availableDeviceIds.contains(device.id)) {
      setState(() {
        availableDeviceIds.add(device.id.toString());
      });
    }
  }

  bool isDeviceAvailable(String id) {
    return availableDeviceIds.contains(id);
  }

  Future<void> onRefreshList() async {
    await scanForDevices();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initSharedPrefs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        elevation: 0,
      ),
      body: devices.isNotEmpty
          ? LiquidPullToRefresh(
              onRefresh: onRefreshList,
              showChildOpacityTransition: false,
              child: Container(
                margin: EdgeInsets.only(top: 10),
                child: ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, i) {
                    return DeviceCard(
                      name: devices[i][0],
                      address: devices[i][1],
                      rssi: devices[i][2],
                      available: isDeviceAvailable(devices[i][1]),
                      ischecking:
                          isScanning && !isDeviceAvailable(devices[i][1]),
                    )
                        .animate()
                        .fade(duration: 300.ms, delay: (100 * (i + 1)).ms)
                        .moveX(duration: 300.ms, delay: (100 * (i + 1)).ms);
                  },
                ),
              ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => openScanner(),
        tooltip: 'Scan',
        child: const Icon(Icons.radar),
      ),
    ).animate().move(duration: 200.ms);
  }
}

class DeviceCard extends StatefulWidget {
  const DeviceCard({
    super.key,
    required this.name,
    required this.address,
    required this.rssi,
    required this.available,
    required this.ischecking,
  });

  final String name;
  final String address;
  final int rssi;
  final bool available;
  final bool ischecking;

  @override
  State<StatefulWidget> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> with TickerProviderStateMixin {
  late AnimationController animationControllerShimmer;

  @override
  void initState() {
    animationControllerShimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 22, horizontal: 18),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      decoration: BoxDecoration(
        //border: Border.all(
        //    color: Colors.grey.shade400, width: 1, style: BorderStyle.solid),
        borderRadius: BorderRadius.all(Radius.circular(15)),
        //color: Colors.grey.shade300,
        //color: Theme.of(context).scaffoldBackgroundColor,
        color: Colors.blue.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            //color: Colors.grey.shade600,
            color: Colors.blue.withOpacity(0.2),
//            offset: Offset(4, 4),
            offset: Offset(1, 1),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          BoxShadow(
            //color: Colors.white,
            color: Theme.of(context).scaffoldBackgroundColor,
            offset: Offset(-4, -4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          //------------------------
          /*BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 30,
          ),
          BoxShadow(
            color: Color(0xFFA7A9AF),
            offset: Offset(15, 15),
            blurRadius: 30,
          ),*/
        ],
      ),
      child: Row(
        children: [
          const Image(
            image: AssetImage("assets/images/device_icon.png"),
            width: 48,
            height: 48,
          ),
          const SizedBox(
            width: 10,
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                widget.address,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 15),
          !widget.ischecking
              ? widget.available
                  ? Stack(
                      children: [
                        Container(
                          width: 33,
                          height: 15,
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${widget.rssi} dBm",
                            style: const TextStyle(
                              fontSize: 7,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 38,
                          alignment: Alignment.centerRight,
                          child: CelluarBar(
                            width: 27,
                            rssi: widget.rssi,
                          ),
                        ),
                      ],
                    )
                  : const Icon(
                      Icons.signal_cellular_off_rounded,
                      size: 32,
                      color: Colors.red,
                    )
              : const Icon(
                  Icons.signal_cellular_4_bar_rounded,
                  size: 32,
                  color: Colors.grey,
                )
                  .animate(
                    onPlay: (controller) => controller.repeat(),
                  )
                  .shimmer(duration: 600.ms, delay: 1000.ms),
        ],
      ),
    );
  }
}
