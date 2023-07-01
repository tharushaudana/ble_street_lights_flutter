import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ble_street_lights/components/celluarbar/celluarbar.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DeviceCard extends StatefulWidget {
  const DeviceCard({
    super.key,
    required this.name,
    required this.address,
    required this.rssi,
    required this.available,
    required this.ischecking,
    required this.onTap,
  });

  final String name;
  final String address;
  final int rssi;
  final bool available;
  final bool ischecking;
  final VoidCallback onTap;

  @override
  State<StatefulWidget> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> with TickerProviderStateMixin {
  late AnimationController animationControllerShimmer;

  @override
  void initState() {
    animationControllerShimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            widget.onTap();
          },
          onLongPress: () {
            log("message");
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
            decoration: BoxDecoration(
              //border: Border.all(
              //    color: Colors.grey.shade400, width: 1, style: BorderStyle.solid),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              //color: Colors.grey.shade300,
              //color: Theme.of(context).scaffoldBackgroundColor,
              color: Colors.blue.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  //color: Colors.grey.shade600,
                  color: Colors.blue.withOpacity(0.2),
                  //            offset: Offset(4, 4),
                  offset: Offset(1, 1),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  //color: Colors.white,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  offset: Offset(-4, -4),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
                //------------------------
                /*BoxShadow(
                color: Colors.white,
                offset: Offset(-4, -4),
                blurRadius: 30,
              ),
              BoxShadow(
                color: Color(0xFFA7A9AF),
                offset: Offset(15, 15),
                blurRadius: 30,
              ),*/
              ],
            ),
            child: Row(
              children: [
                const Image(
                  image: AssetImage("assets/images/device_icon.png"),
                  width: 48,
                  height: 48,
                ),
                const SizedBox(
                  width: 10,
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      widget.address,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const SizedBox(width: 15),
                !widget.ischecking
                    ? widget.available
                        ? Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                width: 33,
                                height: 15,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "${widget.rssi} dBm",
                                  style: const TextStyle(
                                    fontSize: 7,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                width: 40,
                                height: 38,
                                alignment: Alignment.centerRight,
                                child: CelluarBar(
                                  width: 27,
                                  rssi: widget.rssi,
                                ),
                              ),
                            ],
                          )
                        : const Icon(
                            Icons.signal_cellular_off_rounded,
                            size: 32,
                            color: Colors.red,
                          )
                    : const Icon(
                        Icons.signal_cellular_4_bar_rounded,
                        size: 32,
                        color: Colors.grey,
                      )
                        .animate(
                          onPlay: (controller) => controller.repeat(),
                        )
                        .shimmer(duration: 600.ms, delay: 1000.ms),
              ],
            ),
          ),
        ),
        //##################### GREEN DOT #####################
        widget.available
            ? Container(
                alignment: Alignment.topRight,
                margin: const EdgeInsets.only(
                  right: 27,
                  top: 17,
                ),
                child: Container(
                  height: 6,
                  width: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.greenAccent.shade700,
                  ),
                ),
              ).animate().fade(duration: 300.ms)
            : Container(),
      ],
    );
  }
}