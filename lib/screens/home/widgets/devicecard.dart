import 'package:ble_street_lights/components/flippablelayout/flippablelayout.dart';
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
    required this.selectOnTap,
    this.selected = true,
    required this.onTap,
    required this.onSelect,
    required this.onUnselect,
  });

  final String name;
  final String address;
  final int rssi;
  final bool available;
  final bool ischecking;
  final bool selectOnTap;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onSelect;
  final VoidCallback onUnselect;

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

  callbackSelectChange(bool select) {
    if (widget.selected) {
      widget.onUnselect();
    } else {
      widget.onSelect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (widget.selected) {
              callbackSelectChange(false);
            } else if (widget.selectOnTap) {
              callbackSelectChange(true);
            } else {
              widget.onTap();
            }
          },
          onLongPress: () {
            if (widget.selected || widget.selectOnTap) return;
            callbackSelectChange(true);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              color: Colors.blue.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  offset: Offset(1, 1),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  offset: Offset(-4, -4),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                FlippableLayout(
                  duration: const Duration(milliseconds: 600),
                  flipped: widget.selected,
                  front: const Image(
                    image: AssetImage("assets/images/device_icon.png"),
                    width: 48,
                    height: 48,
                  ),
                  back: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.blue,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white70,
                      size: 25,
                    ).animate().scale(duration: 300.ms, delay: 100.ms),
                  ),
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
