import 'dart:async';
import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:ble_street_lights/bledevice/request.dart';
import 'package:ble_street_lights/screens/device/dialogs/syncdialog.dart';
import 'package:flutter/material.dart';

Future<bool> showDeviceSyncDialog({
  required BuildContext context,
  required BLEDeviceConnectionProvider provider,
  required String action,
  required String subject,
  required Map data,
  required Function(SyncDialogController dialogController, VoidCallback sendNow) doSync,
  bool closeOnSuccess = false,
  String initialText = "Syncing Settings...",
  String successText = "Sync Completed.",
  String failedText = "Sync Failed!"
}) {
  final c = Completer<bool>();

  BLEDeviceRequest request = BLEDeviceRequest(action)
    ..subject(subject)
    ..data(data);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => DeviceSyncDialog(
      title: initialText,
      doSync: (dialog) {
        request.listen(
          onSuccess: (_) {
            c.complete(true);
            dialog.completed(close: closeOnSuccess);
            if (!closeOnSuccess) dialog.changeTitle(successText);
          },
          onTimeOut: () {
            c.complete(false);
            dialog.failed();
            dialog.changeTitle(failedText);
          },
        );

        doSync(dialog.controller, () {
          provider.makeRequest(request);
        });
      },
    ),
  );

  return c.future;
}
