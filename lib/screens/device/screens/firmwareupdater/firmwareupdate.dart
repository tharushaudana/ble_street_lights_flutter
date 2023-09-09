import 'dart:developer';
import 'dart:io';

import 'package:ble_street_lights/safestate/safestate.dart';
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
    extends SafeState<DeviceFirmwareUpdaterScreen> {
  bool firmwareFileDownloaded = false;
  bool isSending = false;
  double sentPercent = 0;

  Uint8List? firmwareBytes;

  Future<Uint8List> _downloadFirmwareFile() async {
    final req =  await HttpClient().getUrl(Uri.parse("https://tmpfiles.org/dl/2273820/esp32_f1.0v.ino.esp32.bin"));
    //final req = await HttpClient().getUrl(Uri.parse("https://tmpfiles.org/dl/2273483/fields.json"));
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
        //'s': 1182456,
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
      //int totalLen = 1182456;

      //Uint8List list = Uint8List(1182456);
      //list.fillRange(0, 1182456, 1);

      provider.sendFirmwareFile(
        firmwareBytes!.buffer,
        //list.buffer,
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
