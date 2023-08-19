import 'dart:convert';
import 'package:ble_street_lights/components/hideanimatedlistitem/hideanimatedlistitem.dart';
import 'package:ble_street_lights/helpers/bluetooth.dart';
import 'package:ble_street_lights/helpers/location.dart';
import 'package:ble_street_lights/screens/device/device.dart';
import 'package:ble_street_lights/screens/home/widgets/devicecard.dart';
import 'package:ble_street_lights/screens/scan/scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title,});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SharedPreferences sharedPrefs;

  BluetoothHelper bluetooth = BluetoothHelper();
  LocationHelper location = LocationHelper();

  List devices = [
    //["Test Device 01", "BE:AC:10:00:00:01", -54],
    //["Test Device 02", "BE:AC:10:00:00:02", -68],
    //["Test Device 03", "BE:AC:10:00:00:03", -75],
    //["Test Device 04"],
    //["Test Device 05"],
  ];

  List availableDeviceIds = [];
  List selectedDeviceIds = [];
  List deletedDeviceIds = [];

  bool isInitialized = false;
  bool isPulledForRefresh = false;

  //bool isScanning = false;

  initSharedPrefs() async {
    sharedPrefs = await SharedPreferences.getInstance();

    if (sharedPrefs.containsKey("devices")) {
      String json = (await sharedPrefs.getString("devices")) as String;

      setState(() {
        devices = jsonDecode(json);
        isInitialized = true;
      });
    }

    setState(() {
      isInitialized = true;
    });

    //devices.add(["Test Device 04", "BE:AC:10:00:00:06", -54]);
    //devices.add(["Test Device 05", "BE:AC:10:00:00:07", -54]);
    //devices.add(["Test Device 06", "BE:AC:10:00:00:08", -54]);

    if (devices.isNotEmpty) scanForDevices();
  }

  updateSharedPrefs() {
    sharedPrefs.setString("devices", jsonEncode(devices));
  }

  addDevice(List device) {
    if (devices.any((elem) => elem[1] == device[1])) return;

    setState(() {
      devices.add(device);
      availableDeviceIds.add(device[1]);
    });

    updateSharedPrefs();
  }

  openScanner() {
    if (bluetooth.isScanning) return;

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

  openDeviceScreen(int index) {
    //Navigator.pushNamed(context, "/device");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceScreen(
          deviceData: devices[index],
          didPop: () {
            scanForDevices();
          },
        ),
      ),
    );
  }

  scanForDevices() async {
    if (!await bluetooth.checkIsEnabled() || !await location.checkIsEnabled()) {
      showUnableToScanAlert();
      return;
    }

    await bluetooth.startScan(
      started: () {
        availableDeviceIds.clear();
      },
      stopped: () {},
    );
  }

  listenForBluetooth() {
    /*bluetooth.listenForScanStateChanges(
      started: () {
        availableDeviceIds.clear();
      },
      stopped: () {},
    );*/

    bluetooth.listenForScanResults((List<ScanResult> results) {
      for (ScanResult r in results) {
        updateDeviceDetails(r.device, r.rssi);
      }
    });
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
    setState(() {
      isPulledForRefresh = true;
    });

    await scanForDevices();

    setState(() {
      isPulledForRefresh = false;
    });
  }

  showUnableToScanAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(
            Icons.warning_rounded,
            size: 60,
            color: Colors.red.shade400,
          ),
          title: const Text(
            "Can't Refresh",
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          content: const Text(
            "Please enable Location & Bluetooth",
            style: TextStyle(fontFamily: 'Nunito'),
          ),
        );
      },
    );
  }

  deleteSelectedDevices() {
    for (List device in devices) {
      if (selectedDeviceIds.contains(device[1])) {
        setState(() {
          deletedDeviceIds.add(device[1]);
        });
      }
    }

    setState(() {
      selectedDeviceIds.clear();
    });

    deletePermenently();
  }

  deletePermenently() {
    for (int i = 0; i < devices.length; i++) {
      if (deletedDeviceIds.contains(devices[i][1])) {
        devices.removeAt(i);
      }
    }

    deletedDeviceIds.clear();

    updateSharedPrefs();
  }

  @override
  void initState() {
    super.initState();

    bluetooth.setStateClass(this);
    location.setStateClass(this);
    listenForBluetooth();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initSharedPrefs();
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Banner(
      message: "DEMO",
      location: BannerLocation.topEnd,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text("Smart Street Light Controller"),
              const Spacer(),
              selectedDeviceIds.isNotEmpty
                  ? Row(
                      children: [
                        Text("${selectedDeviceIds.length}")
                            .animate()
                            .fade(duration: 300.ms),
                        const SizedBox(width: 20),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              selectedDeviceIds.clear();
                            });
                          },
                          icon: const Icon(Icons.close),
                        ).animate().fade(duration: 300.ms),
                      ],
                    ) //.animate().scale(duration: 300.ms)
                  : Container(),
            ],
          ),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(
                bluetooth.isScanning && !isPulledForRefresh ? 6.0 : 0),
            child: bluetooth.isScanning && !isPulledForRefresh
                ? LinearProgressIndicator(
                    color: Colors.blue.shade400,
                  )
                : Container(),
          ),
        ),
        body: devices.isNotEmpty && devices.length != deletedDeviceIds.length
            ? LiquidPullToRefresh(
                onRefresh: onRefreshList,
                showChildOpacityTransition: false,
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, i) {
                      return HideAnimatedListItem(
                        hidden: deletedDeviceIds.contains(devices[i][1]),
                        child: DeviceCard(
                          name: devices[i][0],
                          address: devices[i][1],
                          rssi: devices[i][2],
                          available: isDeviceAvailable(devices[i][1]),
                          ischecking: bluetooth.isScanning &&
                              !isDeviceAvailable(devices[i][1]),
                          selectOnTap: selectedDeviceIds.isNotEmpty,
                          selected: selectedDeviceIds.contains(devices[i][1]),
                          onTap: () {
                            openDeviceScreen(i);
                          },
                          onSelect: () {
                            if (!selectedDeviceIds.contains(devices[i][1])) {
                              setState(() {
                                selectedDeviceIds.add(devices[i][1]);
                              });
                            }
                          },
                          onUnselect: () {
                            if (selectedDeviceIds.contains(devices[i][1])) {
                              setState(() {
                                selectedDeviceIds.remove(devices[i][1]);
                              });
                            }
                          },
                        )
                            .animate()
                            .fade(duration: 300.ms, delay: (100 * (i + 1)).ms)
                            .moveX(duration: 300.ms, delay: (100 * (i + 1)).ms),
                      );
                    },
                  ),
                ),
              )
            : isInitialized
                ? Center(
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
                  )
                : Container(),
        floatingActionButton: bluetooth.isScanning
            ? null
            : selectedDeviceIds.isEmpty
                ? FloatingActionButton(
                    onPressed: () => openScanner(),
                    //onPressed: () => throw Exception("Test exception."),
                    tooltip: 'Scan',
                    child: const Icon(Icons.radar),
                  ).animate().scale(duration: 300.ms)
                : FloatingActionButton(
                    onPressed: () => deleteSelectedDevices(),
                    tooltip: 'Delete',
                    backgroundColor: Colors.red,
                    child: const Icon(
                      Icons.delete,
                    ),
                  ).animate().scale(duration: 300.ms, delay: 500.ms),
      ),
    );
    //.animate().move(duration: 200.ms);
  }

  @override
  void dispose() {
    bluetooth.dispose();
    location.dispose();
    super.dispose();
  }
}
