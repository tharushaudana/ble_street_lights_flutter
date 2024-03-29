import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:ble_street_lights/bledevice/request.dart';
import 'package:ble_street_lights/backupableitrs/bmap/bmap.dart';
import 'package:ble_street_lights/components/sliverpersistentheaderbuilder/sliverpersistentheaderbuilder.dart';
import 'package:ble_street_lights/components/neumorphismbutton/neumorphismbutton.dart';
import 'package:ble_street_lights/screens/device/devicesyncer.dart';
import 'package:ble_street_lights/screens/device/dialogs/syncdialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:provider/provider.dart';
import 'package:ble_street_lights/extensions/withopacitynotrans/colorwithopacitynotrans.dart';

class AstroScreen extends StatefulWidget {
  const AstroScreen({
    super.key,
    this.onController,
  });

  final Function(AstroScreenController)? onController;

  @override
  State<StatefulWidget> createState() => _AstroScreenState();
}

class _AstroScreenState extends State<AstroScreen> {
  late ScrollController _scrollController;
  late AstroScreenController _screenController;

  double _scrollPercentage = 0;
  double _shrinkPercentage = 0;

  late BMap settingsData;

  GlobalKey keyOfView = GlobalKey();
  double? viewHeight;

  Future<bool> syncSettings(
    BLEDeviceConnectionProvider provider,
    Map data, {
    bool closeOnSuccess = false,
  }) async {
    bool b = await showDeviceSyncDialog(
      context: context,
      provider: provider,
      action: "set",
      subject: "ast",
      data: data,
      closeOnSuccess: closeOnSuccess,
      doSync: (
        dialogController,
        sendNow,
      ) {
        sendNow();
      },
    );

    if (b) {
      settingsData.clearBackup();
    }

    return b;
  }

