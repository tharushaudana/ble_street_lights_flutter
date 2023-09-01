import 'package:flutter/material.dart';
import 'package:ble_street_lights/bledevice/bledevice.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ble_street_lights/safestate/safestate.dart';

class DeviceConnectingDialog extends StatefulWidget {
  DeviceConnectingDialog({
    super.key,
    required this.device,
  });

  final BLEDevice device;
  late VoidCallback onClose;

  close() {
    onClose();
  }

  @override
  State<StatefulWidget> createState() => _DeviceConnectingDialogState();
}

class _DeviceConnectingDialogState extends SafeState<DeviceConnectingDialog> {
  late AssetImage _blueWaveGif;

  bool isTimeout = false;

  bool canClose = false;
  bool shouldClose = false;
  bool disposed = false;

  connectDevice() async {
    setState(() {
      isTimeout = false;
    });

    try {
      await widget.device.connect(8000);
    } catch (e) {
      setState(() {
        isTimeout = true;
      });

      try {
        widget.device.disconnect();
      } catch (e) {}
    }
  }

  close() {
    if (disposed) return;
    
    if (!canClose) {
      shouldClose = true;
      return;
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  void initState() {
    super.initState();

    widget.onClose =() {
      close();
    };

    _blueWaveGif = const AssetImage("assets/images/blue-wave.gif");

    // prevent close during animation
    Future.delayed(const Duration(milliseconds: 5000), () {
      canClose = true;
      if (shouldClose) {
        close();
      }
    });

    connectDevice();
  }

  @override
  void dispose() {
    _blueWaveGif.evict();
    disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      content: SizedBox(
        height: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            !isTimeout
                ? /*const Icon(
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
                    )*/
                    Image(
                        image: _blueWaveGif,
                        width: 135,
                        height: 135,
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
