import 'package:ble_street_lights/components/circularvalueindicator/circularvalueindicator.dart';
import 'package:ble_street_lights/components/gradientslider/gradientslider.dart';
import 'package:flutter/material.dart';

class AstroMode extends StatelessWidget {
  AstroMode({
    super.key,
    required this.modeType,
    required this.stage,
    required this.currentBrightness,
    required this.relayStates,
  });

  final String modeType;
  final Map stage;
  final int currentBrightness;
  final List relayStates;

  List disabled = [2, 3];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 25),
      child: Column(
        children: [
          Column(
            children: [
              stage.isNotEmpty
                  ? Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.blue,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            modeType == "manual" ? "M" : "G",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "${stage["from"].hour.toString().padLeft(2, '0')}:${stage["from"].minute.toString().padLeft(2, '0')}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 15,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 15),
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "${stage["to"].hour.toString().padLeft(2, '0')}:${stage["to"].minute.toString().padLeft(2, '0')}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "No Active Stage",
                        style: TextStyle(
                          color: Colors.blue,
                          //fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              const SizedBox(height: 10),
              GradientSlider(
                min: 0,
                max: 100,
                value: currentBrightness.toDouble(),
                intLabel: true,
                height: 55,
                trackHeight: 10,
                thumbSize: 30,
                tricksCount: 50,
                tricksHeight: 15,
                colors: const [Colors.blue, Color(0xffffd4cb)],
                tricksColor: Colors.grey.shade300,
                thumbBorderColor: Colors.blue,
                thumbLabelTextStyle: const TextStyle(
                  color: Colors.blue,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                indicateOnly: true,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < 4; i++)
                    Opacity(
                      opacity: disabled.contains(i) ? 0.4 : 1,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 10,
                        ),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularValueIndicator(
                                  size: 55,
                                  highColor: Color(0xffffd4cb),
                                  //highColor: Color(0xff55d0ff),
                                  lowColor: Colors.blue,
                                  //lowColor: Color(0xff413be7),
                                  trackWidth: 3,
                                  value: disabled.contains(i) ? 0 : currentBrightness.toDouble(),
                                ),
                                Container(
                                  width: 45,
                                  height: 45,
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: relayStates[i] == 1
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
                                    color: relayStates[i] == 1
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                              ],
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
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
