import 'dart:ui';
import 'package:ble_street_lights/components/sliverpersistentheaderbuilder/sliverpersistentheaderbuilder.dart';
import 'package:ble_street_lights/components/neumorphismbutton/neumorphismbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class DimmingStagesSettingsScreen extends StatefulWidget {
  const DimmingStagesSettingsScreen({
    super.key,
    required this.settingsData,
    this.onClose,
  });

  final Map settingsData;
  final VoidCallback? onClose;

  @override
  State<StatefulWidget> createState() => _DimmingStagesSettingsScreenState();
}

class _DimmingStagesSettingsScreenState
    extends State<DimmingStagesSettingsScreen> {
  Widget _valueBox(String title, String value) {
    return Row(
      children: [
        Icon(
          Icons.calendar_month_rounded,
          color: Colors.grey.shade400,
          size: 30,
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _settingCard(
    Widget child, {
    border = false,
    shadow = true,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: shadow
              ? [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    offset: const Offset(0, 1),
                    blurRadius: 20,
                    //spreadRadius: 2,
                  ),
                ]
              : [],
          border: border
              ? Border.all(
                  width: 1,
                  color: Colors.blue,
                )
              : null,
          borderRadius: BorderRadius.circular(20)),
      child: child,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (widget.onClose != null) widget.onClose!();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dimming Stages"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),
          _settingCard(
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Status",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.subdirectory_arrow_right_rounded,
                          size: 20,
                        ),
                        Text(
                          widget.settingsData["enabled"] ? "ON" : "OFF",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                NeumorphismButton(
                  initialSwitched: widget.settingsData["enabled"],
                  glowEnabled: false,
                  onSwitching: (will) {
                    setState(() {
                      widget.settingsData["enabled"] = will;
                    });
                    return true;
                  },
                ),
              ],
            ),
            shadow: false,
            border: true,
          ),
          widget.settingsData["enabled"]
              ? Column(
                  children: [
                    _settingCard(
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Mode",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.subdirectory_arrow_right_rounded,
                                    size: 20,
                                  ),
                                  Text(
                                    widget.settingsData["mode"]
                                        .toString()
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          ToggleButtons(
                            onPressed: (index) {
                              if (index == 0) {
                                widget.settingsData["mode"] = "manual";
                              } else if (index == 1) {
                                widget.settingsData["mode"] = "auto";
                              } else {
                                return;
                              }

                              setState(() {});
                            },
                            borderRadius: BorderRadius.circular(10),
                            isSelected: [
                              widget.settingsData["mode"] == "manual",
                              widget.settingsData["mode"] == "auto",
                            ],
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "Manual",
                                  style: TextStyle(
                                    fontWeight:
                                        widget.settingsData["mode"] == "manual"
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "Auto",
                                  style: TextStyle(
                                    fontWeight:
                                        widget.settingsData["mode"] == "auto"
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    widget.settingsData["mode"] == "manual"
                        ? _settingCard(
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Stages",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons
                                              .subdirectory_arrow_right_rounded,
                                          size: 20,
                                        ),
                                        Text(
                                          "${widget.settingsData["stages"].length} STAGE(S)",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                FilledButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => ManualStagesDialog(
                                        stages: widget.settingsData["stages"],
                                      ),
                                    );
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 5),
                                      Text("EDIT")
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fade(duration: 100.ms)
                        : Container(),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {},
                        child: Text("UPDATE"),
                      ),
                    ),
                  ],
                ).animate().fade(duration: 100.ms)
              : const SizedBox(
                  height: 100,
                  child: Center(
                    child: Text(
                      "Turn on for show settings.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class ManualStagesDialog extends StatefulWidget {
  const ManualStagesDialog({
    super.key,
    required this.stages,
  });

  final List stages;

  @override
  State<StatefulWidget> createState() => _ManualStagesDialogState();
}

class _ManualStagesDialogState extends State<ManualStagesDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;

  addStage() {
    widget.stages.add({
      "pwm": 50,
      "start": "",
      "end": "",
    });

    reInitTabController();

    setState(() {});
  }

  reInitTabController() {
    _tabController.dispose();
    _tabController =
        TabController(length: widget.stages.length + 1, vsync: this);
    _tabController.index = widget.stages.length - 1;
    addTabControllerListener();
  }

  addTabControllerListener() {
    _tabController.addListener(() {
      setState(() {});
    });
  }

  Widget stageItem(Map stageData) {
    return Container(
      child: Column(
        children: [Text("this is item")],
      ),
    );
  }

  @override
  void initState() {
    _tabController =
        TabController(length: widget.stages.length + 1, vsync: this);
    addTabControllerListener();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stageItems = [];

    for (var stage in widget.stages) {
      stageItems.add(stageItem(stage));
    }

    stageItems.add(
      Container(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "No more stages.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                addStage();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 5),
                  Text("ADD ONE"),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Container(
          height: 400,
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: stageItems,
                ),
              ),
              Container(
                margin: EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < widget.stages.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        decoration: BoxDecoration(
                            color: _tabController.index == i ? Colors.blue : Colors.transparent,
                            border: Border.all(
                              width: 0.5,
                              color: Colors.blue,
                            ),
                            borderRadius: BorderRadius.circular(
                                _tabController.index == i ? 7.5 : 5)),
                      )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
