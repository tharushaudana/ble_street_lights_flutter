import 'dart:async';
import 'package:ble_street_lights/bledevice/bledevice.dart';
import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:ble_street_lights/components/bottomtabbarlayout/bottomtabbarlayout.dart';
import 'package:ble_street_lights/screens/device/dialogs/deviceconnectingdialog.dart';
import 'package:ble_street_lights/screens/device/screens/astro/astro.dart';
import 'package:ble_street_lights/screens/device/screens/home/home.dart';
import 'package:ble_street_lights/screens/device/screens/profile/profile.dart';
import 'package:ble_street_lights/screens/device/screens/settings/settings.dart';
import 'package:ble_street_lights/time/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({
    super.key,
    required this.deviceData,
    this.didPop,
  });

  final List deviceData;
  final VoidCallback? didPop;

  @override
  State<StatefulWidget> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen>
    with WidgetsBindingObserver {
  final autoCloseDuration = const Duration(minutes: 15);

  late TabController _tabController;
  late BLEDevice device;

  late Timer autoCloseTimer;

  bool isConnected = false;

  bool firstMsgReceived = false;

  DateTime lastSeenTime = Time.now();
  Timer? timerLastSeenUpdate;
  String lastSeenStr = "not connected yet";

  late DeviceConnectingDialog connectingDialog;

  late AstroScreenController _astroScreenController;

  openProfileScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => BLEDeviceConnectionProvider(device),
          child: DeviceProfileScreen(
            deviceData: widget.deviceData,
          ),
        ),
      ),
    );
  }

  openConnectingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return connectingDialog;
      },
    );
  }

  closeScreen() {
    Navigator.pop(context);
  }

  startAutoCloseTimer() {
    autoCloseTimer = Timer(autoCloseDuration, () {
      try {
        Navigator.pop(context);
      } catch (e) {}
    });
  }

  cancelAutoCloseTimer() {
    try {
      autoCloseTimer.cancel();
    } catch (e) {}
  }

  updateLastSeenText(String newText) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        lastSeenStr = newText;
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    /*if (state == AppLifecycleState.paused) {
      startAutoCloseTimer();
    } else if (state == AppLifecycleState.resumed) {
      cancelAutoCloseTimer();
    }*/
  }

  @override
  void initState() {
    //WidgetsBinding.instance.addObserver(this);

    device = BLEDevice(
      widget.deviceData[1],
      onConnected: () {
        setState(() {
          isConnected = true;
        });

        if (timerLastSeenUpdate != null && timerLastSeenUpdate!.isActive) {
          timerLastSeenUpdate!.cancel();
        }
      },
      onDisconnected: () {
        setState(() {
          isConnected = false;
        });

        updateLastSeenText("active recently");

        lastSeenTime = Time.now();

        timerLastSeenUpdate = Timer.periodic(
          const Duration(seconds: 30),
          (timer) {
            updateLastSeenText(
                "active ${Time.dateTimeToHumanDiff(lastSeenTime)}");
          },
        );
      },
      onMessage: (message) {
        //log(message.type.toString());
        //log(jsonEncode(message.data));
        if (!firstMsgReceived) {
          connectingDialog.close();
          firstMsgReceived = true;
        }
      },
      onWrongMessage: () {

      },
    );

    connectingDialog = DeviceConnectingDialog(device: device);

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        openConnectingDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_tabController.index == 0) return true;

        if (_tabController.index == 1 &&
            _astroScreenController.isSettingsOpened) {
          _astroScreenController.closeSettings();
        } else {
          _tabController.index = 0;
        }

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Hero(
                      tag: 'img_profile',
                      child: Image(
                        image: AssetImage("assets/images/device_icon.png"),
                        width: 40,
                        height: 40,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          openProfileScreen();
                        },
                        child: Container(
                          height: 56,
                          margin: const EdgeInsets.only(left: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.deviceData[0]),
                              const SizedBox(height: 3),
                              Text(
                                isConnected ? "online" : lastSeenStr,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_vert),
              ),
            ],
          ),
          //elevation: 0,
          titleSpacing: 0,
        ),
        body: BottomTabBarLayout(
          tabs: const [
            ["Home", Icons.home, Color(0xFF5B36B7)],
            ["Astro", Icons.wb_sunny_rounded, Color(0xFFC9379C)],
            ["Meter", Icons.energy_savings_leaf, Color(0xFFE6A91A)],
            ["Settings", Icons.settings_rounded, Color(0xFF1193A9)],
          ],
          onController: (controller) {
            _tabController = controller;
          },
          children: [
            ChangeNotifierProvider(
              create: (_) => BLEDeviceConnectionProvider(device),
              child: DeviceHomeScreen(),
            ),
            ChangeNotifierProvider(
              create: (_) => BLEDeviceConnectionProvider(device),
              child: AstroScreen(
                onController: (controller) {
                  _astroScreenController = controller;
                },
              ),
            ),
            const Center(
              child: Text(
                "Meter",
                style: TextStyle(fontSize: 30),
              ),
            ),
            ChangeNotifierProvider(
              create: (_) => BLEDeviceConnectionProvider(device),
              child: SettingsScreen(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    device.disconnect();
    device.dispose();

    if (timerLastSeenUpdate != null && timerLastSeenUpdate!.isActive) {
      timerLastSeenUpdate!.cancel();
    }

    if (widget.didPop != null) {
      widget.didPop!();
    }

    cancelAutoCloseTimer();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }
}
