import 'dart:async';

import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:ble_street_lights/bledevice/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SyncButton extends StatefulWidget {
  const SyncButton({
    super.key,
    required this.provider,
    required this.action,
    required this.subject,
    required this.onStartSync,
    required this.onResult,
  });

  final BLEDeviceConnectionProvider provider;
  final String action;
  final String subject;
  final Map Function() onStartSync;
  final Function(bool completed) onResult;

  @override
  State<StatefulWidget> createState() => _SyncButtonState();
}

class _SyncButtonState extends State<SyncButton> {
  bool canSync = true;
  bool isSyncing = false;
  bool syncCompleted = false;

  syncNow(Map data) {
    syncCompleted = false;

    BLEDeviceRequest request = BLEDeviceRequest(widget.action)
      ..subject(widget.subject)
      ..data(data);

    request.listen(
      onSuccess: (_) {
        syncCompleted = true;
        showSyncing(false);
        widget.onResult(true);
      },
      onTimeOut: () {
        syncCompleted = false;
        showSyncing(false);
        widget.onResult(false);
      },
    );

    widget.provider.makeRequest(request);
  }

  showSyncing(bool b) {
    setState(() {
      canSync = !b;
      isSyncing = b;
    });
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
                Future.delayed(const Duration(milliseconds: 2000), () {
                  syncNow(widget.onStartSync());
                });
              },
              child: const Icon(
                Icons.sync_outlined,
                color: Colors.blue,
              ),
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
                  : const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.red,
                    ),
    );
  }
}
