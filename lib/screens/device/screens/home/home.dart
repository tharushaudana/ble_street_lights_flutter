import 'dart:developer';
import 'package:ble_street_lights/components/swipecardswitch/swipecardswitch.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class DeviceHomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DeviceHomeScreenState();
}

class _DeviceHomeScreenState extends State<DeviceHomeScreen> with AutomaticKeepAliveClientMixin<DeviceHomeScreen> {
  double v = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 15),
        SwipeCardSwitch(
          color: Colors.blue,
          initialSwitchedChild: 2,
          onSwitching: (willSwitchingChild) {
            log("message: " + willSwitchingChild.toString());
            return true;
          },
          child1: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "ASTRO",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                ),
              ),
              Text(
                "MODE",
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
            ],
          ),
          child2: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "MANUAL",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                ),
              ),
              Text(
                "MODE",
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
            child: _ContentCard(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              NeumorphismButton(),
              Spacer(),
              NeumorphismButton(),
            ],
          ),
        )),
        Expanded(
            child: _ContentCard(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SleekCircularSlider(
                appearance: CircularSliderAppearance(
                  customColors: CustomSliderColors(
                    trackColor: Colors.blue.shade100,
                    progressBarColors: [
                      Colors.blue,
                      Colors.blue.shade100,
                    ],
                    hideShadow: true,
                  ),
                ),
                onChange: (double value) {},
              ),
              Spacer(),
              SleekCircularSlider(
                appearance: CircularSliderAppearance(
                  customColors: CustomSliderColors(
                    trackColor: Colors.blue.shade100,
                    progressBarColors: [
                      Colors.blue,
                      Colors.blue.shade100,
                    ],
                    hideShadow: true,
                  ),
                ),
                onChange: (double value) {},
              ),
            ],
          ),
        )),
        /*SleekCircularSlider(
          appearance: CircularSliderAppearance(
            customColors: CustomSliderColors(
              trackColor: Colors.blue.shade100,
              progressBarColors: [
                Colors.blue,
                Colors.blue.shade100,
              ],
              hideShadow: true,
            ),
          ),
          onChange: (double value) {},
        ),*/
      ],
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

class NeumorphismButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NeumorphismButtonState();
}

class _NeumorphismButtonState extends State<NeumorphismButton> {
  bool isPressed = true;

  //Color bgColor = Color(0xFFE7ECEF);

  Color _shadeColor(Color color, double shadingFactor) {
    assert(shadingFactor >= 0 && shadingFactor <= 1,
        'The shadingFactor must be between 0 and 1 (inclusive).');

    int red = (color.red + (255 - color.red) * shadingFactor).round();
    int green = (color.green + (255 - color.green) * shadingFactor).round();
    int blue = (color.blue + (255 - color.blue) * shadingFactor).round();

    return Color.fromARGB(color.alpha, red, green, blue);
  }

  @override
  Widget build(BuildContext context) {
    final Offset distance = !isPressed ? Offset(20, 20) : Offset(8, 8);

    final double bSize = 100;

    Color bgColor = Color(0xFFE7ECEF);

    return GestureDetector(
      onTap: () {
        setState(() {
          isPressed = !isPressed;
        });
      },
      /*child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              offset: -distance,
              blurRadius: blur,
              color: Colors.white,
              inset: isPressed,
            ),
            BoxShadow(
              offset: distance,
              blurRadius: blur,
              color: Color(0xFFA7A9AF),
              inset: isPressed,
            ),
          ],
        ),
      ),*/
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        width: bSize,
        height: bSize,
        child: Icon(
          Icons.power_settings_new_rounded,
          size: bSize * 0.3,
          color: _shadeColor(Colors.blue, 0.7),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(150),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: !isPressed
                ? [
                    Color(0xffffffff),
                    Color(0xffced2d5),
                  ]
                : [
                    _shadeColor(Colors.blue, 0),
                    _shadeColor(Colors.blue, 0.7),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: !isPressed
                  ? Color(0xffffffff)
                  : _shadeColor(Colors.blue, 0.7),
              offset: -distance,
              blurRadius: (bSize / 10) * 2,
              spreadRadius: 0.0,
            ),
            BoxShadow(
              color: !isPressed
                  ? Color(0xffced2d5)
                  : _shadeColor(Colors.blue, 0.6),
              offset: distance,
              blurRadius: (bSize / 10) * 2,
              spreadRadius: 0.0,
            ),
          ],
        ),
      ),
    );
  }
}
