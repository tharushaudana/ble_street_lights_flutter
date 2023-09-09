import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ble_street_lights/bledevice/data.dart';
import 'package:ble_street_lights/safestate/safestate.dart';
import 'package:ble_street_lights/screens/device/devicesyncer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:flutter/material.dart';

class DeviceFirmwareUpdaterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DeviceFirmwareUpdaterScreenState();
}

class _DeviceFirmwareUpdaterScreenState
    extends SafeState<DeviceFirmwareUpdaterScreen> {
  bool infoLoaded = false;
  bool errorLoadInfo = false;
  Map? info;

  bool firmwareUpdateStarted = false;

  bool firmwareFileDownloaded = false;
  bool errorFirmwareFileDownload = false;

  bool isSending = false;
  double sentPercent = 0;

  double? progress;

  Uint8List? firmwareBytes;

  String? previousVersion;

  _getInfo() async {
    setState(() {
      errorLoadInfo = false;
      infoLoaded = false;
    });

    Map formData = {
      "api_key": "tPmAT5Ab3j7F9",
      "id": "test",
    };

    final String formBody = formData.entries
        .map(
          (e) => e.key + "=" + e.value,
        )
        .join("&");

    List<int> bodyBytes = utf8.encode(formBody); // utf8 encode

    try {
      final request = await HttpClient().postUrl(
        Uri.parse("https://appstreetlight.000webhostapp.com/info.php"),
      );

      request.headers.set('Content-Type', "application/x-www-form-urlencoded");
      request.headers.set('Content-Length', bodyBytes.length.toString());
      request.add(bodyBytes);

      HttpClientResponse res = await request.close();

      if (res.statusCode != 200) {
        setState(() {
          errorLoadInfo = true;
        });

        return;
      }

      final bytes = await consolidateHttpClientResponseBytes(res);
      String body = utf8.decode(bytes);

      info = json.decode(body);

      setState(() {
        infoLoaded = true;
      });

      print(info);
    } catch (e) {
      log("Info Load Error: $e");

      setState(() {
        errorLoadInfo = true;
      });
    }
  }

  _startDownloadFirmwareFile() async {
    setState(() {
      firmwareUpdateStarted = true;
      errorFirmwareFileDownload = false;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      await _downloadFirmwareFile();

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        firmwareFileDownloaded = true;
      });
    } catch (e) {
      setState(() {
        errorFirmwareFileDownload = true;
      });
    }
  }

  Future<Uint8List> _downloadFirmwareFile() async {
    final url = "${info!['url']}${info!['name']}.bin";

    final req = await HttpClient().getUrl(
      Uri.parse(url),
    );

    final res = await req.close();

    final bytes = await consolidateHttpClientResponseBytes(
      res,
      onBytesReceived: (cumulative, total) {
        if (total == null) return;
        setState(() {
          progress = cumulative / total;
        });
      },
    );

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
    _getInfo();
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

      //##################### DOWNLOAD THE INFORMATIONS #####################

      if (!infoLoaded && !errorLoadInfo) {
        view = const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Checking..."),
          ],
        );
      } else if (errorLoadInfo) {
        view = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 90,
              color: Colors.red,
            ),
            const SizedBox(height: 10),
            const Text(
              "Unable to retrive firmware update informations.",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Make sure you have turn on mobile data or wifi.",
              style: TextStyle(fontSize: 12),
            ),
            TextButton(
              onPressed: () {
                _getInfo();
              },
              child: const Text("TRY AGAIN"),
            ),
          ],
        );
      }

      //##################### OTA UPDATED DONE #####################

      else if (version != null &&
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
      }

      //##################### OTA STATES (BEFORE DONE) #####################

      else if (state == null) {
        view = const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 90,
              color: Colors.red,
            ),
            SizedBox(height: 10),
            Text(
              "Current firmware details not received for the device. It seems like there has some connection issues.",
              style: TextStyle(
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      } else if (double.parse(version!) ==
          double.parse(info!["available_version"])) {
        view = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              version,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 70,
                fontFamily: "monospace",
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Already Latest Version",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Update not available yet.",
              style: TextStyle(fontSize: 12),
            ),
          ],
        ).animate().fade(duration: 500.ms);
      } else if (state == BLEDeviceData.OTA_STA_READY) {
        /*!firmwareFileDownloaded
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
                ? Text("Download successfully. ${firmwareBytes!.length} bytes")
                : Container(),*/

        view = !firmwareUpdateStarted
            ? Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Device:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              info!["device"],
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Text(
                              "Current Version:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              version,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          width: 1,
                          color: Colors.blue,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.blue,
                            blurRadius: 5,
                          )
                        ]),
                    child: Row(
                      children: [
                        Icon(
                          Icons.switch_access_shortcut_outlined,
                          size: 60,
                          color: Colors.blue.withOpacity(0.8),
                        ),
                        const SizedBox(width: 25),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Update Available",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              info!["available_version"],
                              style: const TextStyle(
                                fontSize: 40,
                                fontFamily: "monospace",
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(info!["description"]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Release Note",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(info!["relase"]),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (mContext) => AlertDialog(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            title: const Text(
                              "Warning",
                              textAlign: TextAlign.center,
                            ),
                            content: const Text(
                              "Download firmware will generate data traffic, are you sure to continue?",
                              textAlign: TextAlign.center,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(mContext);
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(mContext);
                                  _startDownloadFirmwareFile();
                                },
                                child: const Text("Download"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text("UPDATE NOW"),
                    ),
                  ),
                ],
              )
            : Container(
                margin: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.blue.withOpacity(0.2),
                          ),
                        ),
                        Column(
                          children: [
                            Icon(
                              Icons.download_rounded,
                              color: Colors.blue,
                              size: 40,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Downloading...",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              );
      } else if (state == BLEDeviceData.OTA_STA_RECEIVING) {
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
      } else if (state == BLEDeviceData.OTA_STA_RECEIVED) {
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
      } else if (state == BLEDeviceData.OTA_STA_UPDATING) {
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
      } else if (state == BLEDeviceData.OTA_STA_REBOOTING) {
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
      } else if (state == BLEDeviceData.OTA_STA_ERROR) {
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

      return Scaffold(
        appBar: AppBar(
          title: const Text("Firmware Updater"),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(20),
          child: view,
        ),
      );
    });
  }
}
