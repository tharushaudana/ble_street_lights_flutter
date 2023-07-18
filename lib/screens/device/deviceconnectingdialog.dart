import 'package:flutter/material.dart';
import 'package:ble_street_lights/bledevice/bledevice.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ble_street_lights/safestate/safestate.dart';

class DeviceConnectingDialog extends StatefulWidget {
  const DeviceConnectingDialog({
    super.key,
    required this.device,
  });

  final BLEDevice device;

  @override
  State<StatefulWidget> createState() => _DeviceConnectingDialogState();
}

class _DeviceConnectingDialogState extends SafeState<DeviceConnectingDialog> {
  bool isTimeout = false;

  connectDevice() async {
    setState(() {
      isTimeout = false;
    });

    try {
      await widget.device.connect(8000);
      close();
    } catch (e) {
      setState(() {
        isTimeout = true;
      });
    }
  }

  close() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 2000), () {
      connectDevice();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      content: Container(
        height: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            !isTimeout
                ? const Icon(
                    Icons.bluetooth_rounded,
                    size: 80,
                    color: Colors.black87,
                  )
                    .animate(
                      onPlay: (controller) => controller.repeat(),
                    )
                    .shimmer(
                      duration: 600.ms,
                      delay: 1000.ms,
                      color: Colors.blue,
                    )
                : Icon(
                    Icons.bluetooth_rounded,
                    size: 80,
                    color: Colors.red.shade600,
                  ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                !isTimeout ? "Connecting..." : "Unable to Connect!",
                style: const TextStyle(
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            isTimeout
                ? TextButton(
                    onPressed: () {
                      connectDevice();
                    },
                    child: const Text("TRY AGAIN"),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
