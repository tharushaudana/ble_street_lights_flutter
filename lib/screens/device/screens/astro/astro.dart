import 'dart:ui';
import 'package:ble_street_lights/components/sliverpersistentheaderbuilder/sliverpersistentheaderbuilder.dart';
import 'package:ble_street_lights/components/neumorphismbutton/neumorphismbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/rendering/sliver_persistent_header.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class AstroScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AstroScreenState();
}

class _AstroScreenState extends State<AstroScreen> {
  double _shrinkPercentage = 0;

  bool isOffsetStatusEnabled = false;

  Map settingsData = {
    "offsetSunrise": 100,
    "offsetSunset": 50,
  };

  Widget _valueBox(String title, String value) {
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
          Icon(
            Icons.calendar_month_rounded,
            color: Colors.grey.shade400,
            size: 30,
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
        vertical: 10,
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
                    color: Colors.grey.shade300,
                    offset: const Offset(0, 1),
                    blurRadius: 20,
                    //spreadRadius: 2,
                  ),
                ]
              : [],
          border: border && _shrinkPercentage < 0.1
              ? Border.all(
                  width: _shrinkPercentage > 0.1 ? 0 : (0.1 - _shrinkPercentage) / 0.1,
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

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final double iconImgSize = 85;
    final double iconImgMargin = 10;

    final double maxCurveRadius = 25;
    final double maxMargin = 7;

    return CustomScrollView(
      slivers: [
        SliverPersistentHeaderBuilder(
          minExtent: 100,
          maxExtent: (size.height / 4) * 2.5,
          builder: (context, shrinkPercentage, overlapsContent) {
            _setShrinkPercentage(shrinkPercentage);

            return Container(
              height: double.infinity,
              color: Colors.blue.withOpacity(_shrinkPercentage),
              child: Row(
                children: [
                  SizedBox(width: maxMargin * shrinkPercentage),
                  Expanded(
                    child: Container(
                      height: double.infinity,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(
                              maxCurveRadius * shrinkPercentage),
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
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
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(50)),
                                child: Row(
                                  children: [
                                    Text(
                                      "Current State",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.wb_sunny_rounded,
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                              _valueBox("Sunrise", "6:00 AM"),
                              const SizedBox(height: 15),
                              _valueBox("Sunset", "6:30 PM"),
                              const SizedBox(height: 15),
                              _valueBox("Offset Sunrise", "6:00 AM"),
                              const SizedBox(height: 15),
                              _valueBox("Offset Sunset", "6:30 PM"),
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
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular((iconImgSize + iconImgMargin * 2) /
                      2 *
                      _shrinkPercentage),
                ),
              ),
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Opacity(
                      opacity: _shrinkPercentage,
                      child: Container(
                        height: iconImgSize * _shrinkPercentage,
                        margin: EdgeInsets.symmetric(
                          horizontal: iconImgMargin,
                          vertical: iconImgMargin,
                        ),
                        child: SingleChildScrollView(
                          physics: NeverScrollableScrollPhysics(),
                          child: Row(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                            .keyboard_double_arrow_down_outlined,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "Scroll down for settings",
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
                                image:
                                    AssetImage("assets/images/astroclock.png"),
                                width: iconImgSize,
                                height: iconImgSize,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 1 - _shrinkPercentage,
                      child: Column(
                        children: [
                          _settingCard(
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Offset Status",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons
                                              .subdirectory_arrow_right_rounded,
                                          size: 20,
                                        ),
                                        Text(
                                          isOffsetStatusEnabled ? "ON" : "OFF",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Spacer(),
                                NeumorphismButton(
                                  initialSwitched: false,
                                  onSwitching: (will) {
                                    setState(() {
                                      isOffsetStatusEnabled = will;
                                    });
                                    return true;
                                  },
                                ),
                              ],
                            ),
                            shadow: false,
                            border: true,
                          ),
                          isOffsetStatusEnabled
                              ? Column(
                                  children: [
                                    _settingCard(
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(Icons.sunny_snowing),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      "Offset Sunrise",
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                                Container(
                                                  width: double.infinity,
                                                  child: SfSlider(
                                                    min: 0,
                                                    max: 120,
                                                    interval: 30,
                                                    showTicks: true,
                                                    showLabels: true,
                                                    showDividers: true,
                                                    minorTicksPerInterval: 1,
                                                    value: settingsData[
                                                        'offsetSunrise'],
                                                    onChanged: (value) {
                                                      if (value < 1) return;
                                                      setState(() {
                                                        settingsData[
                                                                'offsetSunrise'] =
                                                            value.toInt();
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
                                                "${settingsData['offsetSunrise']}",
                                                style: TextStyle(
                                                  fontSize: 35,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              Text(
                                                "minutes",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.blue
                                                        .withOpacity(0.5)),
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
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(Icons.nights_stay),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      "Offset Sunset",
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                                Container(
                                                  width: double.infinity,
                                                  child: SfSlider(
                                                    min: 0,
                                                    max: 120,
                                                    interval: 30,
                                                    showTicks: true,
                                                    showLabels: true,
                                                    showDividers: true,
                                                    minorTicksPerInterval: 1,
                                                    value: settingsData[
                                                        'offsetSunset'],
                                                    onChanged: (value) {
                                                      if (value < 1) return;
                                                      setState(() {
                                                        settingsData[
                                                                'offsetSunset'] =
                                                            value.toInt();
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
                                                "${settingsData['offsetSunset']}",
                                                style: TextStyle(
                                                  fontSize: 35,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              Text(
                                                "minutes",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.blue
                                                        .withOpacity(0.5)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 20,
                                      ),
                                      width: double.infinity,
                                      child: FilledButton(
                                        onPressed: () {},
                                        child: Text("UPDATE"),
                                      ),
                                    ),
                                  ],
                                ).animate().fade(duration: 100.ms)
                              : Container(
                                  height: 100,
                                  child: Center(
                                    child: Text(
                                      "Turn on for show settings.",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    /*Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),*/
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