  Widget _valueBox(String title, String value, AssetImage iconImg) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(width: 1, color: Colors.blue)),
      ),
      child: Row(
        children: [
          /*Icon(
            Icons.calendar_month_rounded,
            color: Colors.grey.shade400,
            size: 30,
          ),*/
          Image(
            image: iconImg,
            width: 30,
            height: 30,
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _settingCard(
    Widget child, {
    border = false,
    shadow = true,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 6,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(1 - _shrinkPercentage),
          boxShadow: shadow
              ? [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    offset: const Offset(0, 1.5),
                    blurRadius: 2,
                    //spreadRadius: 2,
                  ),
                ]
              : [],
          border: border && _shrinkPercentage < 0.1
              ? Border.all(
                  width: _shrinkPercentage > 0.1
                      ? 0
                      : (0.1 - _shrinkPercentage) / 0.1,
                  color: Colors.blue,
                )
              : null,
          borderRadius: BorderRadius.circular(20)),
      child: Opacity(
        opacity: _shrinkPercentage > 0.1 ? 0 : (0.1 - _shrinkPercentage) / 0.1,
        child: child,
      ),
    );
  }

  _setShrinkPercentage(double p) {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (_shrinkPercentage == p) return;

        setState(() {
          _shrinkPercentage = p;
        });
      },
    );
  }

  _autoScrollTo(double pos) {
    Future.delayed(Duration.zero, () {
      _scrollController.animateTo(
        pos,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  _openSettings() {
    _autoScrollTo(_scrollController.position.maxScrollExtent);
  }

  _closeSettings() {
    _autoScrollTo(0);
  }

  bool _isDayTimeNow(String sunriseAt, String sunsetAt) {
    if (sunriseAt == "N/A" || sunsetAt == "N/A") return true;

    TimeOfDay now = TimeOfDay.now();
    TimeOfDay start = _strToTimeOfDay(sunriseAt);
    TimeOfDay end = _strToTimeOfDay(sunsetAt);

    int nowMinutes = now.hour * 60 + now.minute;
    int startMinutes = start.hour * 60 + start.minute;
    int endMinutes = end.hour * 60 + end.minute;

    return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
  }

  TimeOfDay _strToTimeOfDay(String s) {
    // 6:05 AM
    List a1 = s.split(" ");
    List a2 = a1[0].split(":");
    int hplus = a1[1] == "PM" ? 12 : 0;

    return TimeOfDay(
      hour: int.parse(a2[0]) + hplus,
      minute: int.parse(a2[1]),
    );
  }

  _setViewHeight() {
    try {
      RenderBox box = keyOfView.currentContext!.findRenderObject() as RenderBox;
      viewHeight = box.size.height;
    } catch (e) {
    }
  }

  @override
  void initState() {
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      _scrollPercentage = (_scrollController.offset /
              _scrollController.position.maxScrollExtent)
          .clamp(0.0, 1.0);

      if (_scrollPercentage == 0.0) {
        _screenController.isSettingsOpened = false;
        settingsData.restoreBackup();
      } else {
        _screenController.isSettingsOpened = true;
      }
    });

    _screenController = AstroScreenController(
      shouldCloseSettings: () {
        _closeSettings();
      },
    );

    if (widget.onController != null) {
      widget.onController!(_screenController);
    }

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    settingsData.restoreBackup();
    super.dispose();
  }

  bool isSettingsLoaded = false;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _setViewHeight();
    });

    final Size size = MediaQuery.of(context).size;

    const double iconImgSize = 85;
    const double iconImgMargin = 10;

    const double maxCurveRadius = 25;
    const double maxMargin = 7;

    return Consumer<BLEDeviceConnectionProvider>(builder: (
      context,
      provider,
      _,
    ) {
      if (!isSettingsLoaded) {
        provider.deviceData.loadSettingsData('astrotab', (data, success) {
          settingsData = data;
          isSettingsLoaded = success;
        });
      }

      String sunriseAt = provider.deviceData.currentValue("s.f", "N/A");
      String sunsetAt = provider.deviceData.currentValue("s.n", "N/A");
      String ofsunriseAt = provider.deviceData.currentValue("o.f", "N/A");
      String ofsunsetAt = provider.deviceData.currentValue("o.n", "N/A");

      bool isDayTime = _isDayTimeNow(sunriseAt, sunsetAt);

      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            if (_scrollPercentage == 0.0 || _scrollPercentage == 1.0) {
              return false;
            }

            if (_scrollPercentage < 0.5) {
              _closeSettings();
            } else {
              _openSettings();
            }
          }

          return false;
        },
        child: Container(
          key: keyOfView,
          height: double.infinity,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPersistentHeaderBuilder(
                minExtent: 100,
                maxExtent: (size.height / 4) * 2.5,
                builder: (context, shrinkPercentage, overlapsContent) {
                  _setShrinkPercentage(shrinkPercentage);

                  return Container(
                    height: double.infinity,
                    color: Colors.blue
                        .withOpacityNoTrans(_shrinkPercentage, Colors.white),
                    child: Row(
                      children: [
                        SizedBox(width: maxMargin * shrinkPercentage),
                        Expanded(
                          child: Container(
                            height: double.infinity,
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              //### for remove unwanted space
                              border: Border.all(
                                width: 0,
                                color: Colors.white,
                              ),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(
                                    maxCurveRadius * shrinkPercentage),
                              ),
                            ),
                            child: SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: Opacity(
                                opacity: shrinkPercentage,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: Row(
                                        children: [
                                          const Text(
                                            "Current State",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          Icon(
                                            isDayTime
                                                ? Icons.wb_sunny_rounded
                                                : Icons.nights_stay,
                                            size: 30,
                                            color: Colors.orange,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    _valueBox(
                                      "Sunrise",
                                      sunriseAt,
                                      const AssetImage(
                                          "assets/images/sunrise_icon.png"),
                                    ),
                                    const SizedBox(height: 15),
                                    _valueBox(
                                      "Sunset",
                                      sunsetAt,
                                      const AssetImage(
                                          "assets/images/sunset_icon.png"),
                                    ),
                                    const SizedBox(height: 15),
                                    _valueBox(
                                      "Offset Sunrise",
                                      ofsunriseAt,
                                      const AssetImage(
                                          "assets/images/ofsunrise_icon.png"),
                                    ),
                                    const SizedBox(height: 15),
                                    _valueBox(
                                      "Offset Sunset",
                                      ofsunsetAt,
                                      const AssetImage(
                                          "assets/images/ofsunset_icon.png"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SliverFillRemaining(
                child: Container(
                  margin: EdgeInsets.only(right: maxMargin * _shrinkPercentage),
                  color: Colors.white,
                  child: Container(
                    //height: size.height,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(_shrinkPercentage),
                      //### for remove unwanted space
                      border: Border.all(
                        width: 0,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Colors.blue.withOpacityNoTrans(
                            _shrinkPercentage, Colors.white),
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(
                            (iconImgSize + iconImgMargin * 2) /
                                2 *
                                _shrinkPercentage),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          Opacity(
                            opacity: _shrinkPercentage,
                            child: Container(
                              height: iconImgSize * _shrinkPercentage,
                              margin: const EdgeInsets.symmetric(
                                horizontal: iconImgMargin,
                                vertical: iconImgMargin,
                              ),
                              child: const SingleChildScrollView(
                                physics: NeverScrollableScrollPhysics(),
                                child: Row(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Astronomical Clock",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Nunito',
                                            color: Colors.white,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .keyboard_double_arrow_up_outlined,
                                              size: 15,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              "Scroll up for offset settings",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Image(
                                      image: AssetImage(
                                          "assets/images/astroclock.png"),
                                      width: iconImgSize,
                                      height: iconImgSize,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          //########################################################
                          Opacity(
                            opacity: 1 - _shrinkPercentage,
                            child: Container(
                              height: viewHeight,
                              child: Column(
                                children: [
                                  _settingCard(
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Offset Status",
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                const Icon(
                                                  Icons
                                                      .subdirectory_arrow_right_rounded,
                                                  size: 20,
                                                ),
                                                Text(
                                                  settingsData["enabled"]
                                                      ? "ON"
                                                      : "OFF",
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        NeumorphismButton(
                                          initialSwitched:
                                              settingsData["enabled"],
                                          switched: settingsData["enabled"],
                                          glowEnabled: false,
                                          onSwitching: (will) async {
                                            setState(() {
                                              settingsData["enabled"] = will;
                                            });

                                            if (will) {
                                              return true;
                                            }

                                            bool result = await syncSettings(
                                              provider,
                                              {"e": will ? 1 : 0},
                                              closeOnSuccess: true,
                                            );

                                            if (!result) {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((
                                                timeStamp,
                                              ) {
                                                setState(() {
                                                  settingsData["enabled"] =
                                                      !will;
                                                });
                                              });
                                            }

                                            return result;
                                          },
                                        ),
                                      ],
                                    ),
                                    shadow: false,
                                    border: true,
                                  ),
                                  settingsData["enabled"]
                                      ? Column(
                                          children: [
                                            _settingCard(
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .sunny_snowing,
                                                              size: 18,
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              "Offset Sunrise",
                                                              style: TextStyle(
                                                                fontSize: 17,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 5),
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          child: SfSlider(
                                                            min: 0,
                                                            max: 120,
                                                            interval: 30,
                                                            showTicks: true,
                                                            showLabels: true,
                                                            showDividers: true,
                                                            minorTicksPerInterval:
                                                                1,
                                                            value: settingsData[
                                                                'sunrise'],
                                                            onChanged: (value) {
                                                              if (value < 1)
                                                                return;
                                                              setState(() {
                                                                settingsData[
                                                                        'sunrise'] =
                                                                    value
                                                                        .toInt();
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "${settingsData['sunrise']}",
                                                        style: const TextStyle(
                                                          fontSize: 35,
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                      Text(
                                                        "minutes",
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.blue
                                                                .withOpacity(
                                                                    0.5)),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            _settingCard(
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Row(
                                                          children: [
                                                            Icon(
                                                              Icons.nights_stay,
                                                              size: 18,
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              "Offset Sunset",
                                                              style: TextStyle(
                                                                fontSize: 17,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 5),
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          child: SfSlider(
                                                            min: 0,
                                                            max: 120,
                                                            interval: 30,
                                                            showTicks: true,
                                                            showLabels: true,
                                                            showDividers: true,
                                                            minorTicksPerInterval:
                                                                1,
                                                            value: settingsData[
                                                                'sunset'],
                                                            onChanged: (value) {
                                                              if (value < 1)
                                                                return;
                                                              setState(() {
                                                                settingsData[
                                                                        'sunset'] =
                                                                    value
                                                                        .toInt();
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "${settingsData['sunset']}",
                                                        style: const TextStyle(
                                                          fontSize: 35,
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                      Text(
                                                        "minutes",
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.blue
                                                                .withOpacity(
                                                                    0.5)),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ).animate().fade(duration: 100.ms)
                                      : const SizedBox(
                                          height: 100,
                                          child: Center(
                                            child: Text(
                                              "Turn on for show settings.",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                  viewHeight != null
                                      ? const Spacer()
                                      : Container(),
                                  settingsData["enabled"]
                                      ? Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 30,
                                          ),
                                          width: double.infinity,
                                          child: FilledButton(
                                            onPressed: () {
                                              syncSettings(
                                                provider,
                                                {
                                                  'e': 1,
                                                  'sr': settingsData["sunrise"],
                                                  'ss': settingsData["sunset"],
                                                },
                                              );
                                            },
                                            child: const Text("UPDATE"),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class AstroScreenController {
  AstroScreenController({
    required this.shouldCloseSettings,
  });

  final VoidCallback shouldCloseSettings;

  bool isSettingsOpened = false;

  closeSettings() {
    shouldCloseSettings();
  }
}
