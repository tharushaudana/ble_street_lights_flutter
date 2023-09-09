import 'dart:developer';
import 'dart:io';

import 'package:ble_street_lights/bledevice/data.dart';
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

  String? previousVersion;

  Future<Uint8List> _downloadFirmwareFile() async {
    //final req = await HttpClient().getUrl(Uri.parse("https://tmpfiles.org/dl/2274759/esp32_f1.0v.ino.esp32.bin"));
    final req = await HttpClient().getUrl(Uri.parse("https://appstreetlight.000webhostapp.com/firmware/F1.3V.bin"));
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
      int? state = provider.deviceData.otaValue("s", null);
      String? version = provider.deviceData.otaValue("v", null);

      previousVersion ??= version;

      late Widget view;

      if (version != null &&
          previousVersion != null &&
          version != previousVersion) {
        view = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.done_outline,
              size: 60,
              color: Colors.blue.withOpacity(0.5),
            ),
            Text(
              "Welcome to Version $version",
              style: const TextStyle(
                fontSize: 24,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("updated ${previousVersion!} to $version"),
          ],
        );
      } else {
        if (state == null) {
          view = const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("[Details Not Received]"),
            ],
          );
        }

        if (state == BLEDeviceData.OTA_STA_READY) {
          view = Column(
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
                      child: Text("Download Firmware File"),
                    )
                  : FilledButton(
                      onPressed: () {
                        _startUpdate(provider);
                      },
                      child: Text("Update Now"),
                    ),
              firmwareBytes != null
                  ? Text(
                      "Download successfully. ${firmwareBytes!.length} bytes")
                  : Container(),
            ],
          );
        }

        if (state == BLEDeviceData.OTA_STA_RECEIVING) {
          view = Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Sending the file..."),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: sentPercent,
              ),
            ],
          );
        }

        if (state == BLEDeviceData.OTA_STA_RECEIVED) {
          view = const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "File Successfully Received",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("starting OTA update..."),
            ],
          );
        }

        if (state == BLEDeviceData.OTA_STA_UPDATING) {
          view = const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "OTA Updating...",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }

        if (state == BLEDeviceData.OTA_STA_REBOOTING) {
          view = const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Rebooting The Device...",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("looking for re-connecting"),
            ],
          );
        }

        if (state == BLEDeviceData.OTA_STA_ERROR) {
          view = Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Error",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(provider.deviceData.otaValue("e", "[no description]")),
            ],
          );
        }
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text("Firmware Updater"),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    "Current Version:",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    version ?? "[not received]",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: view,
              ),
            ],
          ),
        ),
      );
    });
  }
}
