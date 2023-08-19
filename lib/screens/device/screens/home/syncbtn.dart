import 'dart:async';

import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:ble_street_lights/bledevice/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SyncButton extends StatefulWidget {
  const SyncButton({
    super.key,
    required this.provider,
    required this.action,
    required this.subject,
    required this.onAnimStarted,
    required this.onStartSync,
    required this.onResult,
  });

  final BLEDeviceConnectionProvider provider;
  final String action;
  final String subject;
  final VoidCallback onAnimStarted;
  final Map Function() onStartSync;
  final Function(bool completed) onResult;

  @override
  State<StatefulWidget> createState() => _SyncButtonState();
}

class _SyncButtonState extends State<SyncButton> {
  late Timer _timer;

  int _timeout = 0;
  bool canSync = true;
  bool isSyncing = false;
  bool syncCompleted = false;

  syncNow(Map data) {
    _timeout = 15;
    syncCompleted = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeout--;

      if (_timeout == 0) {
        syncCompleted = false;
        showSyncing(false);
        widget.onResult(false);

        _timer.cancel();
      }
    });

    BLEDeviceRequest request = BLEDeviceRequest(widget.action)
      ..subject(widget.subject)
      ..data(data);

    request.listen(
      onSuccess: (_) {
        _timer.cancel();
        syncCompleted = true;
        showSyncing(false);
        widget.onResult(true);
      },
      onTimeOut: () {
        _timer.cancel();
        syncCompleted = false;
        showSyncing(false);
        widget.onResult(false);
      },
    );

    widget.provider.makeRequest(request);
  }

  showSyncing(bool b) {
    setState(() {
      if (b && canSync) canSync = false;
      isSyncing = b;
    });
  }

  @override
  void dispose() {
    try {
      _timer.cancel();
    } catch (e) {}

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: canSync
            ? InkWell(
                onTap: () {
                  showSyncing(true);
                  widget.onAnimStarted();
                  Future.delayed(const Duration(milliseconds: 2000), () {
                    syncNow(widget.onStartSync());
                  });
                },
                child: const Icon(
                  Icons.sync_outlined,
                  color: Colors.blue,
                ).animate().fadeIn(duration: 300.ms),
              )
            : isSyncing
                ? const SpinKitThreeBounce(
                    color: Colors.blue,
                    size: 15,
                  )
                : syncCompleted
                    ? const Icon(
                        Icons.done_rounded,
                        color: Colors.green,
                      )
                        .animate(
                          onComplete: (controller) => setState(() {
                            canSync = true;
                          }),
                        )
                        .fadeIn(duration: 300.ms)
                        .fadeOut(
                          delay: 3000.ms,
                          duration: 300.ms,
                        )
                    : const Icon(
                        Icons.info_outline_rounded,
                        color: Colors.red,
                      )
                        .animate(
                          onComplete: (controller) => setState(() {
                            canSync = true;
                          }),
                        )
                        .fadeIn(duration: 300.ms)
                        .fadeOut(
                          delay: 3000.ms,
                          duration: 300.ms,
                        ));
  }
}
