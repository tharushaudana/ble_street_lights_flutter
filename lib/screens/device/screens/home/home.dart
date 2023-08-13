import 'dart:developer';
import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:ble_street_lights/components/swipecardswitch/swipecardswitch.dart';
import 'package:ble_street_lights/screens/device/screens/home/syncbtn.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class DeviceHomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DeviceHomeScreenState();
}

class _DeviceHomeScreenState extends State<DeviceHomeScreen>
    with AutomaticKeepAliveClientMixin<DeviceHomeScreen> {
  Map settingsData = {
    "mode": "manual",
  };

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<BLEDeviceConnectionProvider>(
      builder: (
        context,
        provider,
        _,
      ) {
        return SizedBox(
          height: double.infinity,
          child: Stack(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue.shade300,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.model_training_rounded,
                              size: 30,
                              color: Colors.blue.shade300,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Device Mode",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Text("Manual"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Container(
                      height: 45,
                      width: 55,
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            offset: const Offset(0, 1),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: SyncButton(
                        provider: provider,
                        action: "set",
                        subject: "hm",
                        onStartSync: () {
                          return {"m": 1};
                        },
                        onResult: (completed) {},
                      ),
                      /*SpinKitThreeBounce(
                      color: Colors.blue,
                      size: 15,
                    ),*/
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
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
