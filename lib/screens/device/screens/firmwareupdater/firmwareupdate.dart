import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:ble_street_lights/bledevice/data.dart';
import 'package:ble_street_lights/bledevice/request.dart';
import 'package:ble_street_lights/components/simplestepper/simplestepper.dart';
import 'package:ble_street_lights/safestate/safestate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:math' as math;

class DeviceFirmwareUpdaterScreen extends StatefulWidget {
  const DeviceFirmwareUpdaterScreen({
    super.key,
    required this.did,
  });

  final String did;

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

  int showWidgetId = 0;
  /*
    0: CircularPercentageIndicator
    1: Done Gif
    2: CircularProgressIndicator (for loading)
    3: Error Icon
  */

  String loadingText = "";
  String errorText = "";

  int currentStep = 0;

  double? progress;

  Uint8List? firmwareBytes;

  String? previousVersion;

  BLEDeviceConnectionProvider? _provider;

  bool canPop = true;

  late AssetImage _doneGif;

  _getInfo() async {
    setState(() {
      errorLoadInfo = false;
      infoLoaded = false;
    });

    Map formData = {
      "api_key": "tPmAT5Ab3j7F9",
      "id": widget.did,
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

      //print(info);
    } catch (e) {
      log("Info Load Error: $e");

      setState(() {
        canPop = true;
        errorLoadInfo = true;
      });
    }
  }

