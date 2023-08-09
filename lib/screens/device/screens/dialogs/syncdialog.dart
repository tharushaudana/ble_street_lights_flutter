import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ble_street_lights/safestate/safestate.dart';

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

class _DeviceSyncDialogState extends SafeState<DeviceSyncDialog> {
  bool _isFailed = false;
  bool _isCompleted = false;

  String title = "";

  changeTitle(String newTitle) {
    setState(() {
      title = newTitle;
    });
  }

  completed({bool close = false}) {
    if (!close) {
      setState(() {
        _isCompleted = true;
      });
    } else {
      Navigator.pop(context);
    }
  }

  failed() {
    setState(() {
      _isFailed = true;
    });
  }

  _startSync() async {
    setState(() {
      _isFailed = false;
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
    title = widget.title;

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
        height: 170,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            !_isCompleted && !_isFailed
                ? SpinKitThreeBounce(
                    color: Colors.blue,
                    size: 35,
                  )
                : _isFailed
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
                title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            _isFailed || _isCompleted
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
