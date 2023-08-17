import 'package:ble_street_lights/components/circularvalueindicator/circularvalueindicator.dart';
import 'package:flutter/material.dart';

class ManualMode extends StatelessWidget {
  ManualMode({
    super.key,
    required this.settingsData,
    required this.selectedLampIndex,
    required this.onChangeSelectIndex,
  });

  final Map settingsData;
  final int selectedLampIndex;

  final Function(int index) onChangeSelectIndex;

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
                    size: 60,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < settingsData["lamps"].length; i++)
                Column(
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10,),
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
                            size: 35,
                            color: selectedLampIndex == i
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        )
      ],
    );
  }
}