  _startDownloadFirmwareFile() async {
    canPop = false;

    _setShowWidgetId(0); // percent

    setState(() {
      progress = 0;
      firmwareUpdateStarted = true;
      errorFirmwareFileDownload = false;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      //return;

      firmwareBytes = await _downloadFirmwareFile();

      await Future.delayed(const Duration(milliseconds: 500));

      firmwareFileDownloaded = true;
      _setShowWidgetId(1); // done

      await Future.delayed(const Duration(milliseconds: 2000));

      _startUpdate();
    } catch (e) {
      errorFirmwareFileDownload = true;
      _setErrorText("Download failed!");
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

    _setLoadingText("Turning to Firmware Mode...");

    await Future.delayed(const Duration(milliseconds: 2000));

    bool b = await _turnDeviceToFirmwareMode();

    if (b) {
      isSending = true;
      progress = 0;
      _setShowWidgetId(0); // percent

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

  Future<bool> _turnDeviceToFirmwareMode() {
    final c = Completer<bool>();

    BLEDeviceRequest request = BLEDeviceRequest("set")
      ..subject("fus")
      ..data({
        's': firmwareBytes!.length,
      });

    request.listen(
      onSuccess: (_) {
        c.complete(true);
      },
      onFailed: (err) {
        _setErrorText("Unknown error!");
        c.complete(false);
      },
      onTimeOut: () {
        _setErrorText("Request Timed Out!");
        c.complete(false);
      },
    );

    _provider!.makeRequest(request);

    return c.future;
  }

  _setShowWidgetId(int id) {
    setState(() {
      showWidgetId = id;
    });
  }

  _setErrorText(String err) {
    showWidgetId = 3;
    errorText = err;
    canPop = true;
    setState(() {});
  }

  _setLoadingText(String txt) {
    showWidgetId = 2;
    loadingText = txt;
    setState(() {});
  }

  _setCurrentStep(int? state) {
    if (state == BLEDeviceData.OTA_STA_READY && firmwareUpdateStarted) {
      currentStep = 0;
      return;
    }

    if (state == BLEDeviceData.OTA_STA_RECEIVING) currentStep = 1;

    if (state == BLEDeviceData.OTA_STA_RECEIVED) {
      //showWidgetId = 1; // done
      currentStep = 1;
    }

    if (state == BLEDeviceData.OTA_STA_UPDATING) {
      showWidgetId = 0; // percent
      loadingText = "Please wait...";
      progress = null;
      currentStep = 2;
    }

    if (state == BLEDeviceData.OTA_STA_REBOOTING) {
      showWidgetId = 0; // percent
      loadingText = "Please wait...";
      progress = null;
      currentStep = 3;
    }

    if (state == BLEDeviceData.OTA_STA_ERROR) {
      showWidgetId = 3; // error
      errorText = "Process failed!";
      canPop = true;
    }
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
    _doneGif = const AssetImage("assets/images/done-loop-10.gif");
    super.initState();
    _getInfo();
  }

  @override
  void dispose() {
    _doneGif.evict();
    super.dispose();
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

      _setCurrentStep(state);

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
              "Successfully updated ${previousVersion}v to ${version}v",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("BACK TO HOME"),
            ),
          ],
        );

        canPop = true;
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
        view = !firmwareUpdateStarted
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "New Update Available",
                          style: TextStyle(
                            fontSize: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Container(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: 135,
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 25,
                                ),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue,
                                      Colors.purpleAccent,
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: 135,
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 25,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                  gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white.withOpacity(0),
                                        Colors.white,
                                      ],
                                      stops: const [
                                        0.5,
                                        1
                                      ]),
                                ),
                              ),
                              Container(
                                height: 100,
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 25,
                                ),
                                child: Row(
                                  children: [
                                    const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "What's New",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          "Find out what's included in this update.",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      info!["available_version"] + "v",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "monospace",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 5,
                            ),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              children: [
                                for (String note in info!["relase"])
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.circle,
                                          size: 5,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(note)
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Firmware Information",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Text("Version:"),
                                    const SizedBox(width: 8),
                                    Text(info!["available_version"])
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Text("Release Date:"),
                                    const SizedBox(width: 8),
                                    Text(info!["date"])
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Device Information",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Text("DID:"),
                                    const SizedBox(width: 8),
                                    Text(widget.did),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Text("Serial:"),
                                    const SizedBox(width: 8),
                                    Text(info!["serial"]),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Text("Current Version:"),
                                    const SizedBox(width: 8),
                                    Text(version),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(20),
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
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 150,
                          child: Center(
                            child: [
                              CircularPercentIndicator(
                                radius: 75,
                                lineWidth: 10.0,
                                percent: progress ?? 1,
                                progressColor: Colors.blue,
                                circularStrokeCap: CircularStrokeCap.round,
                              ),
                              Image(
                                image: _doneGif,
                                width: 95,
                                height: 95,
                              ),
                              const CircularProgressIndicator(),
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 95,
                                color: Colors.red,
                              ),
                            ][showWidgetId],
                          ),
                        ),
                        showWidgetId == 0
                            ? Column(
                                children: [
                                  [
                                    _iconDownload(),
                                    _iconUpload(),
                                    _iconSync(),
                                    _iconSync(),
                                  ][currentStep!],
                                ],
                              )
                            : Container(),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 60),
                      child: showWidgetId == 3
                          ? Text(
                              errorText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            )
                          : showWidgetId == 0 && progress != null
                              ? Text(
                                  "${(progress! * 100).toInt()}% Completed",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  loadingText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        [
                          const Text(
                            "When download is complete, firmware update process will start automatically.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const Text(
                            "When device started updating, system LED flashing faster.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const Text(
                            "When device started updating, system LED flashing faster.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const Text(
                            "Wait a few seconds for complete reboot.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ][currentStep!],
                        const SizedBox(height: 20),
                        const Text(
                          "Please do not turn off device power & bluetooth during update process.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15,
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

      return WillPopScope(
        onWillPop: () async {
          if (!canPop) {
            showDialog(
              context: context,
              builder: (mContext) => AlertDialog(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                title: const Text(
                  "Update In Progress",
                ),
                content: const Text(
                  "Please wait until it's done.",
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(mContext);
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }

          return canPop;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "Firmware Updater",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(
              color: Colors.black,
            ),
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
            ),
          ),
          body: Container(
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
            child: view,
          ),
        ),
      );
    });
  }
}
