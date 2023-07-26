import 'dart:ui';

import 'package:ble_street_lights/components/sliverpersistentheaderbuilder/sliverpersistentheaderbuilder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/rendering/sliver_persistent_header.dart';

class AstroScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AstroScreenState();
}

class _AstroScreenState extends State<AstroScreen> {
  double _shrinkPercentage = 0;

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

    final double iconImgSize = 65;
    final double iconImgMargin = 10;

    final double maxCurveRadius = 25;
    final double maxMargin = 7;

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

    return CustomScrollView(
      slivers: [
        SliverPersistentHeaderBuilder(
          minExtent: 100,
          maxExtent: (size.height / 4) * 2.5,
          builder: (context, shrinkPercentage, overlapsContent) {
            _setShrinkPercentage(shrinkPercentage);

            return Container(
              height: double.infinity,
              color: Colors.blue,
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
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular((iconImgSize + iconImgMargin * 2) / 2 * _shrinkPercentage),
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
                                        Icons.keyboard_double_arrow_down_outlined,
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
                          for (int i = 0; i < 5; i++)
                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 50,
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

class TestDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.blue,
      child: Column(
        children: [
          Text("hello"),
          Text("hello"),
          Text("hello"),
          Text("hello"),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 400;

  @override
  double get minExtent => 100;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class ItemBlock extends StatelessWidget {
  const ItemBlock({
    super.key,
    this.stringHeight = 15,
    this.bgColor = Colors.blue,
    required this.child,
  });

  final double stringHeight;
  final Color bgColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final double stringMargin = 20;
    final double stringWidth = 10;

    return Container(
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: stringMargin),
              Container(
                height: stringHeight,
                width: stringWidth,
                decoration: BoxDecoration(
                  color: bgColor,
                ),
              ),
              Spacer(),
              Container(
                height: stringHeight,
                width: stringWidth,
                decoration: BoxDecoration(
                  color: bgColor,
                ),
              ),
              SizedBox(width: stringMargin),
            ],
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
