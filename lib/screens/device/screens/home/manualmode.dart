import 'package:ble_street_lights/components/circularvalueindicator/circularvalueindicator.dart';
import 'package:flutter/material.dart';

class ManualMode extends StatelessWidget {
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
                value: 75,
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
        )
      ],
    );
  }
}
