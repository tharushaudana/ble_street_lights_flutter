import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:ble_street_lights/bledevice/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DeviceSyncDialog extends StatefulWidget {
  const DeviceSyncDialog({
    super.key,
    required this.title,
    required this.doSync,
  });

  final String title;
  final Function(_DeviceSyncDialogState dialog) doSync;

  @override
  State<StatefulWidget> createState() => _DeviceSyncDialogState();
}

class _DeviceSyncDialogState extends State<DeviceSyncDialog> {
  bool _isTimeout = false;
  bool _isCompleted = false;

  completed() {
    setState(() {
      _isCompleted = true;
    });
  }

  timeout() {
    setState(() {
      _isTimeout = true;
    });
  }

  _startSync() async {
    setState(() {
      _isTimeout = false;
      _isCompleted = false;
    });

    widget.doSync(this);
  }

  _close() {
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
      _startSync();
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
            !_isCompleted && !_isTimeout
                ? SpinKitThreeBounce(
                    color: Colors.blue,
                  )
                : _isTimeout
                    ? Icon(
                        Icons.warning_amber_rounded,
                        size: 80,
                        color: Colors.red.shade600,
                      )
                    : Icon(
                        Icons.done_outline_rounded,
                        size: 80,
                        color: Colors.green.shade600,
                      ).animate().fade(duration: 500.ms),
            const SizedBox(height: 10),
            Center(
              child: Text(
                !_isCompleted && !_isTimeout
                    ? widget.title
                    : _isTimeout
                        ? "No Response!"
                        : "Sync Completed.",
                style: const TextStyle(
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            _isTimeout || _isCompleted
                ? TextButton(
                    onPressed: () {
                      //connectDevice();
                      _close();
                    },
                    child: const Text("CLOSE"),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
