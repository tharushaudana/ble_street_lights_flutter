import 'dart:developer';
import 'dart:io';

import 'package:ble_street_lights/screens/device/devicesyncer.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:flutter/material.dart';

class DeviceFirmwareUpdaterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DeviceFirmwareUpdaterScreenState();
}

class _DeviceFirmwareUpdaterScreenState
    extends State<DeviceFirmwareUpdaterScreen> {
  bool firmwareFileDownloaded = false;
  bool isSending = false;
  double sentPercent = 0;

  Uint8List? firmwareBytes;

  Future<Uint8List> _downloadFirmwareFile() async {
    final req = await HttpClient()
        .getUrl(Uri.parse("https://tmpfiles.org/dl/2212608/firm.bin"));
    final res = await req.close();
    final bytes = await consolidateHttpClientResponseBytes(res);
    return bytes;
  }

  _startUpdate(BLEDeviceConnectionProvider provider) async {
    bool b = await showDeviceSyncDialog(
      context: context,
      initialText: "Starting Send...",
      provider: provider,
      action: "set",
      subject: "fus",
      data: {
        's': firmwareBytes!.length,
      },
      closeOnSuccess: true,
      doSync: (
        dialogController,
        sendNow,
      ) {
        sendNow();
      },
    );

    if (b) {
      setState(() {
        isSending = true;
        sentPercent = 0;
      });

      log("Start sending firmware file...");

      int totalLen = firmwareBytes!.length;

      provider.sendFirmwareFile(
        firmwareBytes!.buffer,
        onWrite: (writtenLen) {
          setState(() {
            sentPercent = (writtenLen / totalLen);
          });
        },
        onDone: () {
          log("Write Doneeeeeeeeeeeee!");
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BLEDeviceConnectionProvider>(builder: (
      context,
      provider,
      _,
    ) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Firmware Updater"),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              !firmwareFileDownloaded
                  ? FilledButton(
                      onPressed: () async {
                        firmwareBytes = await _downloadFirmwareFile();

                        setState(() {
                          firmwareFileDownloaded = true;
                        });
                      },
                      child: Text("test"),
                    )
                  : FilledButton(
                      onPressed: () {
                        _startUpdate(provider);
                      },
                      child: Text("Update Now"),
                    ),

              isSending
                  ? LinearProgressIndicator(
                      value: sentPercent,
                    )
                  : Container(),
              firmwareBytes != null
                  ? Text(
                      "Download successfully. ${firmwareBytes!.length} bytes")
                  : Container(),
              provider.deviceData.firmwareUpdateResult != null
                  ? Text("Success write to esp.")
                  : Container(),
            ],
          ),
        ),
      );
    });
  }
}
