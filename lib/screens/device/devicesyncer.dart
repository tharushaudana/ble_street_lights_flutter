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
  Map? data,
  required Function(
    SyncDialogController dialogController,
    Function({Map? d}) sendNow,
  ) doSync,
  bool closeOnSuccess = false,
  String initialText = "Syncing Settings...",
  String successText = "Sync Completed.",
  String failedText = "Sync Failed!",
}) {
  
  final c = Completer<bool>();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => DeviceSyncDialog(
      title: initialText,
      doSync: (dialog) {
        doSync(dialog.controller, ({Map? d}) {
          if (data == null && d == null) return;

          BLEDeviceRequest request = BLEDeviceRequest(action)
            ..subject(subject)
            ..data(data ?? d!);

          request.listen(
            onSuccess: (_) {
              c.complete(true);
              dialog.completed(close: closeOnSuccess);
              if (!closeOnSuccess) dialog.changeTitle(successText);
            },
            onFailed: (err) {
              c.complete(false);
              dialog.failed();
              dialog.changeTitle(err);
            },
            onTimeOut: () {
              c.complete(false);
              dialog.failed();
              dialog.changeTitle(failedText);
            },
          );

          provider.makeRequest(request);
        });
      },
    ),
  );

  return c.future;
}
