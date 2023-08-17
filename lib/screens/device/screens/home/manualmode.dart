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
  });

  final Map settingsData;
  final int selectedLampIndex;

  final Function(int index) onChangeSelectIndex;
  final Function(int value) onChangeLampValue;

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
                size: 150,
                highColor: Color(0xffffd4cb),
                lowColor: Color(0xff413be7),
                trackWidth: 5,
                value:
                    settingsData["lamps"][selectedLampIndex]["pwm"].toDouble(),
              ),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
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
                  child: Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 50,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
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
                      width: 65,
                      height: 65,
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
                                color: const Color(0xff413be7),
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
                                ? const Color(0xff413be7)
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
                            size: 25,
                            color: selectedLampIndex == i
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
        GradientSlider(
          onChange: (value) {
            onChangeLampValue(value.toInt());
          },
          min: 0,
          max: 100,
          value: settingsData["lamps"][selectedLampIndex]["pwm"].toDouble(),
          intLabel: true,
          tricksCount: 20,
        ),
      ],
    );
  }
}
