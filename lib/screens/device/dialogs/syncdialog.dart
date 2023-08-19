import 'dart:async';

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
  late SyncDialogController controller;

  late Timer _timer;

  int _timeout = 0; // in secs
  bool _isFailed = false;
  bool _isCompleted = false;

  late AssetImage _doneGif;

  String title = "";

  changeTitle(String newTitle) {
    setState(() {
      title = newTitle;
    });
  }

  completed({bool close = false}) {
    _timer.cancel();

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

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeout--;

      if (_timeout == 0) {
        setState(() {
          _isFailed = true;
          title = "Request Timeout!";
        });

        _timer.cancel();
      }
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

  _start() {
    setState(() {
      _timeout = 15; // in secs
      _isFailed = false;
      _isCompleted = false;
      title = widget.title;
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      _startSync();
    });
  }

  @override
  void initState() {
    title = widget.title;

    _doneGif = const AssetImage("assets/images/done-loop-10.gif");

    super.initState();

    controller = SyncDialogController(
      onChangeTitle: (String title) {
        changeTitle(title);
      },
      onFailed: () {
        failed();
      },
    );

    _start();
  }

  @override
  void dispose() {
    _doneGif.evict();

    try {
      _timer.cancel();
    } catch (e) {}

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
                    : /*Icon(
                        Icons.done_outline_rounded,
                        size: 80,
                        color: Colors.green.shade600,
                      ).animate().fade(duration: 500.ms),*/
                    Image(
                        image: _doneGif,
                        width: 85,
                        height: 85,
                      ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            _isCompleted
                ? TextButton(
                    onPressed: () {
                      _close();
                    },
                    child: const Text("CLOSE"),
                  )
                : _isFailed
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              _start();
                            },
                            child: const Text("TRY AGAIN"),
                          ),
                          TextButton(
                            onPressed: () {
                              _close();
                            },
                            child: const Text(
                              "CLOSE",
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          )
                        ],
                      )
                    : Container(),
            /*_isFailed || _isCompleted
                ? TextButton(
                    onPressed: () {
                      //connectDevice();
                      _close();
                    },
                    child: const Text("CLOSE"),
                  )
                : Container(),*/
          ],
        ),
      ),
    );
  }
}

class SyncDialogController {
  SyncDialogController({
    required this.onChangeTitle,
    required this.onFailed,
  });

  final Function(String title) onChangeTitle;
  final VoidCallback onFailed;

  changeTitle(String title) {
    onChangeTitle(title);
  }

  failed() {
    onFailed();
  }
}
