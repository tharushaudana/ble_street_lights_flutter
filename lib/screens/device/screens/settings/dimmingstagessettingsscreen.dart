import 'dart:developer';
import 'dart:ui';
import 'package:ble_street_lights/components/sliverpersistentheaderbuilder/sliverpersistentheaderbuilder.dart';
import 'package:ble_street_lights/components/neumorphismbutton/neumorphismbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'dart:math' as math;

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
                                widget.settingsData["mode"] = "gradual";
                              } else {
                                return;
                              }

                              setState(() {});
                            },
                            borderRadius: BorderRadius.circular(10),
                            isSelected: [
                              widget.settingsData["mode"] == "manual",
                              widget.settingsData["mode"] == "gradual",
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
                                  "Gradual",
                                  style: TextStyle(
                                    fontWeight:
                                        widget.settingsData["mode"] == "gradual"
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
                                        onClose: () {
                                          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                            setState(() {});
                                          });
                                        },
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
    this.onClose,
  });

  final List stages;
  final VoidCallback? onClose;

  @override
  State<StatefulWidget> createState() => _ManualStagesDialogState();
}

class _ManualStagesDialogState extends State<ManualStagesDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;

  List unfinishedStages = [];

  addStage() async {
    TimeRange? range = await openTimeRangePicker();

    if (range == null) return;

    widget.stages.add({
      "pwm": 100,
      "from": range.startTime,
      "to": range.endTime,
    });

    reInitTabController();
    setState(() {});
  }

  deleteStage(int index) {
    widget.stages.removeAt(index);
    reInitTabController();
    setState(() {});
  }

  reInitTabController() {
    _tabController.dispose();
    _tabController =
        TabController(length: widget.stages.length + 1, vsync: this);

    if (widget.stages.isNotEmpty) {
      _tabController.index = widget.stages.length - 1;
    }

    addTabControllerListener();
  }

  addTabControllerListener() {
    _tabController.addListener(() {
      setState(() {});
    });
  }

  Future<TimeRange?> openTimeRangePicker({
    TimeOfDay? from,
    TimeOfDay? to,
  }) async {
    return await showTimeRangePicker(
        context: context,
        start: from,
        end: to,
        ticks: 12,
        padding: 50,
        ticksOffset: 0,
        ticksColor: Colors.blue,
        paintingStyle: PaintingStyle.fill,
        strokeColor: Colors.blue.withOpacity(0.5),
        labels: [
          for (int i = 0; i < 12; i++)
            ClockLabel(
              angle: (math.pi * 2) / 12 * (-3 + i),
              text:
                  "${((12 + 2 * i) - (i > 5 ? 24 : 0)).toString().padLeft(2, '0')}h",
            )
        ]);
  }

  Widget stageItem(int index) {
    Map stage = widget.stages[index];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        children: [
          Text(
            "STAGE ${index + 1}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 40),
          SleekCircularSlider(
            initialValue: (stage["pwm"] as int).toDouble(),
            appearance: CircularSliderAppearance(
              customColors: CustomSliderColors(
                trackColor: Colors.blue.shade100,
                progressBarColors: [
                  Colors.blue,
                  Colors.blue.shade100,
                ],
                hideShadow: true,
              ),
            ),
            onChange: (double value) {
              stage["pwm"] = value.round();
            },
          ),
          const Spacer(),
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: const Offset(0, 1),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ]),
                child: InkWell(
                  onTap: () async {
                    TimeRange? range = await openTimeRangePicker(
                      from: stage["from"],
                      to: stage["to"],
                    );

                    if (range == null) return;

                    stage["from"] = range.startTime;
                    stage["to"] = range.endTime;

                    setState(() {});
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.blue,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          stage["from"] != null
                              ? "${stage["from"].hour.toString().padLeft(2, '0')} : ${stage["from"].minute.toString().padLeft(2, '0')}"
                              : "...",
                          style: const TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Text("to"),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.blue,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          stage["to"] != null
                              ? "${stage["to"].hour.toString().padLeft(2, '0')} : ${stage["to"].minute.toString().padLeft(2, '0')}"
                              : "...",
                          style: const TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Are you sure ?"),
                      content: const Text(
                          "After delete this stage, it can't be undo."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            deleteStage(index);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "DELETE",
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("CANCEL"),
                        ),
                      ],
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete,
                      color: Colors.red.withOpacity(0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "DELETE",
                      style: TextStyle(
                        color: Colors.red.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
  void dispose() {
    if (widget.onClose != null) widget.onClose!();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stageItems = [];

    for (int i = 0; i < widget.stages.length; i++) {
      stageItems.add(stageItem(i));
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
              child: const Row(
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
        height: 430,
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: stageItems,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < widget.stages.length + 1; i++)
                    GestureDetector(
                      onTap: () {
                        _tabController.index = i;
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        decoration: BoxDecoration(
                          color: _tabController.index == i
                              ? Colors.blue
                              : Colors.transparent,
                          border: i <= widget.stages.length - 1
                              ? Border.all(
                                  width: 0.5,
                                  color: Colors.blue,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(
                              _tabController.index == i ? 7.5 : 5),
                        ),
                        child: i == widget.stages.length
                            ? Icon(
                                Icons.add,
                                size: 10,
                                color: _tabController.index == i
                                    ? Colors.white
                                    : Colors.blue,
                              )
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
