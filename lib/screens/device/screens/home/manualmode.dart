import 'package:ble_street_lights/components/circularvalueindicator/circularvalueindicator.dart';
import 'package:ble_street_lights/components/gradientslider/gradientslider.dart';
import 'package:flutter/material.dart';

class ManualMode extends StatelessWidget {
  ManualMode({
    super.key,
    required this.settingsData,
    required this.selectedLampIndex,
    required this.onChangeSelectIndex,
    required this.onChangeLampValue,
    required this.onChangeRelayValue,
  });

  final Map settingsData;
  final int selectedLampIndex;

  final Function(int index) onChangeSelectIndex;
  final Function(int value) onChangeLampValue;
  final Function(int rvalue) onChangeRelayValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularValueIndicator(
                size: 100,
                highColor: Color(0xffffd4cb),
                //highColor: Color(0xff55d0ff),
                lowColor: Colors.blue,
                //lowColor: Color(0xff413be7),
                trackWidth: 4,
                value:
                    settingsData["lamps"][selectedLampIndex]["pwm"].toDouble(),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: settingsData["lamps"][selectedLampIndex]["rvalue"] == 1 ? Colors.blue.shade100 : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      offset: const Offset(0, 1),
                      blurRadius: 10,
                      //spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      if (settingsData["lamps"][selectedLampIndex]["rvalue"] == 1) {
                        onChangeRelayValue(0);
                      } else {
                        onChangeRelayValue(1);
                      }
                    },
                    child: Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 30,
                      color: settingsData["lamps"][selectedLampIndex]["rvalue"] == 1 ? Colors.blue : Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        GradientSlider(
          onChange: (value) {
            onChangeLampValue(value.toInt());
          },
          min: 0,
          max: 100,
          value: settingsData["lamps"][selectedLampIndex]["pwm"].toDouble(),
          intLabel: true,
          height: 55,
          trackHeight: 10,
          thumbSize: 30,
          tricksCount: 50,
          tricksHeight: 15,
          colors: const [
            Colors.blue,
            Color(0xffffd4cb)
          ],
          thumbBorderColor: Colors.blue,
          thumbLabelTextStyle: const TextStyle(
            color: Colors.blue,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < settingsData["lamps"].length; i++)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      margin: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 10,
                      ),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: selectedLampIndex == i
                            ? Border.all(
                                width: 0.5,
                                color: Colors.blue,
                              )
                            : null,
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          if (i == selectedLampIndex) return;
                          onChangeSelectIndex(i);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedLampIndex == i
                                ? Colors.blue
                                : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                offset: const Offset(0, 1),
                                blurRadius: 10,
                                //spreadRadius: 2,
                              ),
                            ],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 20,
                            color: selectedLampIndex == i
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "LAMP ${(i + 1)}",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
