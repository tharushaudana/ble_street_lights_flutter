import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:ble_street_lights/bledevice/data.dart';
import 'package:ble_street_lights/components/simplestepper/simplestepper.dart';
import 'package:ble_street_lights/safestate/safestate.dart';
import 'package:ble_street_lights/screens/device/devicesyncer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:flutter/material.dart';
import 'package:enhance_stepper/enhance_stepper.dart';
import 'package:cupertino_stepper/cupertino_stepper.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:math' as math;

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

  double? progress;

  Uint8List? firmwareBytes;

  String? previousVersion;

  BLEDeviceConnectionProvider? _provider;

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
      //return;

      firmwareBytes = await _downloadFirmwareFile();

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        firmwareFileDownloaded = true;
      });

      _startUpdate();
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

  _startUpdate() async {
    if (_provider == null || firmwareBytes == null) return;

    setState(() {
      progress = null;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    bool b = await showDeviceSyncDialog(
      context: context,
      initialText: "Starting Send...",
      provider: _provider!,
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
        progress = 0;
      });

      log("Start sending firmware file...");

      int totalLen = firmwareBytes!.length;

      _provider!.sendFirmwareFile(
        firmwareBytes!.buffer,
        onWrite: (writtenLen) {
          setState(() {
            progress = (writtenLen / totalLen);
          });
        },
        onDone: () {
          log("Firmware File Sent.");
        },
      );
    }
  }

  int? _getCurrentStep(int? state) {
    if (state == BLEDeviceData.OTA_STA_READY && firmwareUpdateStarted) return 0;

    if (state == BLEDeviceData.OTA_STA_RECEIVING) return 1;

    if (state == BLEDeviceData.OTA_STA_RECEIVED) {
      progress = null;
      return 1;
    }

    if (state == BLEDeviceData.OTA_STA_UPDATING) return 2;

    if (state == BLEDeviceData.OTA_STA_REBOOTING) return 3;

    return null;
  }

  //############################### Animated Icons ###################################
  Animate _iconDownload() {
    return Transform.rotate(
      angle: math.pi / 2,
      child: const Icon(
        //Icons.arrow_downward_rounded,
        Icons.arrow_right_alt_rounded,
        color: Colors.blue,
        size: 40,
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .move(
          begin: const Offset(0, -10),
          end: const Offset(0, 10),
          duration: 1000.ms,
          curve: Curves.easeInOutSine,
        )
        .fade(duration: 500.ms)
        .fadeOut(duration: 500.ms, delay: 500.ms);
  }

  Animate _iconUpload() {
    return Transform.rotate(
      angle: math.pi + math.pi / 2,
      child: const Icon(
        //Icons.arrow_downward_rounded,
        Icons.arrow_right_alt_rounded,
        color: Colors.blue,
        size: 40,
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .move(
          begin: const Offset(0, 10),
          end: const Offset(0, -10),
          duration: 1000.ms,
          curve: Curves.easeInOutSine,
        )
        .fade(duration: 500.ms)
        .fadeOut(duration: 500.ms, delay: 500.ms);
  }

  Animate _iconSync() {
    return const Icon(
      //Icons.arrow_downward_rounded,
      Icons.sync_rounded,
      color: Colors.blue,
      size: 40,
    )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .rotate(
          begin: 0,
          end: -math.pi / 2,
          duration: 1000.ms,
          curve: Curves.easeInOutSine,
        )
        .fade(duration: 500.ms)
        .fadeOut(duration: 500.ms, delay: 500.ms);
  }
  //##################################################################################

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
      _provider = provider;

      int? state = provider.deviceData.otaValue("s", null);
      String? version = provider.deviceData.otaValue("v", null);

      int? currentStep = _getCurrentStep(state);

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
            Container(
              width: 120,
              height: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 3,
                    color: Colors.blue,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.done_rounded,
                  size: 60,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 45),
            const Text(
              "Update Completed",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 100),
            Text(
              "Successfully updated $previousVersion to $version",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
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
      } else {
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
                        CircularPercentIndicator(
                          radius: 75,
                          lineWidth: 10.0,
                          percent: progress ?? 0,
                          progressColor: Colors.blue,
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                        Column(
                          children: [
                            [
                              _iconDownload(),
                              _iconUpload(),
                              _iconSync(),
                              _iconSync(),
                            ][currentStep!],
                          ],
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 60),
                      child: progress != null
                          ? Text(
                              "${(progress! * 100).toInt()}% Completed",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Text(
                              "Please wait...",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const Column(
                      children: [
                        Text(
                          "When download is complete,",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "firmware update process will start automatically.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Please do not turn off device power during update process.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 70),
                    SizedBox(
                      height: 100,
                      child: SimpleStepper(
                        currentStep: currentStep!,
                        indicatorSize: 20,
                        lineStrokeWidth: 2,
                        inactiveColor: Colors.grey.shade400,
                        lineColor: Colors.grey.shade400,
                        stepTitles: const [
                          ["Download", "Downloading..."],
                          ["Upload", "Uploading..."],
                          ["Update", "Upating..."],
                          ["Reboot", "Rebooting..."],
                        ],
                      ),
                    )
                  ],
                ),
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
